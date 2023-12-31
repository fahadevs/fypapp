import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fypapp/constants.dart';
import 'package:fypapp/Screens/Drawer/app_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
class UserProfileScreen extends StatefulWidget {
  final String token; // User authentication token
  final String userId; // User ID
  Position? position;
  UserProfileScreen({required this.token, required this.userId, Key? key})
      : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Map<String, dynamic> userData = {}; // Initialize with an empty map
  bool isLoading = true;
  String errorMessage = '';
  bool isEditingEmail = false;
  int user_id=0;
  bool isEditingCapacity = false;
  int? capacity;
  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      var response = await http.get(
        Uri.parse('http://$apiAddress:8000/api/user/${widget.userId}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData['success'] == true &&
            decodedData['data'] is Map<String, dynamic>) {
          Map<String, dynamic> userData =
          Map<String, dynamic>.from(decodedData['data']);

          setState(() {
            this.userData = userData;
            user_id=userData['id'];
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
          errorMessage = 'Error: ${response.statusCode}';
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
  Future<void> updateEmail(String newEmail) async {
    try {
      var response = await http.put(
        Uri.parse('http://$apiAddress:8000/api/user/${widget.userId}?email=$newEmail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Update the local user data with the new email
        setState(() {
          userData['email'] = newEmail;
        });
        // Toggle off email editing mode
        setState(() {
          isEditingEmail = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error occurred during data updating';
      });
      print('$e \nException occurred during data updating');
    }
  }

  Future<void> _saveUserLocation(String token) async {
    try {
      if (user_id != null) {
        setState(() {
          isLoading = true;
        });

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        String apiUrl =
            'http://$apiAddress:8000/api/user/$user_id?latitude=${position.latitude}&longitude=${position.longitude}';

        Response locationResponse = await http.put(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (locationResponse.statusCode == 200) {
          var locationData = jsonDecode(locationResponse.body);
          var success = locationData['success'];
          var message = locationData['message'];

          if (success) {
            print('User location saved successfully: $message');

          } else {
            print('Failed to save user location');
            // Show a SnackBar notifying the user about the failure
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to save user location'),
            ));


          }
        } else {
          print('Failed to save user location');
          // Show a SnackBar notifying the user about the failure
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save user location'),
          ));


        }
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error saving user location: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> updateCapacity(int newCapacity) async {
    if (newCapacity < 0 || newCapacity > 5) {
      // Validate capacity
      setState(() {
        errorMessage = 'Capacity should be between 0 and 5';
      });
      return;
    }

    try {
      var response = await http.put(
        Uri.parse(
            'http://$apiAddress:8000/api/user/${widget.userId}?capacity=$newCapacity'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Update the local user data with the new capacity
        setState(() {
          userData['capacity'] = newCapacity;
        });
        // Toggle off capacity editing mode
        setState(() {
          isEditingCapacity = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error occurred during data updating';
      });
      print('$e \nException occurred during data updating');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${userData['name']}'),
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
            style: TextStyle(color: Colors.red),
          ),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Unique Code: ',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${userData['check']}',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 22,
                  ),

                ),

                SizedBox(width: 8.0),
              ],
            ),
            Row(
              children: [

                Text(
                  'Email: ${userData['email']}',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.edit, color: kPrimaryColor),
                  onPressed: () {
                    setState(() {
                      isEditingEmail = !isEditingEmail;
                    });
                  },
                ),
              ],
            ),
            if (isEditingEmail)
              TextField(
                controller: TextEditingController(text: userData['email']),
                onChanged: (newValue) {
                  setState(() {
                    userData['email'] = newValue;
                  });
                },
              ),
            if (isEditingEmail)
                ElevatedButton(
                  onPressed: () {
                    if (isEditingEmail) {
                      updateEmail(userData['email']);
                    }
                  },
                  child: Text('Update Email'),
                ),
            if (userData['capacity']!=null)
            Row(
              children: [

                Text(
                  'Solar Capacity: ${userData['capacity']}',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.edit, color: kPrimaryColor),
                  onPressed: () {
                    setState(() {
                      isEditingCapacity = !isEditingCapacity;
                    });
                  },
                ),
              ],
            ),
            if (isEditingCapacity)
              TextField(
                controller: TextEditingController(text: userData['capacity']),
                onChanged: (newValue) {
                  setState(() {
                    userData['capacity'] = newValue;
                  });
                },
              ),
            if (isEditingCapacity)
              ElevatedButton(
                onPressed: () {
                  if (isEditingCapacity) {
                    updateCapacity(userData['capacity']);
                  }
                },
                child: Text('Update Capacity'),
              ),
            SizedBox(height: 16.0),
            if (userData['latitude'] != null &&
                userData['longitude'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _saveUserLocation(widget.token);
                    },
                    child: Text('Update Location'),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveUserLocation(widget.token);
                    },
                    child: Text('Add Location'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}