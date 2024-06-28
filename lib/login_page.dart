import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_list_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ValueNotifier<String> _messageNotifier = ValueNotifier('');

  void _authenticate(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await _apiService.authenticateUser(username, password);
      _messageNotifier.value = response['message'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatListPage()),
      );
    } catch (e) {
      _messageNotifier.value = 'Failed to authenticate user: $e';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Login', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white, // Set button text color
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _messageNotifier,
              builder: (context, message, _) {
                return Text(message, style: TextStyle(color: Colors.red));
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
