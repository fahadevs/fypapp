import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fypapp/main.dart';
import '../../../constants.dart';
import 'package:fypapp/Screens/Drawer/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';


class UserInputForm extends StatefulWidget {
  @override
  _UserInputFormState createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textField1Controller = TextEditingController();
  TextEditingController textField2Controller = TextEditingController();
  TextEditingController textField3Controller = TextEditingController();
  bool isLoading = false;
  String? successMessage;
  String? errorMessage;
  String textField1Value = '';
  String textField2Value = '';
  String textField3Value = '';
  Timer? _successMessageTimer;


  @override
  void dispose() {
    textField1Controller.dispose();
    textField2Controller.dispose();
    textField3Controller.dispose();
    super.dispose();
    _clearTimers();
  }
  void _clearTimers() {
    _successMessageTimer?.cancel();
  }
  String? _validateWattage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }

    final number = int.tryParse(value);
    if (number == null || number < 1 || number > 3500) {
      return 'Value must be between 1 and 3500';
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
    if (number % 15 != 0) {
      return 'Value must be in multiple of 15-min e.g, 15,30,45,60';
    }

    return null;
  }

  Future<void> _submitForm() async {
    setState(() {
      isLoading = true;
      successMessage = null;
      errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      // Form is valid, perform further actions
      print('Form is valid!');
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      try {
        final response = await sendFormDataToApi(
          token.toString(),
          textField1Controller.text,
          textField2Controller.text,
          textField3Controller.text,
        );
        if (response.statusCode == 200) {

          print('Data sent successfully');
          setState(() {
            successMessage = 'Appliance added successfully';
          });
          // Automatically clear the success message after 10 seconds
          _successMessageTimer = Timer(Duration(seconds: 10), () {
            setState(() {
              successMessage = null;
            });
          });
          // Navigate to ApplianceScreen after successful addition
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/showappliances');
        } else {
          print('Failed to send data. Error: ${response.statusCode}');
          setState(() {
            errorMessage = 'Failed to send data. Error: ${response.statusCode}';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          errorMessage = 'Error: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Future<http.Response> sendFormDataToApi(
      String token,
      String name,
      String wattage,
      String consumption,
      ) async {
    // Replace the URL with your REST API endpoint
    final url = 'http://$apiAddress:8000/api/appliance';

    final body = {
      'a_name': name,
      'a_watt': wattage,
      'a_consumption': consumption,
      'a_status': 'off',
      'a_IP': '0',
      'a_MAC': '0',
    };

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      return response;
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to send data. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appliances'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
      ),
      drawer: Container(
        width: 200,
        child: AppDrawer(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: textField1Controller,
                      decoration:
                      InputDecoration(labelText: 'Enter Appliance Name'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: textField2Controller,
                      decoration:
                      InputDecoration(labelText: 'Enter Wattage 1-3500W'),
                      keyboardType: TextInputType.number,
                      validator: _validateWattage,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: textField3Controller,
                      decoration: InputDecoration(
                          labelText:
                          'Enter Appliance consumption/day in\n15-min  interval'),
                      keyboardType: TextInputType.number,
                      validator: _validateConsumption,
                    ),
                  ),
                  if (successMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Add Appliance'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
