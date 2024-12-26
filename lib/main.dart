import 'package:flutter/material.dart';
import 'package:tiny_desk/screens/auth/login_screen.dart';
import 'package:tiny_desk/screens/auth/signup_screen.dart';
import 'package:tiny_desk/screens/home/home_screen.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';

void main() {
  runApp(MyApp());
}

Future<void> checkLoginStatus(BuildContext context) async {
  final token = await AuthService().getToken();
  print(token);
  if (token != null) {
    Navigator.pushReplacementNamed(
        context, '/home');
  } else {
    Navigator.pushReplacementNamed(
        context, '/'); 
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
        checkLoginStatus(context);
        return Container(); // Temporary widget while checking login status
          },
        );
      },
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen()
      },
    );
  }
}
