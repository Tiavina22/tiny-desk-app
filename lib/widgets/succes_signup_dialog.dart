import 'package:flutter/material.dart';
import 'package:tiny_desk/screens/auth/login_screen.dart';

Future<void> showSuccessDialog(BuildContext context) async {
  // Récupération du thème actuel
  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor = Theme.of(context).dialogBackgroundColor;
  final primaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  // Couleur du bouton : Dynamique ou valeur par défaut
  final buttonColor = Theme.of(context).primaryColor ?? (isDarkTheme ? Colors.greenAccent : Colors.green);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background animation (pulsing circle)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                  // Success Icon
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Inscription Réussie !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vous êtes maintenant inscrit à Tiny Desk. Accédez à votre compte et découvrez toutes nos fonctionnalités !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryTextColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkTheme ? const Color.fromARGB(255, 226, 226, 226) : Colors.black, // Couleur du bouton
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isDarkTheme ? 0 : 3, // Réduction de l'ombre en mode sombre
                ),
                child: Text(
                  'Aller à la Connexion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkTheme ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
