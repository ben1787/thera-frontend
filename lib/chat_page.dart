import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'api_service_web.dart'; // Import your ApiServiceImpl class
import 'chat_settings_page.dart'; // Import ChatSettingsPage
import 'contact_info.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';

class ChatMessage {
  final String id;
  final String user;
  final String text;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.user,
    required this.text,
    required this.type
  });

  @override
  String toString() {
    return 'ChatMessage{id: $id, user: $user, text: $text, type: $type}';
  }
}

enum MessageType {
  type0, // from server
  type1, // user to AI
  type2, // AI to user
  type3, // user to user
}

extension MessageTypeExtension on MessageType {
  String description() {
    switch (this) {
      case MessageType.type1:
        return '1';
      case MessageType.type2:
        return '2';
      case MessageType.type3:
        return '3';
      default:
        return '0';
    }
  }
}

MessageType _getMessageType(String type) {
  switch (type) {
    case '1':
      return MessageType.type1;
    case '2':
      return MessageType.type2;
    case '3':
      return MessageType.type3;
    default:
      return MessageType.type0; // Default type, or handle accordingly
  }
}

class ChatPage extends StatefulWidget {
  final ApiServiceImpl apiService;  // Shared instancefinal 
  final List<ContactInfo> recipients;
  final String loggedInPhone;

  const ChatPage({super.key, 
    required this.apiService,
    required this.recipients,
    required this.loggedInPhone,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add this line
  final uuid = const Uuid();
  final _logger = Logger('ChatPage');
  late List<ContactInfo> _recipients;
  late ApiServiceImpl _apiService; // Use ApiServiceImpl for WebSocketManager
  bool _showType1 = true; // Add this line  
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _logger.info('ChatPage initState called');
    _recipients = widget.recipients;
    _apiService = widget.apiService;

    _apiService.joinRoom(_recipients.map((c) => c.phoneNumber.replaceAll(RegExp(r'\D'), '')).toList(), (message) {
      _logger.info('Received message from WebSocket: $message');
      // Log the names and phone numbers of the recipients
      final recipientDetails = _recipients.map((c) => 'Name: ${c.name}, Phone: ${c.phoneNumber}').join('; ');
      _logger.info('Recipients: $recipientDetails');

      final username = message['user'];
      final type = message['type'];
      if ((username == widget.loggedInPhone) & (type != MessageType.type2.description())) {
        _logger.info('Ignoring message from self');
        return;
      }

      if (!mounted) {
        _logger.warning('Widget is not mounted. Cannot update state.');
        return;
      }

      setState(() {
        final chatMessage = ChatMessage(
          id: uuid.v4(),
          user: message['user'] ?? 'server',
          text: message['msg'],
          type: _getMessageType(message['type'] ?? '0')
        );
        _messages.add(chatMessage);
      });
    });

    // Scroll to the bottom after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
   });   

    // Subscribe
    keyboardSubscription = KeyboardVisibilityController().onChange.listen((bool visible) {
      _logger.info('Keyboard visibility update. Is visible: $visible');

      // Scroll to the bottom after the first frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('scrolling to bottom init');
        _scrollToBottom();
      });   
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _logger.info('ChatPage dispose called');
    _apiService.leaveRoom(_recipients.map((c) => c.phoneNumber.replaceAll(RegExp(r'\D'), '')).toList());
    _scrollController.dispose(); // Dispose the scroll controller
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _sendMessage(MessageType type) {
    final text = _controller.text;
    if (text.isEmpty) {
      _logger.warning('Attempted to send an empty message');
      return;
    }

    final messageId = uuid.v4();
    final newMessage = ChatMessage(
      id: messageId,
      text: text,
      user: widget.loggedInPhone,
      type: type,
    );

    _logger.info('Sending message: $newMessage');

    setState(() {
      _messages.add(newMessage);  // Add new message to the end of the list
      _controller.clear();
    });

    // Scroll to the bottom after adding a new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logger.info('Scrolling to bottom');
      _scrollToBottom();
    });

    try {
      _apiService.sendMessage(_recipients.map((c) => c.phoneNumber.replaceAll(RegExp(r'\D'), '')).toList(), text, type.description());
      _logger.info('Message sent successfully');
    } catch (e) {
      _logger.severe('Failed to send message: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  _logger.info('ChatPage build called');

  // Filter out the logged-in user from the recipients
  final filteredRecipients = _recipients.where((c) => c.name != widget.loggedInPhone).toList();

  // Map the filtered recipients to their names and join with commas
  final recipientNames = filteredRecipients.map((c) => c.name).join(", ");

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text(
        recipientNames,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        Switch(
          value: _showType1,
          onChanged: (value) {
            setState(() {
              _showType1 = value;
            });
          },
          activeColor: Colors.blueAccent,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatSettingsPage(
                  recipients: _recipients
                      .map((c) => c.phoneNumber.replaceAll(RegExp(r'\D'), ''))
                      .toList(),
                ),
              ),
            ).then((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logger.info('Scrolling to bottom');
                _scrollToBottom();
              });
            });
          },
        ),
      ],
    ),
    resizeToAvoidBottomInset: true,
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              if (!_showType1 && (message.type == MessageType.type1 || message.type == MessageType.type1)) {
                return Container();
              }
              final inGreySection = _isMessageInGreySection(message);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: message.user == widget.loggedInPhone
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: inGreySection ? Colors.grey[300] : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(
                      message.text,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onSubmitted: (value) {
                    _sendMessage(MessageType.type1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _sendMessage(MessageType.type1);
                },
                onLongPress: () {
                  _sendMessage(MessageType.type3);
                },
                child: const Icon(Icons.send, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}

  bool _isMessageInGreySection(ChatMessage message) {
    return message.type == MessageType.type1 || message.type == MessageType.type2;
  }
}
