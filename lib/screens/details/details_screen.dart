import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiny_desk/services/database/database_service.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  DetailScreen({required this.item});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item['title']);
    _descriptionController = TextEditingController(text: widget.item['description']);
    _contentController = TextEditingController(
        text: widget.item['command'] ??
            widget.item['note'] ??
            widget.item['code']);

    _titleController.addListener(_onTextChanged);
    _descriptionController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Redémarre le timer chaque fois qu'il y a une modification
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 2), () {
      _saveChanges(); // Sauvegarde automatique après 2 secondes d'inactivité
    });
  }

  Future<void> _saveChanges() async {
    final db = await DatabaseService.instance.database;

    String tableName;
    String contentColumn;

    if (widget.item.containsKey('command')) {
      tableName = 'commands';
      contentColumn = 'command';
    } else if (widget.item.containsKey('note')) {
      tableName = 'notes';
      contentColumn = 'note';
    } else {
      tableName = 'codes';
      contentColumn = 'code';
    }

    await db.update(
      tableName,
      {
        'title': _titleController.text,
        'description': _descriptionController.text,
        contentColumn: _contentController.text,
      },
      where: 'id = ?',
      whereArgs: [widget.item['id']],
    );

    // Affiche un feedback discret
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modifications sauvegardées automatiquement!'),
        duration: Duration(seconds: 1),
      ),
    );

    // Renvoyer un résultat pour indiquer que des modifications ont été apportées
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue), // Icône personnalisée
          onPressed: () {
            Navigator.pop(context, true); // Retour personnalisé avec un résultat
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges, // Bouton manuel pour sauvegarder
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: InputDecoration(
                  hintText: 'Titre',
                  border: InputBorder.none,
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: InputBorder.none,
                ),
              ),
              Divider(height: 32.0, thickness: 1.0),
              TextField(
                controller: _contentController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Ajoutez du contenu ici...',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
