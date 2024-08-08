import 'room.dart';
import 'chat_message.dart';

abstract class ApiServiceInterface {
  Future<Map<String, dynamic>> authenticateUser(String username, String password);
  void connectToWebSocket();
  void joinRoom(List<String> to, void Function(Map<String, dynamic>) onMessageReceived);
  void leaveRoom(List<String> to);
  void sendMessage(List<String> to, String message, String type);
  void disconnectWebSocket();
  Future<List<Room>> getRooms();  
  Future<List<ChatMessage>> fetchMessages(List<String> phones);  // New method to fetch messages
  Future<void> saveChatSettings(List<String> phones, bool shortPressToAI, String systemPrompt);
}