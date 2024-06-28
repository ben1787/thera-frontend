import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service_interface.dart';
import 'package:logging/logging.dart';

class ApiServiceImpl implements ApiServiceInterface {
  final String baseUrl = "https://ai-chat-webapp-bb.azurewebsites.net";
  WebSocketChannel? _channel;
  final _logger = Logger('ApiServiceImpl');

  @override
  Future<Map<String, dynamic>> authenticateUser(String username, String password) async {
    final url = '$baseUrl/register';
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
  Future<void> joinChatRoom(String chatUsername) async {
    final url = '$baseUrl/join';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode(<String, String>{
      'chatUsername': chatUsername,
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
      throw Exception('Failed to join chat room. Status code: ${response.statusCode}, Body: ${response.body}');
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
    _channel = WebSocketChannel.connect(Uri.parse('wss://ai-chat-webapp-bb.azurewebsites.net/websocket'));

    _channel?.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      onMessageReceived(decodedMessage);
    });
  }

  @override
  void disconnectWebSocket() {
    _channel?.sink.close();
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
