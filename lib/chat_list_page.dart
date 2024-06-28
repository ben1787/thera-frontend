import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'api_service.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  List<String> chatTitles = []; // Example: initially empty

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  void _fetchChatList() async {
    // Fetch chat list from the API
    final chats = await _apiService.getChatList(); // Adjust this line based on your API implementation
    setState(() {
      chatTitles = chats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Chats', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter username',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_usernameController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      chatId: null,
                      chatUsername: _usernameController.text,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: Colors.white, // Set button text color
            ),
            child: Text('Start New Chat'),
          ),
          Expanded(
            child: chatTitles.isEmpty
                ? Center(child: Text('No chats yet', style: TextStyle(color: Colors.black)))
                : ListView.builder(
                    itemCount: chatTitles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(chatTitles[index], style: TextStyle(color: Colors.black)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                chatId: index.toString(),
                                chatUsername: chatTitles[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
