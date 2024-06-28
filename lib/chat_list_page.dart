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
        title: Text('Chats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Enter username'),
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
            child: Text('Start New Chat'),
          ),
          Expanded(
            child: chatTitles.isEmpty
                ? Center(child: Text('No chats yet'))
                : ListView.builder(
                    itemCount: chatTitles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(chatTitles[index]),
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
    );
  }
}
