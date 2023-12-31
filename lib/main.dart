import 'package:flutter/material.dart';
import 'package:fypapp/Screens/Login/components/login_form.dart';
import 'package:fypapp/Screens/Login/login_screen.dart';
import 'package:fypapp/Screens/Appliance/addAppliances.dart';
import 'package:fypapp/Screens/Appliance/appliancedata.dart';
import 'package:fypapp/Screens/Schedule/generateUpdateSchedule.dart';
import 'package:fypapp/Screens/Signup/components/signup_form.dart';
import 'package:fypapp/Screens/Signup/signup_screen.dart';
import 'package:fypapp/constants.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:fypapp/Screens/UserInformation/userInformation.dart';
class AuthProvider extends ChangeNotifier {
  String? token;
  int? userId;

  void setAuthData(String newToken, int newUserId) {
    token = newToken;
    userId = newUserId;
    notifyListeners();
  }
  bool isAuthenticated() {
    // Check if both token and userId are not null
    return token != null && userId != null;
  }
  void logout() {
    token = null;
    userId = null;
    notifyListeners();
  }
}
void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MyApp(),
  ),
);
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/addappliance': (context) => UserInputForm(),
        '/login': (context) => LoginScreen(),
        '/showappliances': (context) {
    // Retrieve the token from the AuthProvider
          final authProvider = Provider.of<AuthProvider>(context);
          final String? token = authProvider.token;
          final int? userId = authProvider.userId;
    // Pass the token to the ApplianceScreen constructor
    return ApplianceScreen(token: token.toString(), user_Id: userId.toString());
    },
        '/userinfo': (context) {
    // Retrieve the token from the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final String? token = authProvider.token;
    final int? userId = authProvider.userId;
    // Pass the token to the ApplianceScreen constructor
    return UserProfileScreen(token: token.toString(), userId: userId.toString(),);
    },
        '/showschedule': (context) {
          // Retrieve the token from the AuthProvider
          final authProvider = Provider.of<AuthProvider>(context);
          final String? token = authProvider.token;
          final int? userId = authProvider.userId;
          // Pass the token to the ApplianceScreen constructor
          return ScheduleScreen(token: token.toString(), user_Id: userId as int,);
        },
    },
      debugShowCheckedModeBanner: false,
      title: 'Home Energy Management System',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: kPrimaryColor,
              foregroundColor: kPrimaryLightColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
      home: LoginScreen(),
    );
  }
}
