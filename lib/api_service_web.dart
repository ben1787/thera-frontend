import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service_interface.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_helper.dart';  // Import the helper file
import 'room.dart';
import 'chat_message.dart';

class WebSocketManager {
  // Singleton instance
  static WebSocketManager? _instance;

  // Factory constructor to return the singleton instance
  factory WebSocketManager(Future<String> Function() refreshTokenCallback) {
    _instance = WebSocketManager._internal(refreshTokenCallback);
    _instance!._logger.info('Returning existing WebSocketManager instance: ${_instance.hashCode}');
    return _instance!;
  }

  // Private constructor
  WebSocketManager._internal(this._refreshTokenCallback) {
    _logger.info('WebSocketManager internal constructor called: ${this.hashCode}');
  }

  // Instance variables
  IO.Socket? _socket;
  final Logger _logger = Logger('WebSocketManager');
  String? _lastEvent;
  dynamic _lastData;
  final Future<String> Function() _refreshTokenCallback;
  void Function(Map<String, dynamic>)? _onMessageReceived;  // Declare _onMessageReceived here

  void connect(String url, String token) {
    _logger.info('Connecting to WebSocket with token: $token');

    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .disableAutoConnect()
        .build();
    
    _socket = IO.io(url, options);
    _socket?.connect();
    
    _socket?.on('connect', (_) {
      _logger.info('Connected to WebSocket server');
      _logger.info('Socket ID: ${_socket?.id}');
      _logger.info('Socket Connected: ${_socket?.connected}');
      _logger.info('Socket URL: ${_socket?.io.uri}');
      
      // Re-emit the last event after successful reconnection
      if (_lastEvent != null && _lastData != null) {
        _emitWebSocketEvent(_lastEvent!, _lastData);
      }
    });

    _socket?.on('disconnect', (reason) async {
      _logger.info('Disconnected from WebSocket server, reason: $reason');
      if (reason == 'token_expired' || reason == 'io client disconnect') {
        _logger.info('Token has expired, refreshing token...');
        reconnect();
      }
    });

    _socket?.on('error', (error) {
      _logger.severe('WebSocket error: $error');
      if (error is Map<String, dynamic> && error['msg'] == 'Token Has Expired') {
        _logger.info('Disconnecting due to expired token');
        _socket?.disconnect();
      }
    });

    _socket?.on('message', (data) async {
      _logger.info('Received message: $data');
      if (data is Map<String, dynamic>) {
        _onMessageReceived?.call(data);  // This will work now
      } else {
        _logger.warning('Received data is not a Map<String, dynamic>: $data');
      }
    });

    _socket?.on('notification', (data) async {
      _logger.info('Received notification: $data');
      if (data is Map<String, dynamic>) {
        if (data['msg'] != null) {
          _logger.info('Notification Received: $data');
          await showNotification(data['msg']);
        } else {
          _logger.warning('Received notification data is null: $data');
        }
      } else {
        _logger.warning('Received data is not a Map<String, dynamic>: $data');
      }
    });
  }

  void reconnect() async {    
    String newToken = await _refreshTokenCallback(); // Use the callback to refresh token and reconnect
    _logger.info('Reconnecting to WebSocket with new token... $newToken');
    _socket?.io.options?['extraHeaders'] = {'Authorization': 'Bearer $newToken'};
    _socket?.connect();
  }

  void _emitWebSocketEvent(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit(event, data);
      _lastEvent = null;
      _lastData = null; // Clear last request after successful emit
    } else {
      _lastEvent = event;
      _lastData = data;
      reconnect(); // Attempt to reconnect and then retry the last request
    }
  }

  void joinRoom(List<String> phones, void Function(Map<String, dynamic>)? onMessageReceived) {
    _logger.info('Joining room: $phones');
    _emitWebSocketEvent('join', {'phones': phones});
    _onMessageReceived = onMessageReceived;
  }

  void leaveRoom(List<String> phones) {
    _logger.info('Leaving room: $phones');
    _emitWebSocketEvent('leave', {'phones': phones});
    _onMessageReceived = null;
  }

  void sendMessage(List<String> phones, String message, String type) {
    _logger.info('Sending message to room $phones: $message');
    _emitWebSocketEvent('message', {'phones': phones, 'message': message, 'type': type});
  }

  void disconnect() {
    _logger.info('Disconnecting WebSocket');
    clearListeners();
    _socket?.disconnect();
    _socket = null;
  }

  void clearListeners() {
    if (_socket != null) {
      _socket?.off('connect');
      _socket?.offAny();
      _socket?.off('disconnect');
      _socket?.off('message');
      _socket?.off('error');
      _socket?.off('reconnect');
      _socket?.off('reconnect_attempt');
      _socket?.off('reconnect_failed');
      _socket?.off('notification');
    }
  }
}

class ApiServiceImpl implements ApiServiceInterface {
  // Singleton instance
  static final ApiServiceImpl _instance = ApiServiceImpl._internal();

  // Factory constructor to return the singleton instance
  factory ApiServiceImpl() {
    _instance._logger.info('Returning ApiServiceImpl instance: ${_instance.hashCode}');
    return _instance;
  }

