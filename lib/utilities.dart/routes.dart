import 'package:flutter/material.dart';

import '../other.dart/welcome.dart';
import '../authentication.dart/Splashcreen.dart';
final Map<String, WidgetBuilder> routes = {
   Splash.routeName: (context) => const Splash(),
   Welcome.routeName: (context) =>const Welcome(),

};