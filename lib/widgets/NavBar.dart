import 'package:flutter/material.dart';
import 'dart:io';

class NavBar extends StatelessWidget{

  void _showNotAvailableMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Indisponible"),
          content: Text("Ceci n'est pas encore disponible pour le moment!"),
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Voulez-vous vraiment quitter l'application ?"),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
              },
            ),
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                exit(0); // Quitte l'application
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
            accountName: Text(''),
            accountEmail: Text('Aldonis Mick Lewis'),
            /*currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset("assets/images/one.jpg",
                width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),*/
          decoration: BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
              image: AssetImage("assets/images/three.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        ExpansionTile(
          leading: Icon(Icons.add),
          title: Text('Ajout'),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.production_quantity_limits),
              title: Text('Produit'),
              onTap: () => {
                Navigator.pushNamed(context, '/ajout-produit')
              }
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Achat'),
              onTap: () => {
                Navigator.pushNamed(context, '/ajout-achat')
              }
            ),
            ListTile(
              leading: Icon(Icons.shopping_basket),
              title: Text('Vente'),
              onTap: () => {
                Navigator.pushNamed(context, '/ajout-vente')
              }
            ),
            ListTile(
              leading: Icon(Icons.monetization_on_rounded),
              title: Text('Mouvement Caisse'),
              onTap: () => {
                Navigator.pushNamed(context, '/ajout-mvtcaisse')
              },
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.local_drink),
          title: Text('Produit'),
          onTap: () => {
            Navigator.pushNamed(context, '/detail-produit')
          }
        ),
        ListTile(
          leading: Icon(Icons.attach_money),
          title: Text('Mouvement'),
          onTap: () {
            _showNotAvailableMessage(context);
          },
        ),
        Divider(),
        ExpansionTile(
          leading: Icon(Icons.add),
          title: Text('Aujourd\'hui'),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.shopping_cart_outlined),
              title: Text('Achat'),
                onTap: () => {
                  Navigator.pushNamed(context, '/detail-achat')
                }
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Vente'),
                onTap: () => {
                  Navigator.pushNamed(context, '/detail-vente')
                }
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.money),
          title: Text('chiffre d\'affaire'),
          onTap: () {
            _showNotAvailableMessage(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.data_exploration),
          title: Text('Statistique'),
            onTap: () {
            _showNotAvailableMessage(context);
            }
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Exit'),
          onTap: () {
          _showExitConfirmationDialog(context);
          }
        )
      ],
    ),
    );
  }
}

