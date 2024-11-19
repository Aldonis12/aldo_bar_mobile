import 'package:demo_gestion/design/DetailAchat.dart';
import 'package:demo_gestion/design/DetailMouvementCaisse.dart';
import 'package:demo_gestion/design/DetailVente.dart';
import 'package:demo_gestion/design/Accueil.dart';
import 'package:demo_gestion/design/FormulaireAchat.dart';
import 'package:demo_gestion/design/FormulaireMouvementCaisse.dart';
import 'package:demo_gestion/design/FormulaireProduit.dart';
import 'package:demo_gestion/design/FormulaireVente.dart';
import 'package:demo_gestion/design/FormulaireMyCagot.dart';
import 'package:demo_gestion/design/GridView.dart';
import 'package:demo_gestion/design/ListProduit.dart';
import 'package:demo_gestion/design/Statistique.dart';
import 'package:demo_gestion/design/ListCagot.dart';
import 'package:flutter/material.dart';
import 'homePage.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application multi-pages',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeAccueil(),
      routes: {
        /*'/accueil': (context) => HomeAccueil(),
        '/GridView': (context) => HomeGridView(),
        '/settings': (context) => SettingsPage(),*/
        '/ajout-vente': (context) => ProductsaleFormPage(),
        '/ajout-achat': (context) => ProductPurchaseFormPage(),
        '/ajout-produit': (context) => ProductFormPage(),
        '/ajout-mvtcaisse': (context) => AddMouvementCaissePage(),
        '/ajout-mycagot': (context) => AddCagotPage(),
        '/detail-produit': (context) => ProductGridPage(),
        '/detail-achat': (context) => ProduitEntrantPage(),
        '/detail-vente': (context) => ProduitSortantPage(),
        '/detail-mvtcaisse': (context) => MouvementCaissePage(),
        '/detail-mycagot': (context) => BottleListPage(),
        //'/statistique': (context) => StatistiquesProduitsPage(),
        //'/test': (context) => ProduitSortantPage(),// Route pour la page des paramètres
      },
    );
  }
}
