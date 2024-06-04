import 'package:flutter/material.dart';

import '../other.dart/welcome.dart';
import '../authentication.dart/Splashcreen.dart';
final Map<String, WidgetBuilder> routes = {
   Splash.routeName: (context) => Splash(),
   Welcome.routeName: (context) =>Welcome(),

};