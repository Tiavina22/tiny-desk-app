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
import 'screens/loading/loading_screen.dart'; // Importez l'écran de chargement

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Récupérer le thème préféré de l'utilisateur
  final themeMode = await _getThemeMode();

  // Afficher l'écran de chargement immédiatement avec le thème approprié
  runApp(MaterialApp(
    home: LoadingScreen(themeMode: themeMode),
    debugShowCheckedModeBanner: false,
  ));

  // Effectuer les tâches asynchrones en arrière-plan
  await _initializeApp();

  // Une fois les tâches terminées, rediriger vers l'application principale
  runApp(MyApp(themeMode: themeMode));
}

// Fonction pour initialiser l'application
Future<void> _initializeApp() async {
  if (DatabaseService.instance.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseService.instance.database;
}

// Fonction pour récupérer le thème préféré de l'utilisateur
Future<ThemeMode> _getThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final themeModeIndex = prefs.getInt('themeMode') ?? 0; // 0 = Dark, 1 = Light
  return themeModeIndex == 0 ? ThemeMode.dark : ThemeMode.light;
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
            return LoadingScreen(themeMode: themeMode); // Afficher l'écran de chargement avec le thème
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