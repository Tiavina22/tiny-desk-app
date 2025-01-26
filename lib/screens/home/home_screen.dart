import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_desk/main.dart';
import 'package:tiny_desk/screens/details/details_screen.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';
import 'package:tiny_desk/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware{
  Map<String, dynamic>? _userInfo;
  bool _isDarkMode = true;
  String _searchQuery = ''; // State for search query
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _description;
  String _content = '';
  String _formSelectedType = 'Command';

   // Nouvelle variable pour le filtre
  String _selectedFilter = 'All'; // 'All', 'Command', 'Note', 'Code'

   @override
  void didPopNext() {
    // Rafraîchir les données lorsque l'utilisateur revient à cet écran
    setState(() {});
  }

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
        const SnackBar(content: Text('Donnée enregistrée avec succès!')),
      );

      Navigator.of(context).pop(); // Ferme le Dialog après l'enregistrement
    }
  }

  /*
  Future<List<Map<String, dynamic>>> _fetchItems() async {
  final db = await DatabaseService.instance.database;

  // Récupérer les entrées des trois tables pour l'utilisateur connecté
  List<Map<String, dynamic>> commands = await db.query('commands', where: 'user_id = ?', whereArgs: [_userInfo?['id']]);
  List<Map<String, dynamic>> notes = await db.query('notes', where: 'user_id = ?', whereArgs: [_userInfo?['id']]);
  List<Map<String, dynamic>> codes = await db.query('codes', where: 'user_id = ?', whereArgs: [_userInfo?['id']]);

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
} */

Future<List<Map<String, dynamic>>> _fetchItems() async {
  final db = await DatabaseService.instance.database;

  List<Map<String, dynamic>> allItems = [];

  // Récupérer les éléments en fonction du filtre sélectionné
  if (_selectedFilter == 'All' || _selectedFilter == 'Command') {
    List<Map<String, dynamic>> commands = await db.query(
      'commands',
      where: 'user_id = ?',
      whereArgs: [_userInfo?['id']],
    );
    allItems.addAll(commands.map((item) => {...item, 'type': 'Command'}));
  }

  if (_selectedFilter == 'All' || _selectedFilter == 'Note') {
    List<Map<String, dynamic>> notes = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [_userInfo?['id']],
    );
    allItems.addAll(notes.map((item) => {...item, 'type': 'Note'}));
  }

  if (_selectedFilter == 'All' || _selectedFilter == 'Code') {
    List<Map<String, dynamic>> codes = await db.query(
      'codes',
      where: 'user_id = ?',
      whereArgs: [_userInfo?['id']],
    );
    allItems.addAll(codes.map((item) => {...item, 'type': 'Code'}));
  }

  // Filtrer les éléments en fonction de la recherche
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  Widget _buildFilterButton(String type) {
  IconData icon;
  Color activeColor;

  switch (type) {
    case 'All':
      icon = Icons.all_inclusive;
      activeColor = Colors.blue;
      break;
    case 'Command':
      icon = Icons.terminal;
      activeColor = Colors.red;
      break;
    case 'Note':
      icon = Icons.note;
      activeColor = Colors.green;
      break;
    case 'Code':
      icon = Icons.code;
      activeColor = Colors.orange;
      break;
    default:
      icon = Icons.all_inclusive;
      activeColor = Colors.blue;
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: FilterChip(
      label: Text(type),
      avatar: Icon(icon, size: 16),
      selected: _selectedFilter == type,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = type;
        });
      },
      selectedColor: activeColor,
      backgroundColor: Colors.grey[300],
      labelStyle: TextStyle(
        color: _selectedFilter == type ? Colors.white : Colors.black,
      ),
      checkmarkColor: Colors.white,
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Tiny Desk'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              _saveTheme(value);
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
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
              style: const TextStyle(color: Colors.white),
            ),
            accountEmail: const Text(
              'email@example.com',
              style: TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
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
          const Divider(),
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
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        // Boutons de filtre
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterButton('All'),
              _buildFilterButton('Command'),
              _buildFilterButton('Note'),
              _buildFilterButton('Code'),
            ],
          ),
        ),
        const Divider(),
        // Bouton pour ouvrir le formulaire d'ajout
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _showAddFormDialog(context);
            },
            child: const Text('Ajouter une entrée'),
          ),
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucune donnée disponible.'));
              }

              final items = snapshot.data!;

              // Calcul du nombre de colonnes en fonction de la largeur de l'écran
              double screenWidth = MediaQuery.of(context).size.width;
              int crossAxisCount = screenWidth > 1200
                  ? 6
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

                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(item: item),
                          ),
                        );

                        // Si des modifications ont été apportées, mettez à jour l'état
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      child: SizedBox(
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
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  item['description'] ??
                                      'Aucune description',
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteItem(item);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Supprimer la note'),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ],
                            ),
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
        title: const Text(
          'Ajouter une entrée',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SizedBox(
          width: 500, // Fixe la largeur à 500 pixels
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ Titre
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Titre',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    onSaved: (value) => _title = value!,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
                  ),
                  const SizedBox(height: 15),

                  // Champ Description
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Description (facultatif)',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    style: const TextStyle(fontSize: 16),
                    onSaved: (value) => _description = value,
                  ),
                  const SizedBox(height: 15),

                  // Champ Contenu
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Contenu',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(fontSize: 16),
                    onSaved: (value) => _content = value!,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Veuillez entrer un contenu' : null,
                  ),
                  const SizedBox(height: 20),

                  // Sélection du Type
                  DropdownButtonFormField<String>(
                    value: _formSelectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: _saveData,
            child: const Text('Enregistrer'),
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

  Future<void> _deleteItem(Map<String, dynamic> item) async {
  final db = await DatabaseService.instance.database;

  // Déterminer la table en fonction du type d'élément
  String tableName;
  if (item.containsKey('command')) {
    tableName = 'commands';
  } else if (item.containsKey('note')) {
    tableName = 'notes';
  } else if (item.containsKey('code')) {
    tableName = 'codes';
  } else {
    return; // Si le type n'est pas reconnu, ne rien faire
  }

  // Supprimer l'élément de la base de données
  await db.delete(tableName, where: 'id = ?', whereArgs: [item['id']]);

  // Mettre à jour l'état pour refléter la suppression
  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Élément supprimé avec succès!')),
  );
}
}
