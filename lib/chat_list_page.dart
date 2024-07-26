import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:logging/logging.dart';
import 'package:choose_input_chips/choose_input_chips.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service_web.dart'; // Import your ApiServiceImpl class
import 'login_page.dart'; // Import LoginPage

class ChatListPage extends StatefulWidget {
  final ApiServiceImpl apiService;  // Shared instance
  final String loggedInUsername;

  ChatListPage({required this.apiService, required this.loggedInUsername});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final Logger _logger = Logger('ChatListPage');
  final List<String> _selectedContacts = [];
  List<Contact> _contacts = [];
  late ApiServiceImpl _apiService; // Use ApiServiceImpl for WebSocketManager

  @override
  void initState() {
    super.initState();
    _logger.info('ChatListPage initialized');
    _requestPermissionAndFetchContacts();

    // Use the shared ApiService instance
    _apiService = widget.apiService;
    _apiService.connectToWebSocket();
    _logger.info('Starting chat with access token: ${_apiService.accessToken}');
  }

  Future<void> _requestPermissionAndFetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      _fetchContacts();
    } else {
      _logger.warning('Contacts permission denied');
    }
  }

  Future<void> _fetchContacts() async {
    try {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      _logger.severe('Failed to fetch contacts: $e');
    }
  }

  List<String> _getContactSuggestions(String query) {
    List<String> matches = [];
    for (var contact in _contacts) {
      if (contact.displayName != null && contact.displayName!.toLowerCase().contains(query.toLowerCase())) {
        matches.add(contact.displayName!);
      }
    }
    return matches;
  }

  void _startChat(BuildContext context) {
    if (_selectedContacts.isEmpty) {
      _logger.warning('No contacts selected');
      return;
    }
    _logger.info('Starting chat with: $_selectedContacts');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          apiService: _apiService,
          recipients: _selectedContacts,
          loggedInUsername: widget.loggedInUsername,
        ),
      ),
    );
  }

  void _logout() {
    _logger.info('User logged out');
    // Clear any session data if needed
    _apiService.disconnectWebSocket(); // Disconnect WebSocket
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
      (route) => false,
    );
  }

  @override
  void dispose() {
    _apiService.disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ChipsInput<String>(
                initialValue: _selectedContacts,
                maxChips: 5,
                findSuggestions: (String query) async {
                  _logger.info('ChipsInput findSuggestions with query: $query');
                  return _getContactSuggestions(query);
                },
                onChanged: (data) {
                  _logger.info('ChipsInput onChanged with data: $data');
                  setState(() {
                    _selectedContacts.clear();
                    _selectedContacts.addAll(data);
                    _logger.info('Updated selected contacts: $_selectedContacts');
                  });
                },
                chipBuilder: (context, state, contact) {
                  _logger.info('Chip builder called with contact: $contact');
                  return InputChip(
                    key: ObjectKey(contact),
                    label: Text(contact),
                    onDeleted: () {
                      state.deleteChip(contact);
                      setState(() {
                        _selectedContacts.remove(contact);
                        _logger.info('Deleted contact: $contact, updated selected contacts: $_selectedContacts');
                      });
                    },
                  );
                },
                suggestionBuilder: (context, state, contact) {
                  _logger.info('Suggestion builder called with contact: $contact');
                  return ListTile(
                    key: ObjectKey(contact),
                    title: Text(contact),
                    onTap: () => state.selectSuggestion(contact),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Select contacts to chat with',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
      ),
    );
  }
}
