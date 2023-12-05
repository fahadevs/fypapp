import 'package:flutter/material.dart';
import '../../../constants.dart';

import 'package:http/http.dart' as http;
class UserInputForm extends StatefulWidget {
  @override
  _UserInputFormState createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textField1Controller = TextEditingController();
  TextEditingController textField2Controller = TextEditingController();
  TextEditingController textField3Controller = TextEditingController();
  TextEditingController textField4Controller = TextEditingController();
  TextEditingController textField5Controller = TextEditingController();
  TextEditingController textField6Controller = TextEditingController();

  String textField1Value = '';
  String textField2Value = '';
  String textField3Value = '';

  @override
  void dispose() {
    textField1Controller.dispose();
    textField2Controller.dispose();
    textField3Controller.dispose();
    super.dispose();
  }
  String? _validateWattage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    final number = int.tryParse(value);
    if (number == null || number < 1 || number > 3000) {
      return 'Value must be between 1 and 3000';
    }

    return null;
  }
  String? _validateConsumption(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    final number = int.tryParse(value);
    if (number == null || number < 0 || number > 1440) {
      return 'Value must be between 0 and 1440';
    }

    return null;
  }
  Future<void> _submitForm() async{
    if (_formKey.currentState!.validate()) {
      // Form is valid, perform further actions
      print('Form is valid!');
      final response = await sendFormDataToApi();
      if (response.statusCode == 200) {
        print('Data sent successfully');
        // Handle success response
      } else {
        print('Failed to send data. Error: ${response.statusCode}');
        // Handle error response
      }
    }
    setState(() {
      textField1Value = textField1Controller.text;
      textField2Value = textField2Controller.text;
      textField3Value = textField3Controller.text;
    });
  }
  Future<http.Response> sendFormDataToApi() {
    // Replace the URL with your REST API endpoint
    final url = Uri.parse('localhost:8000/api/appliance');
    final data = {
      'applianceName': textField1Value,
      'wattage': textField2Value,
      'consumption': textField3Value,
    };

    return http.post(url, body: data);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appliances'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
          key: _formKey,
          
          child:SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: textField1Controller,
                    decoration: InputDecoration(labelText: 'Enter Appliance Name'),
        
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: textField2Controller,
                    decoration: InputDecoration(labelText: 'Enter Wattage 0-3000W'),
                    keyboardType: TextInputType.number,
                    validator: _validateWattage,
                  ),
        
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: textField3Controller,
                    decoration: InputDecoration(labelText: 'Enter Appliance consumption/day in mins'),
                    keyboardType: TextInputType.number,
                    validator: _validateConsumption,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Device'),
                ),
                SizedBox(height: 16.0),
                Text('Text Field 1 Value: $textField1Value'),
                Text('Text Field 2 Value: $textField2Value'),
                Text('Text Field 3 Value: $textField3Value'),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
