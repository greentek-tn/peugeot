import 'package:flutter/material.dart';
import '../conf_auth/config_page.dart';
import '../conf_auth/config_tablet.dart';
import '../conf_auth/login_page.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import '../view/checklists_page.dart';
import '../view/settings_page.dart';

class HomeDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  HomeDrawer({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    return Drawer(
      elevation: 20,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  padding: EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(top: 50, bottom: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.center,
                      scale: 0.5,
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Text(""),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(appLocalizations.Login!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  leading: Icon(Icons.login),
                ),
                ListTile(
                  title: Text(appLocalizations.ConfigTablet!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConfigTablet()),
                    );
                  },
                  leading: Icon(Icons.tablet_sharp),
                ),
                ListTile(
                  title: Text(appLocalizations.checklist!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChecklistsPage()),
                    );
                  },
                  leading: Icon(Icons.check_circle),
                ),
                Divider(),
                ListTile(
                  title: Text(appLocalizations.settingsPageTitle!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage(
                                onLanguageChanged: (Locale) {},
                              )),
                    );
                  },
                  leading: Icon(Icons.language),
                ),
                ListTile(
                  title: Text(appLocalizations.ConfigServer!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConfigPage()),
                    );
                  },
                  leading: Icon(Icons.settings_sharp),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(height: 50),
                GestureDetector(
                  // onTap: () async {
                  //   const url = 'https://warzeez.net';
                  //   if (await canLaunchUrl(url as Uri)) {
                  //     await launchUrl(url as Uri);
                  //   } else {
                  //     throw 'Could not launch $url';
                  //   }
                  // },
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            "Powered by:",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 0,
                        ),
                        Image.asset(
                          "assets/warzeez.png",
                          height: 30,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
