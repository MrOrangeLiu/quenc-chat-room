import 'package:OrangeChat/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:OrangeChat/screens/welcome_screen.dart';
import 'package:OrangeChat/screens/login_screen.dart';
import 'package:OrangeChat/screens/registration_screen.dart';
import 'package:OrangeChat/screens/home_screen.dart';
import 'package:OrangeChat/screens/chat_screen.dart';

void main() => runApp(OrangeChat());

class OrangeChat extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
//        accentColor: Colors.orangeAccent,
        accentColor: Color(0xFFFEF9EB),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        SettingScreen.id: (context) => SettingScreen(),
      },
    );
  }
}
