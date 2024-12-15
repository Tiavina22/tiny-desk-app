import 'package:flutter/material.dart';
import 'package:tiny_desk/screens/auth/login_screen.dart';
import 'package:tiny_desk/screens/auth/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Desktop App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
