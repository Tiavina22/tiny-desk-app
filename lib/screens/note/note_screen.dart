


import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tiny_desk/screens/details/details_screen.dart';
import 'package:tiny_desk/services/database/database_service.dart';
import 'package:tiny_desk/services/user/user_service.dart';



class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
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

  // Méthode pour récupérer les codes
  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    if (_userInfo == null || _userInfo!['id'] == null) {
      return []; // Retourner une liste vide si l'utilisateur n'est pas connecté
    }

    final db = await dbService.database;
    return await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [_userInfo!['id']],
    );
  }

  // Méthode pour supprimer une note
  Future<void> _deleteCode(Map<String, dynamic> note) async {
    final db = await dbService.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [note['id']]);
    setState(() {}); // Rafraîchir l'interface après la suppression

     // Afficher un SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Note supprimée avec succès'),
      duration: Duration(seconds: 2),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune note disponible.'));
                }

                final notes = snapshot.data!;

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
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      Color circleColor = Colors.green;

                      return GestureDetector(
                        onTap: () async {
                          // Vers un écran de détail
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(item: note),
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
                                          note['title'] ?? '',
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
                                    note['description'] ?? '',
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
                                          _deleteCode(note);
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
}