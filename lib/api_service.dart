import 'api_service_web.dart';
import 'api_service_interface.dart';
  //if (dart.library.io) 'api_service_io.dart'
  //if (dart.library.html) 'api_service_web.dart';

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
  Future<void> joinChatRoom(String chatUsername) {
    return _service.joinChatRoom(chatUsername); // Add this line
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String message, String type) {
    return _service.sendMessage(message, type);
  }

  @override
  void connectToWebSocket(void Function(Map<String, dynamic>) onMessageReceived) {
    _service.connectToWebSocket(onMessageReceived);
  }

  @override
  void disconnectWebSocket() {
    _service.disconnectWebSocket();
  }
}