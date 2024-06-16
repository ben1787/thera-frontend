import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

void main() {
  // Initialize logging
  _setupLogging();
  runApp(MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final uuid = Uuid();
  final _logger = Logger('ChatPage');

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
      isUserMessage: true, // specifying true for user messages
      type: type,
      replyTo: null,
    );

    _logger.info('Sending message: $newMessage');

    setState(() {
      _messages.add(newMessage);
      _controller.clear();
    });

    if (type == MessageType.type1Sent) {
      _logger.info('Simulating server response for message ID: $messageId');
      Future.delayed(Duration(seconds: 5), () {
        final responseMessage = ChatMessage(
          id: uuid.v4(),
          text: 'Server response to "$text"',
          isUserMessage: false, // specifying false for server messages
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

  bool _isMessageInGreySection(ChatMessage message) {
    if (message.type == MessageType.type1Sent || message.type == MessageType.type1Received) {
      _logger.fine('Message ID: ${message.id} is in grey section');
      return true;
    }
    _logger.fine('Message ID: ${message.id} is not in grey section');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Building ChatPage widget');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final inGreySection = _isMessageInGreySection(message);
                _logger.fine('Rendering message ID: ${message.id}, inGreySection: $inGreySection');
                return Container(
                  color: inGreySection ? Colors.grey[200] : Colors.transparent,
                  child: ListTile(
                    title: Align(
                      alignment: message.isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: message.isUserMessage
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(message.text),
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
                      labelText: 'Enter your message',
                    ),
                    onSubmitted: (value) {
                      _sendMessage(MessageType.type1Sent);
                    },
                  ),
                ),
                GestureDetector(
                  onLongPress: () {
                    _logger.info('Sending Type 2 message');
                    _sendMessage(MessageType.type2Sent);
                  },
                  onTap: () {
                    _logger.info('Sending Type 1 message');
                    _sendMessage(MessageType.type1Sent);
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

enum MessageType {
  type1Sent,
  type1Received,
  type2Sent,
}
