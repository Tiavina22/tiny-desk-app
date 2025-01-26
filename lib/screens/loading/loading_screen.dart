import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final ThemeMode themeMode;

  const LoadingScreen({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // Thème clair
      darkTheme: ThemeData.dark(), // Thème sombre
      themeMode: themeMode, // Applique le thème sélectionné
      home: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Indicateur de chargement
        ),
      ),
    );
  }
}