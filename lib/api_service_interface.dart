abstract class ApiServiceInterface {
  void connectToWebSocket(String token, List<String> to, void Function(Map<String, dynamic>) onMessageReceived);
  Future<Map<String, dynamic>> authenticateUser(String username, String password);
  void sendMessage(List<String> to, String message, String type);
  void disconnectWebSocket();
  Future<List<String>> getChatList();
}