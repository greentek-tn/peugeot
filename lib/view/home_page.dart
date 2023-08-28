import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import '../widgets/home_body.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    if (appLocalizations == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(scaffoldKey: _scaffoldKey),
      appBar: AppBar(
        title: Text(appLocalizations.homePageTitle!),
      ),
      body: HomeBody(),
    );
  }
}
