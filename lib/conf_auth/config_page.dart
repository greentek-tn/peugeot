import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import 'login_page.dart';

class ConfigPage extends StatelessWidget {
  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController databaseController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  ConfigPage({super.key});

  Future<void> saveConfig(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String serverUrl = serverUrlController.text;
      String database = databaseController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('serverUrl', serverUrl);
      await prefs.setString('database', database);
      await prefs.setBool('isLoggedIn', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          SharedPreferences prefs = snapshot.data!;
          String serverUrl = prefs.getString('serverUrl') ?? '';
          String database = prefs.getString('database') ?? '';
          serverUrlController.text = serverUrl;
          databaseController.text = database;
          return Scaffold(
            appBar: AppBar(title: Text(appLocalizations.Config!)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: serverUrlController,
                      decoration: InputDecoration(
                        labelText: appLocalizations.ServerURL,
                        hintText: appLocalizations.EntertheServerURL,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.ServerWarning;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: databaseController,
                      decoration: InputDecoration(
                        labelText: appLocalizations.Database,
                        hintText: appLocalizations.EntertheDatabase,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.PleaseentertheDatabase;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => saveConfig(context),
                      child: Text(appLocalizations.Save!),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Text(appLocalizations.Erroroccurred!);
        }
      },
    );
  }
}
