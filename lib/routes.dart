import 'package:flutter/material.dart';

import 'package:mechanical_switch_app/add_switches_route.dart';
import 'package:mechanical_switch_app/main.dart';
import 'package:mechanical_switch_app/switch_info_route.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/addSwitch':
        return MaterialPageRoute(builder: (_) => const AddSwitch());
      case '/switchInfo':
        if (args is Map) {
          return MaterialPageRoute(builder: (_) => SwitchInfo(data: args));
        }
    }

    return MaterialPageRoute(builder: (_) => const HomePage());
  }
}
