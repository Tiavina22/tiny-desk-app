import 'package:flutter/material.dart';
import 'package:tiny_desk/main.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';
import 'package:tiny_desk/screens/settings/settings_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isDarkMode = true; // Valeur initiale (peut être modifiée selon la préférence de l'utilisateur)

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _loadTheme();
  }

  Future<void> _fetchUserInfo() async {
    final userInfo = await UserService().getUserInfo();
    setState(() {
      _userInfo = userInfo;
    });
  }

  // Charger le thème préféré de l'utilisateur
  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeMode');
    setState(() {
      _isDarkMode = themeIndex != null && themeIndex == 0;
    });
  }

  // Sauvegarder la préférence de thème
  _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', value ? 0 : 1); // 0 pour sombre, 1 pour clair
    // Appliquer immédiatement le changement de thème
    setState(() {
      _isDarkMode = value;
    });
    runApp(MyApp(themeMode: value ? ThemeMode.dark : ThemeMode.light));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiny Desk'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0), 
            child: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                _saveTheme(value);
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _userInfo?['username'] ?? 'Nom de l\'utilisateur',
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                'email@example.com',
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            _buildDrawerItem(
              context,
              'Commandes',
              Icons.terminal,
              () => Navigator.pushNamed(context, '/commands'),
            ),
            _buildDrawerItem(
              context,
              'Notes',
              Icons.note,
              () => Navigator.pushNamed(context, '/notes'),
            ),
            _buildDrawerItem(
              context,
              'Codes',
              Icons.code,
              () => Navigator.pushNamed(context, '/codes'),
            ),
            Divider(),
            _buildDrawerItem(
              context,
              'Paramètres',
              Icons.settings,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Se déconnecter'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          _userInfo != null
              ? 'Bienvenue, ${_userInfo!['username']}'
              : 'Chargement des données utilisateur...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
