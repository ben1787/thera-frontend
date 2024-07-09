import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'api_service.dart';
import 'chat_list_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ValueNotifier<String> _messageNotifier = ValueNotifier('');
  final Logger _logger = Logger('LoginPage');

  LoginPage() {
    _logger.info('LoginPage created');
  }

  void _authenticate(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    _logger.info('Attempting to authenticate user with username: $username');

    try {
      final response = await _apiService.authenticateUser(username, password);
      final token = response['access_token']; // Extract the token
      _messageNotifier.value = 'Login successful';
      _logger.info('Login successful for user: $username');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatListPage(
            token: token,
            loggedInUsername: username, // Pass the loggedInUsername
          ),
        ),
      );
    } catch (e) {
      _messageNotifier.value = 'Failed to authenticate user: $e';
      _logger.severe('Failed to authenticate user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('LoginPage build started');
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
              onChanged: (value) {
                _logger.info('Username field changed: $value');
              },
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
              onChanged: (value) {
                _logger.info('Password field changed');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
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
