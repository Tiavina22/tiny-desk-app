import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_desk/main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeMode');
    setState(() {
      _isDarkMode = themeIndex != null && themeIndex == 0;
    });
  }

  _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', value ? 0 : 1); // 0 pour sombre, 1 pour clair
    // Redémarrer l'application pour appliquer le nouveau thème
    if (value) {
      // Mode sombre
      runApp(MyApp(themeMode: ThemeMode.dark));
    } else {
      // Mode clair
      runApp(MyApp(themeMode: ThemeMode.light));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Mode Sombre'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              _saveTheme(value); // Sauvegarde le choix du thème
            },
          ),
        ],
      ),
    );
  }
}
