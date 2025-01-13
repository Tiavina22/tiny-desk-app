import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_desk/main.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';
import 'package:tiny_desk/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isDarkMode = true;
  String _searchQuery = ''; // State for search query
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _description;
  String _content = '';
  String _formSelectedType = 'Command';

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

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeMode');
    setState(() {
      _isDarkMode = themeIndex != null && themeIndex == 0;
    });
  }

  _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', value ? 0 : 1);
    setState(() {
      _isDarkMode = value;
    });
    runApp(MyApp(themeMode: value ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final db = await DatabaseService.instance.database;

      switch (_formSelectedType) {
        case 'Command':
          await db.insert('commands', {
            'title': _title,
            'description': _description,
            'command': _content,
            'user_id': _userInfo?['id'] ?? 1,
          });
          break;

        case 'Note':
          await db.insert('notes', {
            'title': _title,
            'description': _description,
            'note': _content,
            'user_id': _userInfo?['id'] ?? 1,
          });
          break;

        case 'Code':
          await db.insert('codes', {
            'title': _title,
            'description': _description,
            'code': _content,
            'user_id': _userInfo?['id'] ?? 1,
          });
          break;
      }

      // Réinitialiser le formulaire après la sauvegarde
      _formKey.currentState!.reset();
      setState(() {
        _formSelectedType = 'Command'; // Réinitialiser le type du formulaire
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donnée enregistrée avec succès!')),
      );

      Navigator.of(context).pop(); // Ferme le Dialog après l'enregistrement
    }
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final db = await DatabaseService.instance.database;

    // Récupérer toutes les entrées des trois tables
    List<Map<String, dynamic>> commands = await db.query('commands');
    List<Map<String, dynamic>> notes = await db.query('notes');
    List<Map<String, dynamic>> codes = await db.query('codes');

    // Combiner toutes les listes dans une seule
    List<Map<String, dynamic>> allItems = [];
    allItems.addAll(commands);
    allItems.addAll(notes);
    allItems.addAll(codes);

    // Filter items based on search query
    if (_searchQuery.isNotEmpty) {
      allItems = allItems.where((item) {
        return item['title']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (item['description'] != null &&
                item['description']!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return allItems;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: _isDarkMode
                  ? const Color.fromARGB(80, 41, 41, 41)
                  : Colors.grey[200],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.search,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery =
                            query; // Mettre à jour la requête de recherche
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Recherche...',
                      hintStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiny Desk'),
        actions: [
          // Dark Mode Switch
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: _buildSearchBar(),
        ),
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
      body: Column(
        children: [
          // Bouton pour ouvrir le formulaire d'ajout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showAddFormDialog(context);
              },
              child: Text('Ajouter une entrée'),
            ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune donnée disponible.'));
                }

                final items = snapshot.data!;

                // Calcul du nombre de colonnes en fonction de la largeur de l'écran
                double screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount = screenWidth > 1200
                    ? 10
                    : screenWidth > 800
                        ? 6
                        : 3;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MasonryGridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      String itemType = item.containsKey('command')
                          ? 'Command'
                          : item.containsKey('note')
                              ? 'Note'
                              : 'Code';
                      Color circleColor;
                      switch (itemType) {
                        case 'Command':
                          circleColor = Colors.red;
                          break;
                        case 'Note':
                          circleColor = Colors.green;
                          break;
                        case 'Code':
                          circleColor = Colors.yellow;
                          break;
                        default:
                          circleColor = Colors.grey;
                      }

                      return SizedBox(
                        width: 250, // Fixe la largeur à 150 pixels
                        child: Card(
                          margin: const EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize
                                  .min, // Hauteur minimale basée sur le contenu
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 6,
                                      backgroundColor: circleColor,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  item['description'] ?? 'Aucune description',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(
                                    height: 12.0), // Espacement avant l'icône
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher le Dialog
  void _showAddFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une entrée'),
          content: SizedBox(
              width: 500, // Fixe la largeur à 500 pixels
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Titre'),
                        onSaved: (value) => _title = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un titre'
                            : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onSaved: (value) => _description = value,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Contenu'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onSaved: (value) => _content = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un contenu'
                            : null,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _formSelectedType,
                        decoration: InputDecoration(labelText: 'Type'),
                        items: ['Command', 'Note', 'Code']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _formSelectedType = value!;
                        }),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              )),
          actions: [
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
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
