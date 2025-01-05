import 'package:flutter/material.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final userInfo = await UserService().getUserInfo();
    setState(() {
      _userInfo = userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiny Desk'),
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
                'email@example.com', // Ajoute l'email si disponible dans _userInfo
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
