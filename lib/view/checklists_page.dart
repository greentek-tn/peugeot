import 'dart:async';

import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:peugeot/view/loaded_checklist_wizard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistsPage extends StatefulWidget {
  ChecklistsPage({super.key});
  @override
  State<ChecklistsPage> createState() => _ChecklistsPageState();
}

String onename = '';
List<String> NameOfLine = [];
int? lineId;
List<String> Checklists_List = [];
List<String> Checklists_OF = [];

int LoadedChecklistId = 0;
List<int> Checklists_Listids = [];

class _ChecklistsPageState extends State<ChecklistsPage> {
  void initState() {
    super.initState();
    GetLineName();
    getChecklistLineIds();
  }

  Future<void> getChecklistLineIds() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);

    final Checklists = await orpc.callKw({
      'model': 'control.checklist',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['manufacture_line_id.id', '=', lineId]
        ],
        'fields': ['name', 'manufacturing_order_id'],
        'limit': 8000,
      },
    });

    setState(() {
      Checklists_OF = Checklists.map<String>(
          (record) => record['manufacturing_order_id'][1] as String).toList();
      Checklists_Listids =
          Checklists.map<int>((record) => record['id'] as int).toList();
      Checklists_List =
          Checklists.map<String>((record) => record['name'] as String).toList();
    });
    // print('$Checklists_OF');
  }

  Future<void> GetLineName() async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    lineId = prefs.getInt('lineId');

    final LineNames = await orpc.callKw({
      'model': 'control.manufacturing.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [
          ['id', '=', lineId]
        ],
        'fields': ['id', 'name'],
        'limit': 8000,
      },
    });

    setState(() {
      NameOfLine =
          LineNames.map<String>((record) => record['name'] as String).toList();
      onename = NameOfLine[0];
    });
    // print('name of Line is $LineNames');
  }

  Future<void> editCheckList(int LoadedcheckListId) async {
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist',
      'method': 'action_edit',
      'args': [LoadedcheckListId],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
    // print("Loaded Checklist with ID $LoadedcheckListId started successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checklists List"),
      ),
      body: Column(
        children: [
          if (onename.isEmpty)
            Center(child: CircularProgressIndicator())
          else
            SizedBox(height: 20),
          Text(
            'Listes des contrôle de la ligne : ${onename}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(height: 20),
          if (onename.isEmpty)
            Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: Checklists_List.length,
              itemBuilder: (context, index) {
                final LoadedCheckListName = Checklists_List[index];
                final LoadedcheckListId = Checklists_Listids[index];
                final OfName = Checklists_OF[index];
                if (onename.isEmpty)
                  Center(child: CircularProgressIndicator());
                else
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          editCheckList(LoadedcheckListId);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadedPage(
                                      checklistId: LoadedcheckListId)));
                        },
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.check_circle_rounded),
                            title: Text('$LoadedCheckListName | OF =  $OfName'),
                            trailing: IconButton(
                                icon: Icon(Icons.keyboard_arrow_right_rounded),
                                onPressed: () {
                                  editCheckList(LoadedcheckListId);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoadedPage(
                                              checklistId: LoadedcheckListId)));
                                }),
                          ),
                        ),
                      )
                    ],
                  );
              },
            ),
        ],
      ),
    );
  }
}
