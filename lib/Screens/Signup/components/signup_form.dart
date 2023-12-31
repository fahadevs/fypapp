import 'package:flutter/material.dart';
import 'package:fypapp/Screens/Appliance/addAppliances.dart';
import 'package:fypapp/main.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../Appliance/appliancedata.dart';
class SignUpForm extends StatefulWidget {
const SignUpForm({
  Key? key,
}) : super(key: key);

@override
_SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
final _formKey = GlobalKey<FormState>();
TextEditingController _nameController = TextEditingController();
TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _confirmPasswordController = TextEditingController();
String registrationStatus = '';
Position? position;
int? userId;
String? token;// New variable to store user_id
bool isLoading = false;
late AuthProvider authProviderInstance; // Declare as late
void initState() {
  super.initState();
  Future.delayed(Duration.zero, () {
    authProviderInstance = Provider.of<AuthProvider>(context, listen: false);
  });}
void register(String name, String email, String password, String c_password) async {
  try {
    setState(() {
      isLoading = true;
      registrationStatus = 'Registering...';
    });

    Response response = await post(
      Uri.parse('http://$apiAddress:8000/api/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'c_password': c_password
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var success = data['success'];
      var result = data['data'];
      var message = data['message'];


      if (success) {
        token = result['token'];
        var name = result['name'];
        userId = result['user_id']; // Store the user_id
        print('User ID: $userId');
        print('Token: $token');
        print('Name: $name');
        print(message);

        _saveUserLocation(token as String);
        authProviderInstance.setAuthData(token as String, userId as int);

        setState(() {
          registrationStatus = 'Registration successful';
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ApplianceScreen(token: token as String,user_Id:userId.toString()); // Pass the token to the constructor
            },
          ),
        );


      } else {
        print('Registration failed: $message');
        setState(() {
          registrationStatus = 'Registration failed: $message';

        });

      }
    } else {
      print('Registration failed');
      setState(() {
        registrationStatus = 'Registration failed';
      });
    }
  } catch (e) {
    print('$e \nException occurred during registration');
    setState(() {
      registrationStatus = 'Registration failed: An error occurred';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

void changeText(String result) {
  setState(() {
    registrationStatus = result;
  });
}

Future<void> _saveUserLocation(String token) async {
  try {
    if (userId != null) {
      setState(() {
        isLoading = true;
        registrationStatus = 'Saving location...';
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String apiUrl =
          'http://$apiAddress:8000/api/user/$userId?latitude=${position.latitude}&longitude=${position.longitude}';

      Response locationResponse = await post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (locationResponse.statusCode == 200) {
        var locationData = jsonDecode(locationResponse.body);
        var success = locationData['success'];
        var message = locationData['message'];

        if (success) {
          print('User location saved successfully: $message');
          // Navigate to the form after successful location save
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return UserInputForm();
              },
            ),
          );
        } else {
          print('Failed to save user location');
          // Show a SnackBar notifying the user about the failure
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save user location'),
          ));

          // Delayed navigation to UserinputForm after 5 seconds
          Future.delayed(Duration(seconds: 5), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return UserInputForm();
                },
              ),
            );
          });
        }
      } else {
        print('Failed to save user location');
        // Show a SnackBar notifying the user about the failure
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save user location'),
        ));

        // Delayed navigation to UserinputForm after 5 seconds
        Future.delayed(Duration(seconds: 5), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return UserInputForm();
              },
            ),
          );
        });
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

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (name) {
              // Handle the name data when the form is saved.
            },
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Your name",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {
              // Handle the email data when the form is saved.
            },
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onSaved: (password) {
              // Handle the password data when the form is saved.
            },
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: "Your password",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onSaved: (confirmPassword) {
              // Handle the confirm password data when the form is saved.
            },
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              hintText: "Confirm password",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
        ),
        Text(
          registrationStatus,
          style: TextStyle(
            color: registrationStatus.contains('Registration failed')
                ? Colors.red
                : Colors.green,
          ),
        ),
        const SizedBox(height: defaultPadding / 2),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Password validation logic
              if (_passwordController.text == _confirmPasswordController.text) {
                // Passwords match, proceed with sign up.
                try {
                  register(
                    _nameController.text.toString(),
                    _emailController.text.toString(),
                    _passwordController.text.toString(),
                    _confirmPasswordController.text.toString(),
                  );
                  changeText(registrationStatus);
                } catch (e) {
                  print("exception thrown in try and catch");
                }
              } else {
                // Passwords don't match, display an error message.
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Passwords do not match'),
                ));
              }
            }
          },
          child: isLoading
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text("Sign Up".toUpperCase()),
        ),
        const SizedBox(height: defaultPadding),
        AlreadyHaveAnAccountCheck(
          login: false,
          press: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const LoginScreen();
                },
              ),
            );
          },
        ),











      ],
    ),
  );
}
}
