import 'package:flutter/material.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'dart:convert';
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
  String loginStatus = '';
  Position? position;
  void register(String name, String email, String password, String c_password) async {
    try {
      Response response = await post(
        Uri.parse('localhost:8000/api/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'c_password' : c_password
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var success = data['success'];
        var result = data['data'];
        var message = data['message'];

        if (success) {
          var token = result['token'];
          var name = result['name'];
          print('Token: $token');
          print('Name: $name');
          print(message);

          // Set the login status message for successful login
          setState(() {
            loginStatus = 'Registration successful';
          });
        } else {
          print('Registration failed: $message');

          // Set the login status message for failed login
          setState(() {
            loginStatus = 'Registration failed: $message';
          });
        }
      } else {
        print('Login failed');

        // Set the login status message for failed login
        setState(() {
          loginStatus = 'Registration failed';
        });
      }
    } catch (e) {
      print('$e \nException occurred');

      // Set the login status message for errors
      setState(() {
        loginStatus = 'An error occurred during login';
      });
    }
  }
  void changeText(String result) {
    setState(() {
      loginStatus = result;
    });
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
            loginStatus,
            style: TextStyle(
              color: loginStatus.contains('Registration failed') ? Colors.red : Colors.green,
            ),),
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
                      _confirmPasswordController.text.toString()
                    );
                    changeText(loginStatus);
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
            child: Text("Sign Up".toUpperCase()),
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
