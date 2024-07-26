import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'api_service_web.dart'; // Import your ApiServiceImpl class
import 'chat_settings_page.dart'; // Import ChatSettingsPage

class ChatMessage {
  final String id;
  final String text;
  final bool isUserMessage;
  final MessageType type;
  final String? replyTo;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUserMessage,
    required this.type,
    this.replyTo,
  });

  @override
  String toString() {
    return 'ChatMessage{id: $id, text: $text, isUserMessage: $isUserMessage, type: $type, replyTo: $replyTo}';
  }
}

enum MessageType {
  type1Sent,
  type1Received,
  type2Sent,
  type2Received,
}

extension MessageTypeExtension on MessageType {
  String description() {
    switch (this) {
      case MessageType.type1Sent:
        return '1';
      case MessageType.type1Received:
        return '1';
      case MessageType.type2Sent:
        return '2';
      case MessageType.type2Received:
        return '2';
      default:
        return 'Unknown';
    }
  }
}

class ChatPage extends StatefulWidget {
  final ApiServiceImpl apiService;  // Shared instance
  final List<String> recipients;
  final String loggedInUsername;

  ChatPage({
    required this.apiService,
    required this.recipients,
    required this.loggedInUsername,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final uuid = Uuid();
  final _logger = Logger('ChatPage');
  late List<String> _recipients;
  late ApiServiceImpl _apiService; // Use ApiServiceImpl for WebSocketManager

  @override
  void initState() {
    super.initState();
    _logger.info('ChatPage initState called');
    _recipients = widget.recipients;
    _apiService = widget.apiService;

    _apiService.joinRoom(_recipients, (message) {
      _logger.info('Received message from WebSocket: $message');

      final username = message['user'];
      final type = message['type'];
      if ((username == widget.loggedInUsername) & (type != MessageType.type1Received.description()) || (username != widget.loggedInUsername) & (type == MessageType.type1Received.description())) {
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
          text: message['msg'] ?? '',
          isUserMessage: false,
          type: MessageType.type1Received,
          replyTo: null,
        );
        _messages.add(chatMessage);
      });
    });
  }

  @override
  void dispose() {
    _logger.info('ChatPage dispose called');
    _apiService.leaveRoom(_recipients);
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
      isUserMessage: true,
      type: type,
      replyTo: null,
    );

    _logger.info('Sending message: $newMessage');

    setState(() {
      _messages.add(newMessage);
      _controller.clear();
    });

    try {
      _apiService.sendMessage(_recipients, text, type.description());
      _logger.info('Message sent successfully');
    } catch (e) {
      _logger.severe('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('ChatPage build called');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Chat with ${_recipients.join(", ")}',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatSettingsPage(recipients: _recipients), // Pass recipients
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final inGreySection = _isMessageInGreySection(message);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: message.isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inGreySection ? Colors.grey[300] : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: Colors.black),
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
                    style: TextStyle(color: Colors.black),
                    onSubmitted: (value) {
                      _sendMessage(MessageType.type1Sent);
                    },
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _sendMessage(MessageType.type1Sent);
                  },
                  onLongPress: () {
                    _sendMessage(MessageType.type2Sent);
                  },
                  child: Icon(Icons.send, color: Colors.black),
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
    return message.type == MessageType.type1Sent || message.type == MessageType.type1Received;
  }
}
