import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Future<void> UploadImage() async {
    List<int> imageBytes = await _pickedImage!.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');
    String? database = prefs.getString('database');
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    final orpc = OdooClient(serverUrl!);
    await orpc.authenticate(database!, username!, password!);
    await orpc.callKw({
      'model': 'control.checklist.line',
      'method': 'write',
      'args': [
        1431,
        {'image_defaut': base64Image}
      ],
      'kwargs': {
        'context': {'bin_size': true},
      },
    });
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload to Odoo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pickedImage != null) Image.file(File(_pickedImage!.path)),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              ElevatedButton(
                onPressed: () {
                  UploadImage();
                },
                child: Text('Upload Image to Odoo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: ImageUploadScreen(),
    ));
