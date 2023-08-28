import 'dart:async';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import '../view/home_page.dart';

class ConfigTablet extends StatefulWidget {
  const ConfigTablet(
      {Key? key, int? factoryId, int? lineId, int? workstationId})
      : super(key: key);

  @override
  _ConfigTabletState createState() => _ConfigTabletState();
}

class _ConfigTabletState extends State<ConfigTablet> {
  int currentStep = 0;
  List<List<dynamic>> optionsList = List.filled(4, []);
  List<bool> isStepFetched = List.filled(4, false);
  List<dynamic> selectedOptionsStep1 = [];
  List<dynamic> selectedOptionsStep2 = [];
  List<dynamic> selectedOptionsStep3 = [];

  Future<void> fetchDataForStep(int step) async {
    if (isStepFetched[step]) return;

    switch (step) {
      case 0:
        await getFactory();
        break;
      case 1:
        await getLine();
        break;
      case 2:
        await getWorkstation();
        break;
      default:
        break;
    }

    setState(() {
      isStepFetched[step] = true;
    });
  }

  Future<void> getFactory() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    final getFactoryData = await orpc.callKw({
      'model': 'control.factory',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [],
        'fields': ['id', 'name'],
        'limit': 8000,
      },
    });
    setState(() {
      optionsList[0] = getFactoryData;
      // print(selectedOptionsStep1);
    });
  }

  Future<void> getLine() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final getLineData = await orpc.callKw({
      'model': 'control.manufacturing.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['factory_id', '=', selectedOptionsStep1]
        ],
        'fields': ['id', 'name'],
        'limit': 8000,
      },
    });
    setState(() {
      optionsList[1] = getLineData;
    });
  }

  Future<void> getWorkstation() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    final getWorkstationData = await orpc.callKw({
      'model': 'control.workstation',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['manufacture_line_id', '=', selectedOptionsStep2],
          ['is_workstation_control', '=', 'true']
        ],
        'fields': ['id', 'name'],
        'limit': 8000,
      },
    });
    setState(() {
      optionsList[2] = getWorkstationData;
      // print(selectedOptionsStep3);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataForStep(0);
  }

  void goToNextStep() async {
    if (currentStep < 2) {
      if (getSelectedOptions(currentStep).isNotEmpty) {
        final selectedOption = getSelectedOptions(currentStep).first;
        setSelectedOption(currentStep, selectedOption);
        setState(() {
          currentStep++;
        });
        fetchDataForStep(currentStep);
      } else {
        showDialog(
          context: context,
          builder: (context) {
            final languageCode = LocalizedApp.of(context)?.languageCode;
            final appLocalizations = AppLocalizations.of(context, languageCode);

            return AlertDialog(
              title: Text(appLocalizations.Error!),
              content: Text(appLocalizations.configtabwizardWarning!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      final sharedPreferences = await SharedPreferences.getInstance();
      final factoryId = getSelectedOption(0);
      final lineId = getSelectedOption(1);
      final workstationId = getSelectedOption(2);

      if (factoryId != null && lineId != null && workstationId != null) {
        await sharedPreferences.setInt('factoryId', factoryId);
        await sharedPreferences.setInt('lineId', lineId);
        await sharedPreferences.setInt('workstationId', workstationId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            final languageCode = LocalizedApp.of(context)?.languageCode;
            final appLocalizations = AppLocalizations.of(context, languageCode);

            return AlertDialog(
              title: Text(appLocalizations.Error!),
              content: Text(appLocalizations.configtabwizardSavingWarning!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void goBack() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void goNext(dynamic selectedOption) {
    if (currentStep < 2) {
      setSelectedOption(currentStep, selectedOption);
      fetchDataForStep(currentStep + 1);
      goToNextStep();
    } else {
      setSelectedOption(currentStep, selectedOption);
    }
  }

  List<Widget> _buildOptions(int stepIndex) {
    final options = <Widget>[];

    for (int i = 0; i < optionsList[stepIndex].length; i++) {
      final option = optionsList[stepIndex][i];
      final value = option['id'];
      final label = option['name'];
      options.add(
        Card(
          elevation: 2,
          child: ListTile(
            onTap: () => goNext(value),
            leading: Radio(
              value: value,
              groupValue: getSelectedOption(stepIndex),
              onChanged: (selectedOption) {
                setState(() {
                  setSelectedOption(stepIndex, selectedOption);
                  goNext(selectedOption);
                });
              },
            ),
            title: Text(label),
          ),
        ),
      );
    }

    return options;
  }

  List<dynamic> getSelectedOptions(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return selectedOptionsStep1;
      case 1:
        return selectedOptionsStep2;
      case 2:
        return selectedOptionsStep3;
      default:
        return [];
    }
  }

  Widget _buildStepTitle(int stepIndex) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    switch (stepIndex) {
      case 0:
        return Text(appLocalizations.step1!);
      case 1:
        return Text(appLocalizations.step2!);
      case 2:
        return Text(appLocalizations.step3!);
      default:
        return SizedBox.shrink();
    }
  }

  dynamic getSelectedOption(int stepIndex) {
    final selectedOptions = getSelectedOptions(stepIndex);
    return selectedOptions.isNotEmpty ? selectedOptions[0] : null;
  }

  void setSelectedOption(int stepIndex, dynamic selectedOption) {
    final selectedOptions = getSelectedOptions(stepIndex);
    selectedOptions.clear();
    selectedOptions.add(selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.ConfigTablet!),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < 3; i++)
              Visibility(
                visible: currentStep == i,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appLocalizations.step!} ${i + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (optionsList[i].isEmpty)
                      Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: [
                          _buildStepTitle(i),
                          SizedBox(height: 8),
                          ..._buildOptions(i),
                        ],
                      ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goBack,
                  child: Text(appLocalizations.Back!),
                ),
                // ElevatedButton(
                // onPressed: goToNextStep,
                // child: Text('Next'),
                // ),
                if (currentStep == 2)
                  ElevatedButton(
                    onPressed: goToNextStep,
                    child: Text(appLocalizations.Save!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
