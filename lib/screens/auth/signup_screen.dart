import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.grey[850],
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo_white.png',
                                height: 100,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
              SizedBox(height: 20),
              TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom d\'utilisateur';
                            }
                            return null;
                          },
                        ),
              SizedBox(height: 10),
              TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: Colors.white),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            return null;
                          },
                        ),
              SizedBox(height: 10),
              TextFormField(
                          controller: _confirmPasswordController,
                          style: TextStyle(color: Colors.white),
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmation du mot de passe',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            return null;
                          },
                        ),
              
              SizedBox(height: 20),
             ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Logique de l'inscription
                            }
                          },
                          child: Text('S\'inscrire', style: TextStyle(fontSize: 16, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 5,
                          ),
                        ),
              SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Vous avez déja un compte? Se connecter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
              
            ],
          ),
        ),
                ))
            )))));
}}
