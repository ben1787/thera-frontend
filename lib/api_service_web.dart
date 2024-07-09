import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service_interface.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiServiceImpl implements ApiServiceInterface {
  final String baseUrl = "https://ai-chat-webapp-cc1fa1616037.herokuapp.com"; // Ensure this is https for secure connections
  IO.Socket? _socket;
  final _logger = Logger('ApiServiceImpl');

  @override
  void connectToWebSocket(String token, List<String> to, void Function(Map<String, dynamic>) onMessageReceived) {
    _logger.info('Connecting to WebSocket with token: $token');

    // Configure WebSocket options with autoConnect disabled
    final options = IO.OptionBuilder()
      .setTransports(['websocket'])
      .setExtraHeaders({'Authorization': 'Bearer $token'}) // Ensure the header is set
      .disableAutoConnect() // Disable automatic connection
      .build();

    _socket = IO.io(baseUrl, options);
    _logger.info('WebSocket instance created with options but not connected yet.');

    // Manual connection when this method is called
    _socket?.connect();

    _logger.info('WebSocket created with options and $token');

    _socket?.on('connect', (_) {
      _logger.info('Connected to WebSocket server');
      _logger.info('Joining room with token: $token, room: $to');
      _socket?.emit('join', {'to': to});
      _logger.info('Joined room: $to');
    });


    _socket?.onAny((event, data) {
      _logger.info('Received event: $event, data: $data');
    });

    _socket?.on('disconnect', (_) {
      _logger.info('Disconnected from WebSocket server');
    });

    // Set up listener for incoming messages
    _socket?.on('message', (data) {
      _logger.info('Received message: $data');
      if (data is Map<String, dynamic>) {
        onMessageReceived(data); // Call the callback with the received message
      } else {
        _logger.warning('Received data is not a Map<String, dynamic>: $data');
      }
    });

    // Add error and reconnect event listeners
    _socket?.on('error', (error) {
      _logger.severe('WebSocket error: $error');
    });

    _socket?.on('reconnect', (attempt) {
      _logger.info('Reconnecting to WebSocket, attempt: $attempt');
    });

    _socket?.on('reconnect_attempt', (attempt) {
      _logger.info('Reconnect attempt: $attempt');
    });

    _socket?.on('reconnect_failed', (error) {
      _logger.severe('Reconnect failed: $error');
    });
  }

  @override
  Future<Map<String, dynamic>> authenticateUser(String username, String password) async {
    final loginUrl = '$baseUrl/login';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode(<String, String>{
      'username': username,
      'password': password,
    });

    // _logger.info('Sending POST request to $registerUrl with body: $body');
    // final registerResponse = await http.post(
    //   Uri.parse(registerUrl),
    //   headers: headers,
    //   body: body,
    // );
    // _logger.info('Received response: ${registerResponse.statusCode} ${registerResponse.body}');

    // if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201 && registerResponse.statusCode != 500) {
    //   throw Exception('Failed to register user. Status code: ${registerResponse.statusCode}, Body: ${registerResponse.body}');
    // }

    _logger.info('Sending POST request to $loginUrl with body: $body');
    final loginResponse = await http.post(
      Uri.parse(loginUrl),
      headers: headers,
      body: body,
    );
    _logger.info('Received response: ${loginResponse.statusCode} ${loginResponse.body}');

    if (loginResponse.statusCode == 200) {
      return jsonDecode(loginResponse.body);
    } else {
      throw Exception('Failed to login user. Status code: ${loginResponse.statusCode}, Body: ${loginResponse.body}');
    }
  }

  @override
  void sendMessage(List<String> to, String message, String type) {
    _logger.info('Sending message to room $to: $message');
    _socket?.emit('message', {'to': to, 'message': message, 'type': type});
  }

  @override
  void disconnectWebSocket() {
    _logger.info('Disconnecting WebSocket');
    _socket?.off('connect');
    _socket?.off('disconnect');
    _socket?.off('message');
    _socket?.disconnect();
    _socket = null;
  }

  @override
  Future<List<String>> getChatList() async {
    final url = '$baseUrl/chatList';
    _logger.info('Sending GET request to $url');

    final response = await http.get(Uri.parse(url));
    _logger.info('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      _logger.warning('Failed to fetch chat list. Status code: ${response.statusCode}, Body: ${response.body}');
      return [];
    }
  }
}
