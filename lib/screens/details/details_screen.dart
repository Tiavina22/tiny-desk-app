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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item['title']);
    _descriptionController = TextEditingController(text: widget.item['description']);
    _contentController = TextEditingController(
        text: widget.item['command'] ??
            widget.item['note'] ??
            widget.item['code']);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modifications enregistrées avec succès!')),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Contenu'),
                maxLines: 5,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
