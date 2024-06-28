import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure this is imported

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
      // Navigate to the ChatPage on successful login
      Navigator.pushReplacementNamed(context, '/chat');
    } catch (e) {
      _messageNotifier.value = 'Failed to authenticate user: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              child: Text('Login'),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _messageNotifier,
              builder: (context, message, _) {
                return Text(message);
              },
            ),
          ],
        ),
      ),
    );
  }
}
