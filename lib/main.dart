import 'package:flutter/material.dart';
import 'package:tiny_desk/screens/auth/signup_screen.dart';
import 'package:tiny_desk/screens/code/code_screen.dart';
import 'package:tiny_desk/screens/command/command_screen.dart';
import 'package:tiny_desk/screens/note/note_screen.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (DatabaseService.instance.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseService.instance.database; 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: _authService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/commands': (context) => CommandScreen(),
        '/home': (context) => HomeScreen(),
        '/notes': (context) => NoteScreen(),
        '/codes': (context) => CodeScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
