import 'api_service_web.dart';
import 'api_service_interface.dart';
import 'room.dart';
import 'chat_message.dart'; // Import the ChatMessage model

class ApiService implements ApiServiceInterface {
  static final ApiServiceInterface _service = createService();

  factory ApiService() => _serviceInstance;

  static final ApiService _serviceInstance = ApiService._internal();

  ApiService._internal();

  static ApiServiceInterface createService() {
    return ApiServiceImpl();
  }

  @override
  Future<Map<String, dynamic>> authenticateUser(String username, String password) {
    return _service.authenticateUser(username, password);
  }

  @override
  void connectToWebSocket() {
    _service.connectToWebSocket();
  }

  @override
  void joinRoom(List<String> to, void Function(Map<String, dynamic>) onMessageReceived) {
    _service.joinRoom(to, onMessageReceived);
  }

  @override
  void leaveRoom(List<String> to) {
    _service.leaveRoom(to);
  }

  @override
  void sendMessage(List<String> to, String message, String type) {
    _service.sendMessage(to, message, type);
  }

  @override
  void disconnectWebSocket() {
    _service.disconnectWebSocket();
  }

  @override
  Future<List<Room>> getRooms() {
    return _service.getRooms();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(List<String> phones) {
    return _service.fetchMessages(phones); // Implement this method
  }
}
