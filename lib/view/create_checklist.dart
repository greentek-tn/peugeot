import 'dart:async';
import 'package:peugeot/i18n/app_localizations.dart';
import '../i18n/language_config.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checklist_wizard.dart';

class CreateChecklists extends StatefulWidget {
  const CreateChecklists({Key? key, required Future<bool> Function() onWillPop})
      : super(key: key);

  @override
  _CreateChecklistsState createState() => _CreateChecklistsState();
}

class _CreateChecklistsState extends State<CreateChecklists> {
  final TextEditingController _textEditingController = TextEditingController();
  String barcodeResult = '';
  int? fabOrderId;
  List<dynamic> fabricationOrders = [];

  int? factoryId;
  int? lineId;
  int? workstationId;

  @override
  void initState() {
    super.initState();
    retrieveSavedData();
    // Timer(Duration(milliseconds: 100), () {
    //   scanBarcode();
    // });
  }

  bool isChecklistCreated = false;
  int createdChecklistId = 0;
  String? username;
  String? password;

  Future<int> createChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    factoryId = prefs.getInt('factoryId');
    lineId = prefs.getInt('lineId');
    workstationId = prefs.getInt('workstationId');

    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    final createChecklistResponse = await orpc.callKw({
      'model': 'control.checklist',
      'method': 'create',
      'args': [
        {
          'factory_id': factoryId,
          'manufacture_line_id': lineId,
          'workstation_id': workstationId,
          'manufacturing_order_id': fabOrderId
        }
      ],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });

    final checklistId = createChecklistResponse as int;
    // print("Created Checklist ID: $checklistId");
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isChecklistCreated = true;
      createdChecklistId = checklistId;
    });

    return checklistId;
  }

  Future<void> retrieveSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    factoryId = prefs.getInt('factoryId');
    lineId = prefs.getInt('lineId');
    workstationId = prefs.getInt('workstationId');
  }

  Future<void> scanBarcode() async {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff0000',
        appLocalizations.Cancel!,
        true,
        ScanMode.BARCODE,
      );
      setState(() {
        barcodeResult = barcode;
        _textEditingController.text = barcode;
      });

      fabOrderId = await getFabOrderId(barcodeResult);
      if (fabOrderId != null) {
        getFabOrderDetails(fabOrderId!);
      } else {
        setState(() {
          fabricationOrders = [];
        });
      }
    } catch (e) {
      setState(() {
        barcodeResult = '${appLocalizations.Error!} : $e';
      });
    }
  }

  Future<int?> getFabOrderId(String scannedCode) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final getFabricationOrders = await orpc.callKw({
      'model': 'control.manufacturing.order',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['name', '=', scannedCode]
        ],
        'fields': ['id'],
      },
    });

    if (getFabricationOrders.isNotEmpty) {
      return getFabricationOrders[0]['id'];
    }

    return null;
  }

  Future<void> getFabOrderDetails(int fabOrderId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final fabOrderDetails = await orpc.callKw({
      'model': 'control.manufacturing.order',
      'method': 'read',
      'args': [fabOrderId],
      'kwargs': {
        'fields': [
          'name',
          'vin',
          'lot_id',
          'model_id',
          'color_id',
          'color',
          'version_id',
          'under_exemption',
          'derogation_id'
        ],
      },
    });

    setState(() {
      fabricationOrders = fabOrderDetails;
      // print(fabOrderDetails);
    });
  }

  Future<void> StartChecklist(int checklistId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_start',
      'args': [checklistId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
    // print("Checklist with ID $checklistId started successfully.");

    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OtherPage(checklistId: createdChecklistId)));
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizedApp.of(context)?.languageCode;
    final appLocalizations = AppLocalizations.of(context, languageCode);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appLocalizations.ScanOF!),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                },
                icon: Icon(Icons.home),
                iconSize: 35,
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appLocalizations.NumeroOF!,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        barcodeResult,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      labelText: appLocalizations.OF!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: 450,
                            child: ElevatedButton(
                              onPressed: scanBarcode,
                              child: Text(
                                appLocalizations.ScanOF!,
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            height: 80,
                            width: 450,
                            child: ElevatedButton(
                              onPressed: () async {
                                fabOrderId = await getFabOrderId(
                                    _textEditingController.text);
                                if (fabOrderId != null) {
                                  getFabOrderDetails(fabOrderId!);
                                } else {
                                  setState(() {
                                    fabricationOrders = [];
                                  });
                                }
                              },
                              child: Text('Search Fab Order',
                                  style: TextStyle(fontSize: 25)),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            height: 80,
                            width: 450,
                            child: ElevatedButton(
                              onPressed: () {
                                if (fabOrderId != null) {
                                  createChecklist();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      animation: CurvedAnimation(
                                        curve: Curves.linear,
                                        parent: kAlwaysCompleteAnimation,
                                      ),
                                      duration: Duration(seconds: 1),
                                      content: Text(appLocalizations
                                          .FabricationOrdernotfound!),
                                    ),
                                  );
                                }
                              },
                              child: Text(appLocalizations.CreateCheckList!,
                                  style: TextStyle(fontSize: 25)),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          if (isChecklistCreated)
                            Container(
                              height: 80,
                              width: 450,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isChecklistCreated) {
                                    StartChecklist(createdChecklistId);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(
                                              'Please create the checklist before starting it.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text(appLocalizations.StartButton!,
                                    style: TextStyle(fontSize: 25)),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      if (fabricationOrders.isNotEmpty)
                        Center(
                          child: Container(
                            // margin: EdgeInsets.symmetric(horizontal: 150),
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border:
                                    Border.all(width: 5, color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Column(
                              children: fabricationOrders.map((details) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Divider(
                                          height: 0,
                                          thickness: 5,
                                          indent: 20,
                                          endIndent: 0,
                                          color: Colors.black,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (details['under_exemption'] ==
                                                true)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.yellow),
                                                child: Row(
                                                  children: [
                                                    Text('Sous Dérogation : ',
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black)),
                                                    if (details[
                                                            'under_exemption'] ==
                                                        true)
                                                      Text(
                                                          details['derogation_id']
                                                              [1],
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black))
                                                    else
                                                      Text('')
                                                  ],
                                                ),
                                              )
                                            else
                                              Text('')
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                '${appLocalizations.ManifacturingOrder!} : ',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            Text(details['name'],
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                '${appLocalizations.CarColor!} : ',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            Text(details['color_id'][1],
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Vin : ',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            Text(details['vin'],
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text('Lot : ',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            Text(details['lot_id'][1],
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('${appLocalizations.CarModel!} : ',
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text(details['model_id'][1],
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Version : ',
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text(details['version_id'][1],
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      if (fabricationOrders.isEmpty && fabOrderId != null)
                        Text('Fab order : $fabOrderId : incorrect'),
                      if (fabOrderId == null)
                        Center(
                            child: Text(
                          appLocalizations.FabricationOrdernotfound!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
