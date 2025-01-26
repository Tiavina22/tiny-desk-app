import 'package:flutter/material.dart';
import 'package:tiny_desk/screens/auth/login_screen.dart';
import 'package:tiny_desk/services/auth/auth_service.dart';
import 'package:tiny_desk/widgets/succes_signup_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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
  bool _isLoading = false;
  int _currentStep = 0;

  final AuthService _authService = AuthService();

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.signup(
          _usernameController.text,
          _passwordController.text,
          _confirmPasswordController.text,
        );

        if (response['message'] == "Utilisateurs inscrit avec succes") {
          await showSuccessDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erreur lors de l\'inscription.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue : $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildStepOne() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nom d\'utilisateur',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF3D3D3D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom d\'utilisateur';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _nextStep,
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF3D3D3D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _nextStep,
          child: const Text('Suivant'),
        ),
        ElevatedButton(
          onPressed: _previousStep,
          child: const Text('Précédent'),
        ),
      ],
    );
  }

  Widget _buildStepThree() {
    return Column(
      children: [
        TextFormField(
          controller: _confirmPasswordController,
          style: const TextStyle(color: Colors.white),
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmation',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF3D3D3D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _previousStep,
          child: const Text('Précédent'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _handleSignup,
          child: const Text('S\'inscrire'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Card(
                  color: const Color(0xFF2D2D2D),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/logo_white.png',
                              height: 80,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Créer un compte',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rejoignez Tiny dès aujourd\'hui',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        IndexedStack(
                          index: _currentStep,
                          children: [
                            _buildStepOne(),
                            _buildStepTwo(),
                            _buildStepThree(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ?',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}