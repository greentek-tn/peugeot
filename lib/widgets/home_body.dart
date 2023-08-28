import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import '../view/create_checklist.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/peugeot-bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 30,
                shadowColor: Colors.white,
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateChecklists(
                            onWillPop: () async {
                              return false;
                            },
                          )),
                );
              },
              child: Text(
                appLocalizations.StartButton!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
              ),
            ),

            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     elevation: 10,
            //     padding:
            //         EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => RecapPage()),
            //     );
            //   },
            //   child: Text(
            //     'test',
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
