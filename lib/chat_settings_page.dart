import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service_web.dart'; // Import your ApiServiceImpl class

class ChatSettingsPage extends StatefulWidget {
  final List<String> recipients;
  final ApiServiceImpl apiService; // Add ApiServiceImpl

  const ChatSettingsPage({
    super.key, 
    required this.recipients,
    required this.apiService, // Add ApiServiceImpl parameter
  });

  @override
  _ChatSettingsPageState createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool _shortPressToAI = false;
  final TextEditingController _systemPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String recipientsKey = widget.recipients.join(",");
    
/*     try {
      await _apiService.saveChatSettings(recipientsKey, {
        'shortPressToAI': _shortPressToAI,
        'systemPrompt': _systemPromptController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved successfully')));
    } catch (e) {
      _logger.severe('Failed to save settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings')));
    } */
  }

  Future<void> _saveSettings() async {
    try {
      await widget.apiService.saveChatSettings(widget.recipients, _shortPressToAI, _systemPromptController.text);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved successfully')));
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _shortPressToAI ? 'Short press for AI' : 'Long press for AI',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _shortPressToAI,
                  onChanged: (bool value) {
                    setState(() {
                      _shortPressToAI = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _systemPromptController,
              decoration: const InputDecoration(
                labelText: 'AI System Prompt',
              ),
              maxLines: null,
              onChanged: (value) {
                _saveSettings(); // Save settings as the user types
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }
}