  // Private constructor
  ApiServiceImpl._internal() : _webSocketManager = WebSocketManager(() => _instance.refreshTokenAndReconnect()) {
    _logger.info('ApiServiceImpl internal constructor called: ${this.hashCode}');
  }

  // Instance variables
  final String baseUrl = "https://ai-chat-webapp-cc1fa1616037.herokuapp.com";
  final WebSocketManager _webSocketManager;
  final _logger = Logger('ApiServiceImpl');
  String? accessToken;
  String? refreshToken;

  Future<http.Response> _performHttpRequest(Future<http.Response> Function() request) async {
    http.Response response = await request();

    if (response.statusCode == 401 || response.body.contains('Token Has Expired')) {
      await _handleTokenExpiry();
      response = await request();
    }

    return response;
  }

  Future<String> refreshTokenAndReconnect() async {
    _logger.info('refreshTokenAndReconnect ApiServiceImpl instance: $hashCode');
    await _handleTokenExpiry();
    return accessToken!;
  }

  Future<void> _handleTokenExpiry() async {
    if (refreshToken != null) {
      final refreshUrl = '$baseUrl/refresh';
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      _logger.info('Refresh token response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        accessToken = responseBody['access_token'];
        if (responseBody.containsKey('refresh_token')) {
          refreshToken = responseBody['refresh_token'];
          _logger.info('Refresh token refreshed successfully. New refresh token: $refreshToken');
        }
        _logger.info('Access token refreshed successfully. New access token: $accessToken');
      } else {
        _logger.severe('Failed to refresh token, logging out. Response: ${response.statusCode} ${response.body}');
        // Handle logout or prompt user to re-login
      }
    } else {
      _logger.severe('No refresh token available, logging out');
      // Handle logout or prompt user to re-login
    }
  }

  Map<String, String> _authHeaders() {
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }

  @override
  void connectToWebSocket() {
    _logger.info('connectToWebSocket ApiServiceImpl instance: $hashCode');
    if (accessToken != null) {
      _webSocketManager.connect(baseUrl, accessToken!);
      _logger.info('connectToWebSocket Access token: $accessToken');
    } else {
      _logger.severe('Cannot connect to WebSocket: Access token is null');
    }
  }

  @override
  void joinRoom(List<String> phones, void Function(Map<String, dynamic>) onMessageReceived) {
    _webSocketManager.joinRoom(phones, onMessageReceived);
    _logger.info('joinRoom access token: $accessToken');
  }

  @override
  void leaveRoom(List<String> phones) {
    _webSocketManager.leaveRoom(phones);
  }

  @override
  Future<Map<String, dynamic>> authenticateUser(String username, String password) async {
    final loginUrl = '$baseUrl/login';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode(<String, String>{
      'phone': username,
      'password': password,
    });

    _logger.info('Sending POST request to $loginUrl with body: $body');
    final loginResponse = await http.post(
      Uri.parse(loginUrl),
      headers: headers,
      body: body,
    );
    _logger.info('Received response: ${loginResponse.statusCode} ${loginResponse.body}');

    if (loginResponse.statusCode == 200) {
      final responseBody = jsonDecode(loginResponse.body);
      accessToken = responseBody['access_token'];
      refreshToken = responseBody['refresh_token']; // Capture the refresh token      
      _logger.info('Authentication successful. Access token and refresh token set.'); 
      _logger.info('Refresh token: $refreshToken');
      return responseBody;
    } else {
      throw Exception('Failed to login user. Status code: ${loginResponse.statusCode}, Body: ${loginResponse.body}');
    }
  }

  @override
  void sendMessage(List<String> phones, String message, String type) {
    _webSocketManager.sendMessage(phones, message, type);
  }

  @override
  void disconnectWebSocket() {
    _webSocketManager.disconnect();
  }

  @override
  Future<List<Room>> getRooms() async {
    final url = '$baseUrl/rooms';
    _logger.info('Sending GET request to $url');

    final response = await _performHttpRequest(() async {
      return await http.get(Uri.parse(url), headers: _authHeaders());
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } else {
      _logger.warning('Failed to fetch rooms list. Status code: ${response.statusCode}, Body: ${response.body}');
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> fetchMessages(List<String> phones) async {
    _logger.info('API Response Refreshgin: $phones');
    final response = await _performHttpRequest(() async {
      return await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'phones': phones,
        }),
      );
    });

    _logger.info('API Response2: ${response.statusCode}');
    _logger.info('API Response: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _logger.info('API Response: ${response.body}');
      return data.map((json) => ChatMessage.fromJson(json)).toList();
      // return data.map((json) => ChatMessage.fromJson(json)).toList().reversed.toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  @override
  Future<void> saveChatSettings(List<String> phones, bool shortPressToAI, String systemPrompt) async {
    final url = '$baseUrl/room-prompt';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'phones': phones,
          'setting': systemPrompt,
          'shortPressToAI': shortPressToAI
        }),
      );

      if (response.statusCode == 200) {
        _logger.info('Chat settings updated successfully');
      } else {
        _logger.severe('Failed to update chat settings: ${response.statusCode}, ${response.body}');
        throw Exception('Failed to update chat settings');
      }
    } catch (e) {
      _logger.severe('Exception occurred while updating chat settings: $e');
      throw Exception('Exception occurred while updating chat settings');
    }
  }
}