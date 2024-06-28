import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'api_service_interface.dart';
import 'package:logging/logging.dart';

class ApiServiceImpl implements ApiServiceInterface {
  final String baseUrl = "https://ai-chat-webapp-bb.azurewebsites.net";
  IOWebSocketChannel? _channel;
  final _logger = Logger('ApiServiceImpl');

  @override
  Future<Map<String, dynamic>> authenticateUser(String username, String password) async {
    final url = '$baseUrl/auth';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode(<String, String>{
      'username': username,
      'password': password,
    });

    _logger.info('Sending POST request to $url with body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    _logger.info('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to authenticate user. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String message, String type) async {
    final url = '$baseUrl/sendMessage';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode(<String, String>{
      'message': message,
      'type': type,
    });

    _logger.info('Sending POST request to $url with body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    _logger.info('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  void connectToWebSocket(void Function(Map<String, dynamic>) onMessageReceived) {
    _channel = IOWebSocketChannel.connect(Uri.parse('wss://ai-chat-webapp-bb.azurewebsites.net/websocket'));

    _channel?.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      onMessageReceived(decodedMessage);
    });
  }

  @override
  void disconnectWebSocket() {
    _channel?.sink.close();
  }
}
