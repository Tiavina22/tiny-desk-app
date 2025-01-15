import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final ThemeMode themeMode;

  const LoadingScreen({Key? key, required this.themeMode}) : super(key: key);

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