import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'login_page.dart';
import 'notification_helper.dart';  // Import the helper file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger('GlobalErrorHandler').severe('Flutter error caught by global handler', details.exception, details.stack);
  };

  await initializeNotifications();  // Initialize notifications

  runApp(MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (!record.message.contains('toggled cursor') && !record.message.contains('field changed') && !record.message.contains('InputConnectionWrapper')) {
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('Stack Trace: ${record.stackTrace}');
      }
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
