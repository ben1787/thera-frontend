abstract class ApiServiceInterface {
  Future<Map<String, dynamic>> authenticateUser(String username, String password);
  Future<Map<String, dynamic>> sendMessage(String message, String type);
  void connectToWebSocket(void Function(Map<String, dynamic>) onMessageReceived);
  void disconnectWebSocket();
  Future<void> joinChatRoom(String chatUsername); // Add this line
}