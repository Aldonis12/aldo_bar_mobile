import 'package:flutter/material.dart';
import 'widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue sur la page d\'accueil'),
            SizedBox(height: 20),
            CustomButton(
              text: 'Accueil',
              onPressed: () {
                Navigator.pushNamed(context, '/accueil');
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Grid View',
              onPressed: () {
                Navigator.pushNamed(context, '/GridView');
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Aller aux paramètres',
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Aller aux tests',
              onPressed: () {
                Navigator.pushNamed(context, '/test');
              },
            ),
          ],
        ),
      ),
    );
  }
}
