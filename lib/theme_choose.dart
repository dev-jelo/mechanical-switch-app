import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeChoose with ChangeNotifier {
  var box = Hive.box('saved');

  String? theme;
  String? getTheme() => theme;
  ThemeData? themeData;
  ThemeData? getThemeData() => themeData;

  ThemeChoose() {
    theme = box.get('savedTheme');

    // Check system default dark or light setting if no theme was chosen previously
    if (theme == null) {
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      if (isDarkMode) {
        setDark();
      }
    }

    // Set theme if previously chosen
    if (theme == 'dark') {
      setDark();
    } else {
      setLight();
    }
  }

  final lightTheme = ThemeData(
    scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.black54)),
    fontFamily: 'Lato',
    primaryColor: Colors.blueGrey,
    appBarTheme: const AppBarTheme(
      color: Colors.blueGrey,
    ),
    colorScheme: ThemeData().colorScheme.copyWith(
          brightness: Brightness.light,
          primary: Colors.white,
          secondary: Colors.blueGrey,
          secondaryContainer: Colors.blueGrey,
        ),
    snackBarTheme: const SnackBarThemeData(
      actionTextColor: Colors.white70,
    ),
  );

  final darkTheme = ThemeData(
    fontFamily: 'Lato',
    appBarTheme: const AppBarTheme(
      color: Color(0xFF222222),
      titleTextStyle: TextStyle(color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ThemeData().colorScheme.copyWith(
          brightness: Brightness.dark,
          primary: Colors.grey.shade900,
          secondary: Colors.green.shade800,
          secondaryContainer: Colors.grey.shade700,
        ),
    snackBarTheme: const SnackBarThemeData(
      actionTextColor: Colors.white70,
    ),
  );

  void setLight() {
    box.put('savedTheme', 'light');
    theme = 'light';
    themeData = lightTheme;
    notifyListeners();
  }

  void setDark() {
    box.put('savedTheme', 'dark');
    theme = 'dark';
    themeData = darkTheme;
    notifyListeners();
  }
}
