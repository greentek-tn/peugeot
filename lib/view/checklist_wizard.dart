import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import 'create_checklist.dart';

class OtherPage extends StatefulWidget {
  final int checklistId;

  OtherPage({Key? key, required this.checklistId}) : super(key: key);

  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  List<Zone> zones = [];
  List<dynamic> zonedata = [];
  Zone? selectedZone;
  String? selectedCheckpoint;

  @override
  void initState() {
    super.initState();
    getZones().then((_) {
      if (zones.isNotEmpty) {
        selectZone(zones.first);
      }
    });
  }

  void navigateToFirstZone() async {
    List<Zone> zones = getZones() as List<Zone>;

    if (zones.isNotEmpty) {
      Zone firstZone = zones.first;
      navigateToZone(firstZone);
    }
  }

  void navigateToZone(Zone zone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(
          initialZone: zone,
          checklistId: widget.checklistId,
          zones: zones,
        ),
      ),
    );
  }

  Future<void> getZones() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final zones = await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['checklist_id', '=', widget.checklistId]
        ],
        'fields': ['checkzone_id'],
        'limit': 8000,
      },
    });

    final uniqueZones = <int, dynamic>{};

    for (final zone in zones) {
      final zoneId = zone['checkzone_id'][0] as int;
      if (!uniqueZones.containsKey(zoneId)) {
        uniqueZones[zoneId] = zone;
      }
    }

    final checkZoneSequences = await orpc.callKw({
      'model': 'control.check.zone',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': ['sequence'],
      },
    });

    final sortedZones = uniqueZones.values.toList()
      ..sort((a, b) {
        final zoneIdA = a['checkzone_id'][0] as int;
        final zoneIdB = b['checkzone_id'][0] as int;
        final sequenceA = checkZoneSequences
            .firstWhere((zone) => zone['id'] == zoneIdA)['sequence'] as int;
        final sequenceB = checkZoneSequences
            .firstWhere((zone) => zone['id'] == zoneIdB)['sequence'] as int;
        return sequenceA.compareTo(sequenceB);
      });

    setState(() {
      this.zonedata = sortedZones;
      this.zones = List<Zone>.from(sortedZones.map((zoneData) => Zone(
            id: zoneData['checkzone_id'][0] as int,
            name: zoneData['checkzone_id'][1] as String,
          )));
    });
    print(zones);
  }

  void selectZone(Zone zone) {
    setState(() {
      selectedZone = zone;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(
          initialZone: zone,
          checklistId: widget.checklistId,
          zones: zones,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final languageCode = LocalizedApp.of(context)?.languageCode;
    // final appLocalizations = AppLocalizations.of(context, languageCode);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checklist Wizard'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}

class Workstation {
  final int id;
  final String name;

  Workstation(this.id, this.name);
}

class NextPage extends StatefulWidget {
  final Zone initialZone;
  final int checklistId;
  final List<Zone> zones;

  NextPage({
    required this.initialZone,
    required this.checklistId,
    required this.zones,
  });

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  int currentZoneIndex = 0;
  Map<int, bool> clickedMap = {};
  List<String> checkpointNames = [];
  List<int> checkpointIds = [];
  List<String> checkpointTypes = [];
  List<String> workstationsNames = [];
  List<dynamic> defaultworkstations = [];
  List<int> workstationsIds = [];
  Zone? currentZone;
  bool isResetVisible = false;
  bool allChecklinesDone = false;
  Map<dynamic, Color> checklineColors = {};
  Map<int, bool> showAdditionalButtons = {};
  Map<int, bool> resetMap = {};
  int dropdownValue = 1;
  List<int> invalidChecklineIds = [];
  List<String> invalidChecklineNames = [];
  Map<int, String> checkpointStates = {};

  @override
  void initState() {
    //  getChecklineState;
    super.initState();
    currentZone = widget.initialZone;
    getChecklistLineIds(currentZone!);
    for (int checkpointId in checkpointIds) {
      checklineColors[checkpointId] = Colors.white;
    }
  }

  Future<void> getChecklistLineIds(Zone zone) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final checklines = await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['checklist_id', '=', widget.checklistId],
          ['checkzone_id', '=', zone.id],
        ],
        'fields': [
          'checkpoint_id',
          'selection_field',
          'defaultworkstation_ids2',
          //   'state',
        ],
        'limit': 8000,
      },
    });

    setState(() {
      defaultworkstations = checklines
          .map<dynamic>((record) => record['defaultworkstation_ids2'] as List)
          .toList();
      checkpointTypes = checklines
          .map<String>((record) => record['selection_field'] as String)
          .toList();
      checkpointNames = checklines
          .map<String>((record) => record['checkpoint_id'][1] as String)
          .toList();
      checkpointIds =
          checklines.map<int>((record) => record['id'] as int).toList();
      allChecklinesDone = false;
      // for (final checkline in checklines) {
      //   final checkpointId = checkline['checkpoint_id'][0] as int;
      //   final state = checkline['state'] as String;
      //   checkpointStates[checkpointId] = state;
      // }
    });
  }

  // Future<void> getChecklineState(Zone zone) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? serverUrl = prefs.getString('serverUrl');
  //   String? database = prefs.getString('database');
  //   String? username = prefs.getString('username');
  //   String? password = prefs.getString('password');
  //   final orpc = OdooClient(serverUrl!);
  //   await orpc.authenticate(database!, username!, password!);

  //   final checklines = await orpc.callKw({
  //     'model': 'control.checklist.line',
  //     'method': 'search_read',
  //     'args': [],
  //     'kwargs': {
  //       'context': {'bin_size': true},
  //       'domain': [
  //         ['checklist_id', '=', widget.checklistId],
  //         ['checkzone_id', '=', zone.id],
  //       ],
  //       'fields': [
  //         'checkpoint_id',
  //         'state',
  //       ],
  //       'limit': 8000,
  //     },
  //   });

  //   setState(() {
  //     final Map<int, String> checkpointStates = {};

  //     for (final checkline in checklines) {
  //       final checkpointId = checkline['checkpoint_id'][0] as int;
  //       final state = checkline['state'] as String;
  //       checkpointStates[checkpointId] = state;

  //       if (state == 'valid') {
  //         checklineColors[checkpointId] = Colors.green;
  //       }
  //     }
  //   });
  // }

  int? lineId;
  Future<List<Workstation>> getWorkstations() async {
    List allIds = defaultworkstations.expand((list) => list).toList();

    final prefs = await SharedPreferences.getInstance();
    lineId = prefs.getInt('lineId');
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final workstations = await orpc.callKw({
      'model': 'control.workstation',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'fields': [
          'id',
          'name',
        ],
        'domain': [
          ['is_workstation_control', '=', false],
          //  ['manufacture_line_id', '=', lineId],
          ['id', 'in', allIds]
        ],
        'limit': 8000,
      },
    });

    return workstations.map<Workstation>((record) {
      final id = record['id'] as int;
      final name = record['name'] as String;
      return Workstation(id, name);
    }).toList();
  }

  Future<void> validAction(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_valid',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {
      clickedMap[checklineId] = true;
      allChecklinesDone = checkAllChecklinesDone();
      checklineColors[checklineId] = Colors.green;
    });
  }

  Future<void> invalidAction(int checklineId) async {
    final workstations = await getWorkstations();
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    Workstation? selectedWorkstation;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Real workstation'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<Workstation>(
                value: selectedWorkstation,
                onChanged: (Workstation? newValue) {
                  setState(() {
                    selectedWorkstation = newValue;
                  });
                },
                items: workstations.map<DropdownMenuItem<Workstation>>(
                  (Workstation workstation) {
                    return DropdownMenuItem<Workstation>(
                      value: workstation,
                      child: Text(workstation.name),
                    );
                  },
                ).toList(),
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (selectedWorkstation != null) {
                  // print('Selected ID: ${selectedWorkstation!.id}');
                  // print('Selected Name: ${selectedWorkstation!.name}');
                }
              },
            ),
          ],
        );
      },
    );

    if (selectedWorkstation != null) {
      await orpc.callKw({
        'model': 'control.checklist.line',
        'method': 'action_invalid',
        'args': [checklineId],
        'kwargs': {
          'context': {'bin_size': true},
        },
      });

      await orpc.callKw({
        'model': 'control.checklist.line',
        'method': 'write',
        'args': [
          checklineId,
          {'reel_workstation_id': selectedWorkstation!.id}
        ],
        'kwargs': {
          'context': {'bin_size': true},
        },
      });

      setState(() {
        clickedMap[checklineId] = true;
        allChecklinesDone = checkAllChecklinesDone();

        checklineColors[checklineId] = Colors.red;
        showAdditionalButtons[checklineId] = true;
        invalidChecklineIds.add(checklineId);
        invalidChecklineNames
            .add(checkpointNames[checkpointIds.indexOf(checklineId)]);
      });
    }
  }

  Future<void> cancelChecklist(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_cancel',
      'args': [widget.checklistId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {});
  }

  Future<void> resetAction(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_reset',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {
      clickedMap[checklineId] = false;
      allChecklinesDone = checkAllChecklinesDone();
      resetMap[checklineId] = false;
      allChecklinesDone = checkAllChecklinesDone();
      checklineColors[checklineId] = Colors.white;
      showAdditionalButtons[checklineId] = false;
    });
  }

  Future<void> retouched(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_retouched',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {
      clickedMap[checklineId] = true;
      allChecklinesDone = checkAllChecklinesDone();
      // resetMap[checklineId] = false;
      // allChecklinesDone = checkAllChecklinesDone();
      checklineColors[checklineId] = Colors.orange;
      showAdditionalButtons[checklineId] = false;
    });
  }

  Future<void> unretouched(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_un_retouched',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {
      clickedMap[checklineId] = true;
      allChecklinesDone = checkAllChecklinesDone();
      // resetMap[checklineId] = false;
      // allChecklinesDone = checkAllChecklinesDone();
      checklineColors[checklineId] = Colors.red;
      showAdditionalButtons[checklineId] = false;
    });
  }

  void navigateToResultPage() async {
    List<String> invalidChecklistNames =
        await getInvalidChecklistNames(invalidChecklineIds);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          invalidChecklineIds: invalidChecklineIds,
          invalidChecklistNames: invalidChecklistNames,
          checklistId: widget.checklistId,
        ),
      ),
    );
  }

  bool isValidationInProgress = false;

  Future<void> validateChecklist(int checklistId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    setState(() {
      isValidationInProgress = true;
    });

    final result = await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_validate',
      'args': [widget.checklistId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
    setState(() {
      isValidationInProgress = false;
    });

    // print("Checklist with ID ${widget.checklistId} validated successfully.");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChecklists(
          onWillPop: () async {
            return false;
          },
        ),
      ),
    );

    return result;
  }

  void onNext() {
    isButtonClicked = true;

    if (allChecklinesDone) {
      setState(() {
        currentZoneIndex++;
        currentZone = widget.zones[currentZoneIndex];
        getChecklistLineIds(currentZone!);
        isResetVisible = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Please check all checklines before moving to the next zone."),
        ),
      );
    }
  }

  void startTimer() {
    buttonTimer = Timer(Duration(seconds: 4), () {
      setState(() {
        isButtonClicked = false;
      });
    });
  }

  void onValidate() {
    if (allChecklinesDone) {
      validateChecklist(widget.checklistId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please check all checklines before Validate."),
        ),
      );
    }
  }

  bool checkAllChecklinesDone() {
    for (final checkpointId in checkpointIds) {
      if (clickedMap[checkpointId] == null || !clickedMap[checkpointId]!) {
        return false;
      }
    }
    return true;
  }

  void validAllAction() {
    for (final checkpointId in checkpointIds) {
      validAction(checkpointId);
    }
    setState(() {
      isValidAllClicked = true;
    });
  }

  bool isValidAllClicked = false;
  bool isButtonClicked = false;

  @override
  void dispose() {
    buttonTimer?.cancel();
    super.dispose();
  }

  Timer? buttonTimer;

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    final isLastStep = currentZoneIndex == widget.zones.length - 1;
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Checklist  - Zone :  ${currentZone!.name}'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                iconSize: 30,
                onPressed: () async {
                  final Random random = Random();
                  final int num1 = random.nextInt(10);
                  final int num2 = random.nextInt(10);
                  final int result = num1 + num2;
                  final TextEditingController resultController =
                      TextEditingController();

                  bool isVerified = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Column(
                          children: [
                            Text(
                                "Are you sure you want to cancel the checklist?"),
                            SizedBox(height: 16),
                            Text("$num1 + $num2 = ?"),
                            SizedBox(height: 8),
                            TextField(
                              controller: resultController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Enter the result",
                              ),
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text("Confirm"),
                            onPressed: () {
                              final enteredResult =
                                  int.tryParse(resultController.text) ?? 0;
                              final isCorrect = enteredResult == result;

                              if (isCorrect) {
                                Navigator.of(context).pop(true);
                              } else {}
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (isVerified) {
                    cancelChecklist(widget.checklistId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateChecklists(
                          onWillPop: () async {
                            return false;
                          },
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.cancel_outlined),
              )
              // IconButton(
              //   iconSize: 30,
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return AlertDialog(
              //           title: Text("Confirmation"),
              //           content: Text(
              //               "Are you sure you want to cancel the checklist?"),
              //           actions: <Widget>[
              //             TextButton(
              //               child: Text("Cancel"),
              //               onPressed: () {
              //                 Navigator.of(context).pop();
              //               },
              //             ),
              //             TextButton(
              //               child: Text("Confirm"),
              //               onPressed: () {
              //                 cancelChecklist(widget.checklistId);
              //                 Navigator.of(context).pop();

              //                 Navigator.push(
              //                   context,
              //                   MaterialPageRoute(
              //                     builder: (context) => CreateChecklists(
              //                       onWillPop: () async {
              //                         return false;
              //                       },
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //           ],
              //         );
              //       },
              //     );
              //   },
              //   icon: Icon(Icons.cancel_outlined),
              // )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: checkpointNames.length,
                  itemBuilder: (context, index) {
                    final checkpointName = checkpointNames[index];
                    final checkpointId = checkpointIds[index];
                    final checkpointType = checkpointTypes[index];
                    final bool isClicked = clickedMap[checkpointId] ?? false;
                    final bool isReset = resetMap[checkpointId] ?? false;
                    Color? checklineColor = checklineColors[checkpointId];
                    // final String checkpointState =
                    //     checkpointStates[checkpointId] ?? '';
                    // if (checkpointState == 'valid') {
                    //   checklineColor = Colors.green;
                    // }
                    return Card(
                      color: checklineColor,
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text('$checkpointName ')),
                            Text(' | '),
                            Text(
                              '$checkpointType',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(' | '),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isClicked && !isReset)
                              ElevatedButton(
                                onPressed: () => validAction(checkpointId),
                                child: Text(appLocalizations.ValidButton!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            if (isClicked || isReset)
                              ElevatedButton(
                                onPressed: () => resetAction(checkpointId),
                                child: Text(appLocalizations.ResetButton!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            if (!isClicked && !isReset) SizedBox(width: 8),
                            if (!isClicked && !isReset)
                              ElevatedButton(
                                onPressed: () => invalidAction(checkpointId),
                                child: Text(appLocalizations.inValidButton!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            SizedBox(
                              width: 10,
                            ),
                            if (showAdditionalButtons[checkpointId] ?? false)
                              ElevatedButton(
                                onPressed: () {
                                  retouched(checkpointId);
                                },
                                child: Text(appLocalizations.RetouchedButton!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            SizedBox(
                              width: 10,
                            ),
                            if (showAdditionalButtons[checkpointId] ?? false)
                              ElevatedButton(
                                onPressed: () {
                                  unretouched(checkpointId);
                                },
                                child:
                                    Text(appLocalizations.unRetouchedButton!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!isLastStep)
                    Visibility(
                      visible: allChecklinesDone && !isButtonClicked,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isButtonClicked = true;
                          });
                          onNext();
                          startTimer();
                        },
                        child: Text(
                          appLocalizations.NextButton!,
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary:
                              allChecklinesDone ? Colors.blue : Colors.grey,
                          onPrimary: Colors.white,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: validAllAction,
                    child: Text(
                      appLocalizations.ValidAllButton!,
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (isLastStep)
                    ElevatedButton(
                      onPressed: () {
                        navigateToResultPage();
                      },
                      child: Text(
                        appLocalizations.ResultButton!,
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            allChecklinesDone ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ));
  }
}

Future<List<String>> getInvalidChecklistNames(
    List<int> invalidChecklineIds) async {
  final prefs = await SharedPreferences.getInstance();
  String? serverUrl = prefs.getString('serverUrl');
  String? database = prefs.getString('database');
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  final orpc = OdooClient(serverUrl!);
  await orpc.authenticate(database!, username!, password!);

  final checklines = await orpc.callKw({
    'model': 'control.checklist.line',
    'method': 'search_read',
    'args': [],
    'kwargs': {
      'context': {'bin_size': true},
      'domain': [
        ['id', 'in', invalidChecklineIds],
      ],
      'fields': ['checkpoint_id'],
      'limit': 8000,
    },
  });

  return checklines.map<String>((record) {
    final checkpointName = record['checkpoint_id'][1] as String;
    return checkpointName;
  }).toList();
}

class ChecklineWidget extends StatelessWidget {
  final int checklineId;
  final bool isRetouched;
  final Function() onRetouched;
  final Function() onUnretouched;
  final Function() onValid;
  final Function() onInvalid;
  final String invCheckName;
  ChecklineWidget({
    required this.checklineId,
    required this.isRetouched,
    required this.onRetouched,
    required this.onUnretouched,
    required this.onValid,
    required this.onInvalid,
    required this.invCheckName,
  });
  Future<void> retouchedx(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_retouched',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
  }

  Future<void> unretouchedx(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'action_un_retouched',
      'args': [checklineId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    // final languageCode = LocalizedApp.of(context)?.languageCode;
    //  final appLocalizations = AppLocalizations.of(context, languageCode);

    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text('$invCheckName')),
          SizedBox(width: 8),
          SizedBox(width: 8),
          // isRetouched
          //     ? Container()
          //     : ElevatedButton(
          //         onPressed: () {
          //           onRetouched();
          //           retouchedx(checklineId);
          //         },
          //         child: Text('Retouched'),
          //       ),
        ],
      ),
      // onTap: () {
      //   retouchedx(checklineId);
      // },

      trailing: isRetouched
          ? SizedBox()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    onRetouched();
                    retouchedx(checklineId);
                  },
                  child: Text('Retouched'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 0, 0),
                  ),
                  onPressed: () {
                    onRetouched();
                    unretouchedx(checklineId);
                  },
                  child: Text('unRetouched'),
                ),
              ],
            ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final List<int> invalidChecklineIds;
  final List<String> invalidChecklistNames;
  final int checklistId;
  ResultPage({
    Key? key,
    required this.invalidChecklineIds,
    required this.invalidChecklistNames,
    required this.checklistId,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<bool> retouchedStatus = [];

  @override
  void initState() {
    super.initState();
    retouchedStatus =
        List<bool>.filled(widget.invalidChecklineIds.length, false);
  }

  void onRetouched(int index) {
    setState(() {
      retouchedStatus[index] = true;
    });
  }

  void onUnretouched(int index) {
    setState(() {
      retouchedStatus[index] = false;
    });
  }

  bool isAllRetouched() {
    return retouchedStatus.every((status) => status == true);
  }

  bool isValidationInProgress = false;
  Future<void> cancelChecklist(int checklineId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_cancel',
      'args': [widget.checklistId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    setState(() {});
  }

  Future<void> validateChecklist(int checklistId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    setState(() {
      isValidationInProgress = true;
    });

    final result = await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_validate',
      'args': [widget.checklistId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
    setState(() {
      isValidationInProgress = false;
    });

    // print("Checklist with ID ${widget.checklistId} validated successfully.");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChecklists(
          onWillPop: () async {
            return false;
          },
        ),
      ),
    );

    return result;
  }

  void onValidate() {
    if (isAllRetouched == true) {
      validateChecklist(widget.checklistId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please check all checklines before Validate."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Result'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.invalidChecklineIds.length,
              itemBuilder: (context, index) {
                int checklineId = widget.invalidChecklineIds[index];
                String invalidChecklistName =
                    widget.invalidChecklistNames[index];

                return ChecklineWidget(
                  checklineId: checklineId,
                  isRetouched: retouchedStatus[index],
                  onRetouched: () => onRetouched(index),
                  onUnretouched: () => onUnretouched(index),
                  onValid: () {},
                  onInvalid: () {},
                  invCheckName: invalidChecklistName,
                );
              },
            ),
          ),
          if (!isAllRetouched())
            ElevatedButton(
                onPressed: () {
                  //cancelChecklist(widget.checklistId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateChecklists(
                          onWillPop: () async {
                            return false;
                          },
                        ),
                      ));
                },
                child: Text("Cancel / Go to next Vehicle")),
          if (isAllRetouched())
            ElevatedButton(
              onPressed: () {
                validateChecklist(widget.checklistId);
              },
              child: Text('Validate'),
            ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// class ResultPage extends StatelessWidget {
//   final List<int> invalidChecklineIds;
//   final List<String> invalidChecklistNames;
//   final int checklistId;

//   ResultPage({
//     required this.invalidChecklineIds,
//     required this.invalidChecklistNames,
//     required this.checklistId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invalid Checklist Items'),
//       ),
//       body: ListView.builder(
//         itemCount: invalidChecklineIds.length,
//         itemBuilder: (context, index) {
//           int invalidChecklineId = invalidChecklineIds[index];
//           String invalidChecklistName = invalidChecklistNames[index];
//           return ListTile(
//             title: Text('ID: $invalidChecklineId'),
//             subtitle: Text('Name: $invalidChecklistName'),
//           );
//         },
//       ),
//     );
//   }
// }

class Zone {
  final int id;
  final String name;

  Zone({required this.id, required this.name});
}
