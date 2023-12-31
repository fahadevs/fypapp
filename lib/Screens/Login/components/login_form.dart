import 'package:flutter/material.dart';
import 'package:fypapp/main.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Signup/signup_screen.dart';
import '../../Appliance//addAppliances.dart';
import '../../Appliance/appliancedata.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String loginStatus = '';
  late AuthProvider authProviderInstance; // Declare as late
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      authProviderInstance = Provider.of<AuthProvider>(context, listen: false);
    });}
  void login(String email, String password) async {
    try {
      Response response = await post(
        Uri.parse('http://$apiAddress:8000/api/login'),
        body: {
          'email': email,
          'password': password,
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
          var user_id=result['user_id'];
          authProviderInstance.setAuthData(token, user_id);
          print('Token: $token');
          print('Name: $name');
          print('user Id: $user_id');
          print(message);

          // Set the login status message for successful login
          setState(() {
            loginStatus = 'Login successful';
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ApplianceScreen(token: token,user_Id:user_id.toString()); // Pass the token to the constructor
              },
            ),
          );

        } else {
          print('Login failed: $message');

          // Set the login status message for failed login
          setState(() {
            loginStatus = 'Login failed: $message';
          });
        }
      } else {
        print('Login failed');

        // Set the login status message for failed login
        setState(() {
          loginStatus = 'Invalid Login or Password';
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
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void changeText(String result) {
    setState(() {
      loginStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom + 16.0,
          ),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  onSaved: (email) {},
                  decoration: InputDecoration(
                    hintText: "Your email",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: TextFormField(
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Your password",
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
                    color: loginStatus.contains('Invalid Login or Password')
                        ? Colors.red
                        : Colors.green,
                  ),),
                const SizedBox(height: defaultPadding),
                Hero(
                  tag: "login_btn",
                  child: ElevatedButton(
                    onPressed: () {
                      login(
                        emailController.text.toString(),
                        passwordController.text.toString(),
                      );
                      changeText(loginStatus);
                    },
                    child: Text(
                      "Login".toUpperCase(),
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),

                  ),

                ),
                // Display login status message

                const SizedBox(height: defaultPadding),
                AlreadyHaveAnAccountCheck(
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const SignUpScreen();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: defaultPadding),
              ],
            ),
          ),
        ),
      );
    }

  }