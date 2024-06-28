import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'api_service.dart';
import 'login_page.dart';

void main() {
  _setupLogging();
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger('GlobalErrorHandler').severe('Flutter error caught by global handler', details.exception, details.stack);
  };
  runApp(MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack Trace: ${record.stackTrace}');
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
