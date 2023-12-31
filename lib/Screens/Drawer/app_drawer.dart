import 'package:flutter/material.dart';
import 'package:fypapp/Screens/Login/components/login_form.dart';
import 'package:fypapp/Screens/Signup/components/signup_form.dart';
import 'package:fypapp/Screens/Appliance/addAppliances.dart';
import 'package:fypapp/Screens/Signup/signup_screen.dart';
import 'package:fypapp/constants.dart';
import 'package:fypapp/main.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  late AuthProvider authProviderInstance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: kPrimaryColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildDrawerItem(
                icon: Icons.person,
                title: 'User Information',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/userinfo');
                },
              ),
              buildDrawerItem(
                icon: Icons.add,
                title: 'Add Appliance',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/addappliance');
                },
              ),
              buildDrawerItem(
                icon: Icons.devices,
                title: 'My Appliances',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/showappliances');
                },
              ),
              buildDrawerItem(
                icon: Icons.schedule,
                title: 'Schedule',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/showschedule');
                },
              ),
              buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  // Use Provider to call the logout method
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  // Navigate to the login screen
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: Colors.white), // Add icon here
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        tileColor: kPrimaryColor,
      ),
    );
  }
}
