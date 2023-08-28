import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakelock/wakelock.dart';
import '/i18n/app_localizations.dart';
import 'i18n/language_config.dart';
import 'view/home_page.dart';
import 'conf_auth/login_page.dart';
import 'view/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  Wakelock.enable();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _currentLocale = Locale('fr', '');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      setState(() {
        _currentLocale = Locale(languageCode);
      });
    }
  }

  void _changeLanguage(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    if (_isLanguageSupported(locale)) {
      setState(() {
        _currentLocale = locale;
      });
      Restart.restartApp();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsupported Language'),
          content: Text('The selected  language is not supported.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _isLanguageSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizedApp(
      languageCode: _currentLocale.languageCode,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Odoo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.grey,
          ),
        ),
        home: widget.isLoggedIn ? HomePage() : LoginPage(),
        locale: _currentLocale,
        supportedLocales: [
          const Locale('fr', ''),
          const Locale('en', ''),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          '/settings': (context) => SettingsPage(
                onLanguageChanged: _changeLanguage,
              ),
        },
      ),
    );
  }
}
