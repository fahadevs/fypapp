import 'package:flutter/material.dart';
import 'editAppliance.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import 'package:fypapp/Screens/Drawer/app_drawer.dart';
import 'appliance.dart';

class ApplianceScreen extends StatefulWidget {
  final String token;
  final String user_Id; // New parameter

  ApplianceScreen({
    required this.token,
    required this.user_Id, // Add the new parameter
    Key? key,
  }) : super(key: key);

  @override
  _ApplianceScreenState createState() => _ApplianceScreenState();
}

class _ApplianceScreenState extends State<ApplianceScreen> {
  List<Appliance> applianceData = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchApplianceData() async {
    try {
      print('widget token: ${widget.token}');
      print('userId widget: ${widget.user_Id}');


      var response = await http.get(
        Uri.parse(
            'http://$apiAddress:8000/api/appliance/${widget.user_Id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        // Check if 'success' is true and 'data' is a List
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<Map<String, dynamic>> rawData =
              List<Map<String, dynamic>>.from(decodedData['data']);

          setState(() {
            if (rawData.isEmpty) {
              // If the list is empty, show a message to add appliances
              showAddAppliancesMessage();
            } else {
              // If the list is not empty, map the raw data to Appliance instances
              applianceData =
                  rawData.map((data) => Appliance.fromJson(data)).toList();
              isLoading = false;
            }
          });
        } else {
          // Handle unexpected data format or error message
          setState(() {
            isLoading = false;
            errorMessage = decodedData['message'] ?? 'Unexpected data format';
          });
        }
      } else {
        // Handle errors
        setState(() {
          isLoading = false;
          errorMessage = 'No Appliances found, add appliances first';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred during data fetching';
      });
      print('$e \nException occurred during data fetching');
    }
  }

  void showAddAppliancesMessage() {
    setState(() {
      isLoading = false;
      errorMessage =
          'You have not added any appliances. Please add appliances first.';
    });
  }
  Future<void> deleteAppliance(int applianceId) async {
    try {
      var response = await http.delete(
        Uri.parse('http://$apiAddress:8000/api/appliance/$applianceId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Appliance deleted successfully
        // Refresh the appliance list after deletion
        fetchApplianceData();
      } else {
        // Handle errors
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      setState(() {
        errorMessage = 'Error occurred during deletion';
      });
      print('$e \nException occurred during deletion');
    }
  }
  @override
  void initState() {
    super.initState();
    // Fetch appliance data when the screen is initialized
    fetchApplianceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appliance Data'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
      ),
      drawer: Container(
        width: 200,
        child: AppDrawer(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Text(
            errorMessage,
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      )
          : applianceData.isEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Text(
            'No data found',
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      )
          : ListView.builder(
        itemCount: applianceData.length,
        itemBuilder: (context, index) {
          Appliance appliance = applianceData[index];
          return Card(
            margin: EdgeInsets.all(defaultPadding),
            child: InkWell(
              onTap: () {
              },
              splashColor: kPrimaryColor.withOpacity(0.4), // Customize the ripple effect color and opacity
              child: ListTile(
              title: Text(
                appliance.name,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20.0, // Adjust the font size for the appliance name
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wattage: ${appliance.wattage}W',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Consumption: ${appliance.consumption}min',
                    style: TextStyle(color: Colors.black),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'Status: '),
                        TextSpan(
                          text: '${appliance.status.toUpperCase()}',
                          style: TextStyle(
                            color: appliance.status.toLowerCase() == 'on' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,color: kPrimaryColor),
                    onPressed: () {
                      // Navigate to the EditAppliance screen with appliance data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAppliance(
                            applianceId: appliance.id,  // Pass the applianceId
                            applianceName: appliance.name,
                            applianceWattage: appliance.wattage,
                            applianceConsumption: appliance.consumption,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,color: kPrimaryColor),
                    onPressed: () {
                      // Show a confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion',
                              style: TextStyle(
                                color: kPrimaryColor,
                              ),),
                            content: Text('Are you sure you want to delete this appliance?'),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text('Cancel',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                  ),),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Close the dialog and delete the appliance
                                  Navigator.pop(context);
                                  deleteAppliance(appliance.id);
                                },
                                child: Text('Delete',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                  ),),
                              ),
                            ],
                          );
                        },
                      );
                    },

                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
