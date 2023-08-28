import 'package:flutter/material.dart';

class LocalizedApp extends InheritedWidget {
  final String languageCode;

  const LocalizedApp({
    Key? key,
    required this.languageCode,
    required Widget child,
  }) : super(key: key, child: child);

  static LocalizedApp? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalizedApp>();
  }

  @override
  bool updateShouldNotify(LocalizedApp oldWidget) {
    return languageCode != oldWidget.languageCode;
  }
}