import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  final String? chatId;
  final String? chatUsername;

  ChatPage({this.chatId, this.chatUsername});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final uuid = Uuid();
  final _logger = Logger('ChatPage');
  final ApiService _apiService = ApiService();
  String? _chatUsername;

  @override
  void initState() {
    super.initState();
    _chatUsername = widget.chatUsername;
    _loadChat(widget.chatId);
    _apiService.connectToWebSocket((message) {
      _logger.info('Received message from WebSocket: $message');
      setState(() {
        final chatMessage = ChatMessage(
          id: message['id'],
          text: message['text'],
          isUserMessage: false,
          type: message['type'] == 'type1' ? MessageType.type1Received : MessageType.type2Received,
          replyTo: message['replyTo'],
        );
        _messages.add(chatMessage);
      });
    });
  }

  void _loadChat(String? chatId) {
    if (chatId != null) {
      _logger.info('Loading chat with ID: $chatId');
    } else {
      _logger.info('Starting a new chat');
    }
  }

  @override
  void dispose() {
    _apiService.disconnectWebSocket();
    super.dispose();
  }

  void _sendMessage(MessageType type) async {
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
      final response = await _apiService.sendMessage(text, type == MessageType.type1Sent ? "type1" : "type2");
      _logger.info('Message sent successfully: ${response['message']}');
    } catch (e) {
      _logger.severe('Failed to send message: $e');
    }

    if (type == MessageType.type1Sent) {
      _logger.info('Simulating server response for message ID: $messageId');
      Future.delayed(const Duration(seconds: 3), () {
        final responseMessage = ChatMessage(
          id: uuid.v4(),
          text: 'Server response to "$text"',
          isUserMessage: false,
          type: MessageType.type1Received,
          replyTo: messageId,
        );
        _logger.info('Received server response: $responseMessage');
        setState(() {
          _messages.add(responseMessage);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _chatUsername != null ? 'Chat with $_chatUsername' : 'New Chat',
          style: TextStyle(color: Colors.black),
        ),
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

enum MessageType {
  type1Sent,
  type1Received,
  type2Sent,
  type2Received,
}

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
