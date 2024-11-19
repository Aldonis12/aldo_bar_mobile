import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BottleListPage extends StatefulWidget {
  @override
  _BottleListPageState createState() => _BottleListPageState();
}

class _BottleListPageState extends State<BottleListPage> {
  List _bottles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBottles();
  }

  Future<void> fetchBottles() async {
    try {
      final response = await http.get(Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-mycagot'));

      if (response.statusCode == 200) {
        setState(() {
          _bottles = json.decode(response.body).map((bottle) {
            return {
              'nomProduit': bottle['produit']?['nom'] ?? 'Produit inconnu',
              'quantite': bottle['quantite'] ?? 0,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load bottles');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du chargement des bouteilles'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Bouteilles"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bottles.isEmpty
          ? Center(
        child: Text(
          "Aucune bouteille trouvée",
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
      )
          : Padding(
        padding: EdgeInsets.all(screenHeight * 0.01),
        child: ListView.builder(
          itemCount: _bottles.length,
          itemBuilder: (context, index) {
            final bottle = _bottles[index];
            final name = bottle['nomProduit']; // Le nom du produit
            final quantity = bottle['quantite']; // La quantité de bouteilles

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: ListTile(
                title: Text(
                  name,
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
                subtitle: Text(
                  '$quantity bouteilles',
                  style: TextStyle(fontSize: screenHeight * 0.018),
                ),
                //leading: Icon(Icons.local_drink, color: Colors.blue),
              ),
            );
          },
        ),
      ),
    );
  }
}
