import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';
import '/i18n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  SettingsPage({required this.onLanguageChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('languageCode');
    if (savedLanguage != null) {
      setState(() {
        _selectedLanguage = savedLanguage;
      });
    }
  }

  void _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
      Restart.restartApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.settingsPageTitle!),
      ),
      body: settings_body(appLocalizations),
    );
  }

  Padding settings_body(AppLocalizations appLocalizations) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            appLocalizations.languageSelectionLabel!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
                _changeLanguage(newValue);
              });
            },
            items: <String>[
              'en',
              'fr',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toUpperCase(),
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
