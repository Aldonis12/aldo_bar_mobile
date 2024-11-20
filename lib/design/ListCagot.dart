import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BottleListPage extends StatefulWidget {
  @override
  _BottleListPageState createState() => _BottleListPageState();
}

class _BottleListPageState extends State<BottleListPage> {
  List _bottles = [];
  List _filteredBottles = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBottles();
    _searchController.addListener(_filterBottles);
  }

  Future<void> fetchBottles() async {
    try {
      final response = await http.get(Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-mycagot'));

      if (response.statusCode == 200) {
        setState(() {
          _bottles = json.decode(response.body).map((bouteille) {
            return {
              'nomProduit': bouteille['produit']?['nom'] ?? 'Produit inconnu',
              'quantite': bouteille['quantite'] ?? 0,
              'quantite_cagot': bouteille['produit']?['quantite_cagot'] ?? 0,
            };
          }).toList();
          _filteredBottles = _bottles;  // Initially show all bottles
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

  // Filter bottles based on search input
  void _filterBottles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBottles = _bottles.where((bottle) {
        return bottle['nomProduit'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Liste de mes Bouteilles"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un produit",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredBottles.isEmpty
          ? Center(
        child: Text(
          "Aucune bouteille trouvée",
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
      )
          : Padding(
        padding: EdgeInsets.all(screenHeight * 0.01),
        child: ListView.builder(
          itemCount: _filteredBottles.length,
          itemBuilder: (context, index) {
            final bottle = _filteredBottles[index];
            final name = bottle['nomProduit'];
            final quantity = bottle['quantite'];
            final quantityCagot = bottle['quantite_cagot'];

            String resultText = '';
            if (quantityCagot > 0) {
              int cagots = (quantity / quantityCagot).floor();
              int bottles = quantity % quantityCagot;

              if (cagots > 0) {
                resultText += '$cagots Cagots';
              }
              if (bottles > 0) {
                if (resultText.isNotEmpty) resultText += ' et ';
                resultText += '$bottles Bouteilles';
              }
            } else {
              resultText = '$quantity Bouteilles';
            }

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: ListTile(
                title: Text(
                  '$name ($quantity)',
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
                subtitle: Text(
                  resultText.isEmpty ? 'Pas de stock disponible' : resultText,
                  style: TextStyle(fontSize: screenHeight * 0.018),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
