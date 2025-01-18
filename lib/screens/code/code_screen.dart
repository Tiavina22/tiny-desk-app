import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tiny_desk/screens/details/details_screen.dart';
import 'package:tiny_desk/services/database/database_service.dart';



class CodeScreen extends StatefulWidget {
  @override
  _CodeScreenState createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final DatabaseService dbService = DatabaseService.instance;

  // Méthode pour récupérer les codes
  Future<List<Map<String, dynamic>>> _fetchCodes() async {
    return await dbService.getCodes();
  }

  // Méthode pour supprimer une code
  Future<void> _deleteCommand(Map<String, dynamic> code) async {
    final db = await dbService.database;
    await db.delete('codes', where: 'id = ?', whereArgs: [code['id']]);
    setState(() {}); // Rafraîchir l'interface après la suppression

     // Afficher un SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('COde supprimée avec succès'),
      duration: Duration(seconds: 2),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Codes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCodes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune code disponible.'));
                }

                final codes = snapshot.data!;

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
                    itemCount: codes.length,
                    itemBuilder: (context, index) {
                      final code = codes[index];
                      Color circleColor = Colors.red;

                      return GestureDetector(
                        onTap: () async {
                          // Vers un écran de détail
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(item: code),
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
                                          code['title'] ?? '',
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
                                    code['description'] ?? '',
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
                                          _deleteCommand(code);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Supprimer le code'),
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