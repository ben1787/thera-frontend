import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:logging/logging.dart';
import 'package:choose_input_chips/choose_input_chips.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service_web.dart'; // Import your ApiServiceImpl class
import 'login_page.dart'; // Import LoginPage
import 'contact_info.dart';
import 'room.dart';

class ChatListPage extends StatefulWidget {
  final ApiServiceImpl apiService;  // Shared instance
  final String loggedInPhone;

  const ChatListPage({super.key, required this.apiService, required this.loggedInPhone});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final Logger _logger = Logger('ChatListPage');
  final List<ContactInfo> _selectedContacts = [];
  List<Contact> _contacts = [];
  late ApiServiceImpl _apiService; // Use ApiServiceImpl for WebSocketManager
  List<Room> _rooms = [];  // To store rooms with phone numbers
  final TextEditingController _controller = TextEditingController(); // Define controller
  final GlobalKey<ChipsInputState> _chipKey = GlobalKey<ChipsInputState>(); // Key for ChipsInput

  @override
  void initState() {
    super.initState();
    _logger.info('ChatListPage initialized');
    _requestPermissionAndFetchContacts();

    // Use the shared ApiService instance
    _apiService = widget.apiService;
    _apiService.connectToWebSocket();
    _logger.info('Starting chat with access token: ${_apiService.accessToken}');

    _fetchRooms(); // Fetch the rooms
  }

  Future<void> _fetchRooms() async {
    try {
      _logger.severe('Feching rooms...');
      List<Room> rooms = await _apiService.getRooms(); // Adjust to handle the correct return type
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      _logger.severe('Failed to fetch rooms: $e');
    }
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

  List<ContactInfo> _getContactSuggestions(String query) {
    List<ContactInfo> matches = [];
    for (var contact in _contacts) {
      bool nameMatches = contact.displayName.toLowerCase().contains(query.toLowerCase());
      bool phoneMatches = contact.phones.isNotEmpty && contact.phones.first.number.replaceAll(RegExp(r'\D'), '').contains(query.replaceAll(RegExp(r'\D'), ''));

      if ((nameMatches || phoneMatches) && query.trim().isNotEmpty) {
        matches.add(ContactInfo(
          name: contact.displayName,
          phoneNumber: contact.phones.isNotEmpty ? contact.phones.first.number : '',
        ));
      }
    }

    // Add the free-form text as a suggestion if no contact matches and it's a valid phone number
    if (matches.isEmpty && query.isNotEmpty && isValidPhoneNumber(query)) {
      matches.add(ContactInfo(name: query, phoneNumber: query));
    }

    return matches;
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  void _startChat(BuildContext context) {
    if (_selectedContacts.isEmpty) {
      _logger.warning('No contacts selected');
      return;
    }
    _logger.info('Starting chat with: $_selectedContacts');
    final selectedContactsSnapshot = List<ContactInfo>.from(_selectedContacts); // Take a snapshot of the current selection
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          apiService: _apiService,
          recipients: selectedContactsSnapshot,
          loggedInPhone: widget.loggedInPhone,
        ),
      ),
    ).then((_) {
      // Refresh the chat list when coming back
      _logger.info('Refreshing rooms');
      _fetchRooms();
    });
  }

  void _logout() {
    _logger.info('User logged out');
    // Clear any session data if needed
    _apiService.disconnectWebSocket(); // Disconnect WebSocket
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage(apiService: _apiService)), // Navigate to LoginPage
      (route) => false,
    );
  }

  @override
  void dispose() {
    _apiService.disconnectWebSocket();
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  void _joinRoom(BuildContext context, Room room) {
    try {
      // Extract the room contacts from the Room object
      List<ContactInfo> roomContacts = room.phones
        .where((phone) => phone != widget.loggedInPhone) // Filter out the logged-in user's phone number
        .map((phone) {
        // Find the contact that matches the phone number
        var matchingContact = _contacts.firstWhere(
          (c) => c.phones.isNotEmpty && c.phones.any((p) => p.number.replaceAll(RegExp(r'\D'), '') == phone.replaceAll(RegExp(r'\D'), '')),
          orElse: () => Contact(displayName: phone)
        );

        String name = matchingContact.displayName.isNotEmpty ? matchingContact.displayName : phone;

        _logger.info('Matched contact: Name: $name, Phone: $phone');

        return ContactInfo(name: name, phoneNumber: phone);
      }).toList();

      // Log the names and phone numbers of the recipients
      final recipientDetails = roomContacts.map((c) => 'Name: ${c.name}, Phone: ${c.phoneNumber}').join('; ');
      _logger.info('Recipients: $recipientDetails');
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            apiService: _apiService,
            recipients: roomContacts,
            loggedInPhone: widget.loggedInPhone,
          ),
        ),
      ).then((_) {
        // Refresh the chat list when coming back
        _logger.info('Refreshing rooms');
        _fetchRooms();
      });
    } catch (e) {
      _logger.severe('Failed to join room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ChipsInput<ContactInfo>(
                key: _chipKey,
                initialValue: _selectedContacts,
                maxChips: 5,
                findSuggestions: (String query) async {
                  _logger.info('ChipsInput findSuggestions with query: $query');
                  return _getContactSuggestions(query);
                },
                onChanged: (data) {
                  _logger.info('ChipsInput onChanged with data: $data');
                  setState(() {
                    _selectedContacts
                      ..clear()
                      ..addAll(data);
                    _logger.info('Updated selected contacts: $_selectedContacts');
                  });
                },
                chipBuilder: (context, state, contact) {
                  return InputChip(
                    key: ObjectKey(contact),
                    label: Text(contact.name),
                    onDeleted: () {
                      state.deleteChip(contact);
                      setState(() {
                        _selectedContacts.remove(contact);
                        _logger.info('Deleted contact: ${contact.name}, updated selected contacts: $_selectedContacts');
                      });
                    },
                  );
                },
                suggestionBuilder: (context, state, contact) {
                  return ListTile(
                    key: ObjectKey(contact),
                    title: Text(contact.name),
                    subtitle: Text(contact.phoneNumber),
                    onTap: () => state.selectSuggestion(contact),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Select contacts or enter a phone number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _startChat(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start Chat'),
              ),
              const SizedBox(height: 16),
              const Text('Existing Rooms:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ..._rooms.map((room) => ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(room.getContactNames(_contacts, widget.loggedInPhone)), // Pass loggedInPhone
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(room.getFormattedTimestamp()),
                    ),
                  ],
                ),
                onTap: () => _joinRoom(context, room), // Pass the Room object
              )),
            ],
          ),
        ),
      ),
    );
  }
}
