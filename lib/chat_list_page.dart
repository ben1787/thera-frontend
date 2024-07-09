import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:logging/logging.dart';

class ChatListPage extends StatelessWidget {
  final String token;
  final String loggedInUsername; // Add loggedInUsername parameter

  ChatListPage({required this.token, required this.loggedInUsername});

  final TextEditingController _usernameController = TextEditingController();
  final Logger _logger = Logger('ChatListPage');

  void _startChat(BuildContext context) {
    final chatUsername = _usernameController.text;
    if (chatUsername.isEmpty) {
      _logger.warning('Username is empty');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatUsername: chatUsername,
          token: token,
          loggedInUsername: loggedInUsername, // Provide the username
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter username to start chat',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
              ),
              child: Text('Start Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
