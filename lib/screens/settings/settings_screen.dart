import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_desk/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Mode Sombre'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              _saveTheme(value); // Sauvegarde le choix du thème
            },
          ),
          const SizedBox(height: 20), // Espacement entre les éléments
          // Section des cartes d'information
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
              children: [
                Text(
                  'Légende des couleurs :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoCard(
                        color: const Color.fromARGB(255, 134, 41, 34),
                        icon: Icons.terminal,
                        title: 'Commandes',
                        description: 'Représentées en rouge',
                      ),
                      const SizedBox(width: 10),
                      _buildInfoCard(
                        color: const Color.fromARGB(255, 39, 105, 41),
                        icon: Icons.note,
                        title: 'Notes',
                        description: 'Représentées en vert',
                      ),
                      const SizedBox(width: 10),
                      _buildInfoCard(
                        color: const Color.fromARGB(255, 158, 146, 39),
                        icon: Icons.code,
                        title: 'Code',
                        description: 'Représenté en jaune',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        // Ajouter une interaction si nécessaire
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150, // Largeur fixe pour les cartes
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}