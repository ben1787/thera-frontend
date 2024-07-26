import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service_interface.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_helper.dart';  // Import the helper file

class WebSocketManager {
  IO.Socket? _socket;
  final Logger _logger = Logger('WebSocketManager');
  bool _listenersAttached = false;
  List<String>? _currentRoom; // Variable to track the current room
  void Function(Map<String, dynamic>)? _onMessageReceived;

  // Singleton instance
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  void connect(String url, String token, Future<String> Function() refreshTokenCallback) {
    _logger.info('Connecting to WebSocket with token: $token');

    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .disableAutoConnect()
        .build();

    _socket = IO.io(url, options);
    _logger.info('WebSocket instance created with options but not connected yet.');

    _socket?.connect();

    if (!_listenersAttached) {
      _socket?.on('connect', (_) {
        _logger.info('Connected to WebSocket server');
        _logger.info('Socket ID: ${_socket?.id}');
        _logger.info('Socket Connected: ${_socket?.connected}');
        _logger.info('Socket URL: ${_socket?.io.uri}');
        _rejoinRoom(); // Rejoin room on reconnect
      });

      _socket?.onAny((event, data) {
        _logger.info('Received event: $event, data: $data');
      });

      _socket?.on('disconnect', (reason) {
        _logger.info('Disconnected from WebSocket server, reason: $reason');
        if (reason == 'io server disconnect') {
          // Handle server disconnect if necessary
        }
      });

      _socket?.on('error', (error) async {
        _logger.severe('WebSocket error: $error');
        if (error is Map<String, dynamic> && error['msg'] == 'Token Has Expired') {
          _logger.info('Token has expired, refreshing token...');
          String newToken = await refreshTokenCallback(); // Use the callback to refresh token and reconnect
          _logger.info('Reconnecting to WebSocket with new token...');
          connect(url, newToken, refreshTokenCallback); // Reconnect with the new token
          // Rejoin the current room if needed
          if (_currentRoom != null) {
            joinRoom(_currentRoom!, _onMessageReceived!);
          }
        }
      });

      _socket?.on('message', (data) async {
        _logger.info('Received message: $data');
        if (data is Map<String, dynamic>) {
          _onMessageReceived?.call(data);
        } else {
          _logger.warning('Received data is not a Map<String, dynamic>: $data');
        }
      });

      _socket?.on('notification', (data) async {
        _logger.info('Received notification: $data');
        if (data is Map<String, dynamic>) {
          // Show notification if necessary
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

      _socket?.on('reconnect', (attempt) {
        _logger.info('Reconnecting to WebSocket, attempt: $attempt');
        _rejoinRoom(); // Rejoin room on reconnect
      });

      _socket?.on('reconnect_attempt', (attempt) {
        _logger.info('Reconnect attempt: $attempt');
      });

      _socket?.on('reconnect_failed', (error) {
        _logger.severe('Reconnect failed: $error');
      });

      _listenersAttached = true;
    }
  }

  void joinRoom(List<String> to, void Function(Map<String, dynamic>) onMessageReceived) {
    _logger.info('Joining room: $to');
    if (_socket != null && _socket!.connected) {
      _socket?.emit('join', {'to': to});
      _logger.info('Just emitted to: $to');
      _currentRoom = to; // Set the current room
      _onMessageReceived = onMessageReceived;

      _socket?.on('join_confirmation', (data) {
        _logger.info('Joined room confirmation received: $data');
      });
    } else {
      _logger.severe('Socket is not connected, cannot join room');
    }
  }

  void _rejoinRoom() {
    if (_currentRoom != null) {
      _logger.info('Rejoining room: $_currentRoom');
      joinRoom(_currentRoom!, _onMessageReceived!);
    }
  }

  void leaveRoom(List<String> to) {
    _logger.info('Leaving room: $to');
    _socket?.emit('leave', {'to': to});
    _currentRoom = null;
    _onMessageReceived = null;
  }

  void clearListeners() {
    if (_socket != null) {
      _socket?.off('connect');
      _socket?.off('disconnect');
      _socket?.off('message');
      _socket?.off('error');
      _socket?.off('reconnect');
      _socket?.off('reconnect_attempt');
      _socket?.off('reconnect_failed');
    }
    _listenersAttached = false;
  }

  void sendMessage(List<String> to, String message, String type) {
    _logger.info('Sending message to room $to: $message');
    _socket?.emit('message', {'to': to, 'message': message, 'type': type});
  }

  void disconnect() {
    _logger.info('Disconnecting WebSocket');
    clearListeners();
    _socket?.disconnect();
    _socket = null;
  }
}

class ApiServiceImpl implements ApiServiceInterface {
  final String baseUrl = "https://ai-chat-webapp-cc1fa1616037.herokuapp.com";
  final WebSocketManager _webSocketManager = WebSocketManager(); // Use the singleton instance
  final _logger = Logger('ApiServiceImpl');
  String? accessToken;
  String? refreshToken;

  @override
  void connectToWebSocket() {
    _logger.info('ApiServiceImpl instance: $hashCode');  // Log instance identity
    if (accessToken != null) {
      _webSocketManager.connect(baseUrl, accessToken!, refreshTokenAndReconnect);
      _logger.info('connectToWebSocket Access token: $accessToken');
    } else {
      _logger.severe('Cannot connect to WebSocket: Access token is null');
    }
  }

  Future<String> refreshTokenAndReconnect() async {
    _logger.info('ApiServiceImpl instance in callback: $hashCode');  // Log instance identity
    _logger.info('refreshTokenAndReconnect Refresh token: $refreshToken');
    await _handleTokenExpiry();
    return accessToken!;
  }

  Map<String, String> _authHeaders() {
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }

  @override
  void joinRoom(List<String> to, void Function(Map<String, dynamic>) onMessageReceived) {
    _webSocketManager.joinRoom(to, onMessageReceived);
    _logger.info('joinRoom Refresh token: $refreshToken');
  }

  @override
  void leaveRoom(List<String> to) {
    _webSocketManager.leaveRoom(to);
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
  void sendMessage(List<String> to, String message, String type) {
    _webSocketManager.sendMessage(to, message, type);
  }

  @override
  void disconnectWebSocket() {
    _webSocketManager.disconnect();
  }

  @override
  Future<List<String>> getChatList() async {
    final url = '$baseUrl/chatList';
    _logger.info('Sending GET request to $url');

    final response = await http.get(Uri.parse(url), headers: _authHeaders());
    _logger.info('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _handleTokenExpiry();
      return getChatList(); // Retry the request
    } else {
      _logger.warning('Failed to fetch chat list. Status code: ${response.statusCode}, Body: ${response.body}');
      return [];
    }
  }

  Future<void> _handleTokenExpiry() async {
    _logger.info('_handleTokenExpiry Refresh token: $refreshToken');
    if (refreshToken != null) {
      final refreshUrl = '$baseUrl/refresh';
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $refreshToken', // Include the refresh token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        accessToken = responseBody['access_token'];
        if (responseBody.containsKey('refresh_token')) {
          refreshToken = responseBody['refresh_token']; // Update the refresh token if a new one is provided
        }
        _logger.info('Token refreshed successfully. New refresh token: $refreshToken');
      } else {
        _logger.severe('Failed to refresh token, logging out');
        // Handle logout or prompt user to re-login
      }
    } else {
      _logger.severe('No refresh token available, logging out');
      // Handle logout or prompt user to re-login
    }
  }
}
