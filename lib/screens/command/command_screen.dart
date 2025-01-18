import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tiny_desk/screens/details/details_screen.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';
class CommandScreen extends StatefulWidget {
  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final DatabaseService dbService = DatabaseService.instance;

  Map<String, dynamic>? _userInfo; 

   @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Récupérer les informations de l'utilisateur au démarrage
  }

   Future<void> _fetchUserInfo() async {
    final userInfo = await UserService().getUserInfo();
    setState(() {
      _userInfo = userInfo;
    });
  }

  // Méthode pour récupérer les commandes filtrées par user_id
  Future<List<Map<String, dynamic>>> _fetchCommands() async {
    if (_userInfo == null || _userInfo!['id'] == null) {
      return []; // Retourner une liste vide si l'utilisateur n'est pas connecté
    }

    final db = await dbService.database;
    return await db.query(
      'commands',
      where: 'user_id = ?',
      whereArgs: [_userInfo!['id']],
    );
  }

  // Méthode pour supprimer une commande
  Future<void> _deleteCommand(Map<String, dynamic> command) async {
    final db = await dbService.database;
    await db.delete('commands', where: 'id = ?', whereArgs: [command['id']]);
    setState(() {}); // Rafraîchir l'interface après la suppression

    // Afficher un SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande supprimée avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commands'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCommands(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune commande disponible.'));
                }

                final commands = snapshot.data!;

                // Calcul du nombre de colonnes en fonction de la largeur de l'écran
                double screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount = screenWidth > 1200
                    ? 6
                    : screenWidth > 800
                        ? 4
                        : 2;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MasonryGridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    itemCount: commands.length,
                    itemBuilder: (context, index) {
                      final command = commands[index];
                      Color circleColor = Colors.red;

                      return GestureDetector(
                        onTap: () async {
                          // Vers un écran de détail
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(item: command),
                            ),
                          );

                          // Rafraîchir l'écran si des modifications ont été apportées
                          if (result == true) {
                            setState(() {});
                          }
                        },
                        child: SizedBox(
                          width: 250, // Largeur fixe pour chaque carte
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
                                mainAxisSize: MainAxisSize.min,
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
                                          command['title'] ?? '',
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
                                    command['description'] ?? '',
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
                                          _deleteCommand(command);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Supprimer la commande'),
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
}