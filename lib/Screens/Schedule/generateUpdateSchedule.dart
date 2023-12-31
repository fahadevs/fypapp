import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fypapp/constants.dart';
import 'package:fypapp/Screens/Drawer/app_drawer.dart';

class ScheduleScreen extends StatefulWidget {
  final String token;
  final int user_Id;

  ScheduleScreen({
    required this.token,
    required this.user_Id,
    Key? key,
  }) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> appliances = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    fetchAppliances();
  }

  Future<void> fetchSchedules() async {
    try {
      var response = await http.get(
        Uri.parse('http://$apiAddress:8000/api/schedulings/${widget.user_Id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData['success'] == true &&
            decodedData['data'] is List<dynamic>) {
          List<dynamic> scheduleData = decodedData['data'];

          setState(() {
            schedules = List<Map<String, dynamic>>.from(scheduleData);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = decodedData['message'] ?? 'Unexpected data format';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No schedules found. If appliances are added,'
              ' schedules will show here tomorrow';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error occurred during data fetching';
      });
      print('$e \nException occurred during data fetching');
    }
  }

  Future<void> fetchAppliances() async {
    try {
      var response = await http.get(
        Uri.parse('http://$apiAddress:8000/api/appliance/${widget.user_Id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData['success'] == true &&
            decodedData['data'] is List<dynamic>) {
          List<dynamic> appliancesData = decodedData['data'];
          setState(() {
            appliances = List<Map<String, dynamic>>.from(appliancesData);
          });
        } else {
          print('Appliance fetching error: ${decodedData['message']}');
        }
      } else {
        print('Error fetching appliances: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred during appliance fetching: $e');
    }
  }

  String getFormattedTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  String getApplianceName(int applianceId) {
    var appliance = appliances.firstWhere((element) => element['id'] == applianceId, orElse: () => {});
    return appliance['a_name'] ?? 'Unknown Appliance';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appliances Schedule'),
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
          padding: EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      )
          : schedules.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No schedules generated yet.'),
            ElevatedButton(
              onPressed: () {
                // Implement the logic to generate a schedule
                // and then call fetchSchedules() to refresh the screen
              },
              child: Text('Generate Schedule'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => kPrimaryColor),
          dataRowColor: MaterialStateColor.resolveWith(
                  (states) => kPrimaryWhite),
          headingTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          columnSpacing: 10.0,
          columns: [
            DataColumn(label: Text('Appliance Name')),
            DataColumn(label: Text('Start Time')),
            DataColumn(label: Text('End Time')),
            DataColumn(label: Text('Day')),
          ],
          rows: schedules
              .map<DataRow>(
                (schedule) => DataRow(
              cells: [
                DataCell(
                  Text(
                    getApplianceName(schedule['appliance_id']),
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
                DataCell(
                  Text(
                    schedule['start_time'],
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
                DataCell(
                  Text(
                    schedule['end_time'],
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
                DataCell(
                  Text(
                    schedule['date'],
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
