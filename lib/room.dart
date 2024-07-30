import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; // Ensure you have this import

class Room {
  final List<String> phones;
  final String ts;

  Room({required this.phones, required this.ts});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      phones: List<String>.from(json['phones']),
      ts: json['ts'],
    );
  }

  String getFormattedTimestamp() {
    final DateTime parsedTimestamp = DateFormat("EEE, d MMM yyyy HH:mm:ss 'GMT'").parse(ts);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedTimestamp);
  }

  String getContactNames(List<Contact> contacts, String loggedInPhoneNumber) {
    // Remove non-digit characters from the loggedInPhoneNumber for comparison
    String cleanedLoggedInPhoneNumber = loggedInPhoneNumber.replaceAll(RegExp(r'\D'), '');

    List<String> names = phones.where((phone) {
      // Remove non-digit characters from the current phone number for comparison
      String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
      return cleanedPhone != cleanedLoggedInPhoneNumber;
    }).map((phone) {
      // Find the first contact whose phone number matches the current phone after removing non-digit characters.
      return contacts.firstWhere(
        (c) => c.phones.isNotEmpty && c.phones.first.number.replaceAll(RegExp(r'\D'), '') == phone.replaceAll(RegExp(r'\D'), ''),
        // If no matching contact is found, return a new Contact with the display name set to the phone number.
        orElse: () => Contact(displayName: phone)
      ).displayName; // Use the display name of the found or created contact
    }).toList();

    // Join the names with commas and return the result.
    return names.join(', ');
  }
}
