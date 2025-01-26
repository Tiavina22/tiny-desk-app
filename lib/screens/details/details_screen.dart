import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_desk/services/database/database_service.dart';

import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailScreen({super.key, required this.item});

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
    _descriptionController =
        TextEditingController(text: widget.item['description']);
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
    _saveTimer = Timer(const Duration(seconds: 2), () {
      _saveChanges(); // Sauvegarde automatique après 2 secondes d'inactivité
    });
  }

  // Méthode pour copier le contenu dans le presse-papiers
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _contentController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contenu copié dans le presse-papiers!'),
        duration: Duration(seconds: 2),
      ),
    );
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

    // Vérifie si tous les champs sont vides
    if (_titleController.text.isEmpty &&
        _descriptionController.text.isEmpty &&
        _contentController.text.isEmpty) {
      // Supprime l'élément de la base de données
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [widget.item['id']],
      );

      // Affiche un feedback discret
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Élément supprimé car tous les champs étaient vides.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Retourne à l'écran précédent avec un résultat indiquant que l'élément a été supprimé
      Navigator.pop(context, true);
    } else {
      // Met à jour l'élément dans la base de données
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
        const SnackBar(
          content: Text('Modifications sauvegardées automatiquement!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCommand = widget.item.containsKey('command');

    final bool isCode = widget.item.containsKey('code');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.blue), // Icône personnalisée
          onPressed: () {
            Navigator.pop(
                context, true); // Retour personnalisé avec un résultat
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
                decoration: const InputDecoration(
                  hintText: 'Titre',
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 32.0, thickness: 1.0),
              // Condition pour afficher le contenu en mode terminal ou normal
              if (isCommand)
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: _contentController,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14.0,
                          color: Colors.green,
                        ),
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Ajoutez du contenu ici...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Icône de copie en haut à droite
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: IconButton(
                        icon: const Icon(Icons.copy,
                            color: Color.fromARGB(255, 136, 136, 136)),
                        onPressed: _copyToClipboard,
                      ),
                    ),
                  ],
                )
              else if (isCode)
                Stack(
                  children: [
                    // Affichage du code avec coloration syntaxique
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(0.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: HighlightView(
                        _contentController.text,
                        language: 'dart',
                        theme: monokaiSublimeTheme,
                        padding: const EdgeInsets.all(12.0),
                        textStyle: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14.0,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Champ de texte transparent pour l'édition
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _contentController,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14.0,
                          height: 1.5,
                          color: Colors.transparent,
                        ),
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Ajoutez du contenu ici...',
                          hintStyle: TextStyle(color: Colors.transparent),
                          border: InputBorder.none,
                        ),
                        cursorColor: Colors.white,
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),

                    // Icône de copie en haut à droite
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: IconButton(
                        icon: const Icon(Icons.copy,
                            color: Color.fromARGB(255, 136, 136, 136)),
                        onPressed: _copyToClipboard,
                      ),
                    ),
                  ],
                )
              else
                TextField(
                  controller: _contentController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: null,
                  decoration: const InputDecoration(
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
