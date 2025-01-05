import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tiny_desk/screens/auth/signup_screen.dart';
import 'package:tiny_desk/screens/code/code_screen.dart';
import 'package:tiny_desk/screens/command/command_screen.dart';
import 'package:tiny_desk/screens/note/note_screen.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (DatabaseService.instance.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseService.instance.database;

  // Récupérer le thème préféré de l'utilisateur
  final prefs = await SharedPreferences.getInstance();
  final themeModeIndex = prefs.getInt('themeMode') ?? 0; // 0 = Dark, 1 = Light
  final themeMode = themeModeIndex == 0 ? ThemeMode.dark : ThemeMode.light;


  runApp(MyApp(themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final AuthService _authService = AuthService();

  MyApp({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
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
