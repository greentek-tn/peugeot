import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import '../view/home_page.dart';
import 'config_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');

    if (serverUrl == null ||
        serverUrl.isEmpty ||
        database == null ||
        database.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfigPage()),
      );
    } else if (username.isEmpty) {
      AlertDialog(
        title: Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      OdooClient client = OdooClient(serverUrl);
      OdooSession? session =
          await client.authenticate(database, username, password);
      final bool success = session != null;
      final session_id = session.id;
      if (success) {
        print(session.id);
        prefs.setString('session_id', session_id);
        prefs.setBool('isLoggedIn', true);
        prefs.setString('username', username);
        prefs.setString('password', password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.Login!)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfigPage()),
                  );
                },
                child: Text(appLocalizations.ConfigServer!),
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: appLocalizations.Username!,
                  hintText: appLocalizations.Enteryourusername!,
                ),
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: appLocalizations.Password!,
                  hintText: appLocalizations.Enteryourpassword!,
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => login(context),
                child: Text(appLocalizations.Login!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
