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
              'id': bouteille['idProduit'],
              'nomProduit': bouteille['produit']?['nom'] ?? 'Produit inconnu',
              'quantite': bouteille['quantite'] ?? 0,
              'quantite_cagot': bouteille['produit']?['quantite_cagot'] ?? 0,
            };
          }).toList();
          _filteredBottles = _bottles;
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

  void _filterBottles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBottles = _bottles.where((bottle) {
        return bottle['nomProduit'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _updateBottle(final id, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('https://aldo-bar.gtouch-admin.com/api/update-mycagot/$id/$quantity'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit mis à jour avec succès')),
        );
        fetchBottles();
      } else {
        throw Exception('Failed to update bottle');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
    }
  }

  Future<void> _deleteBottle(final id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://aldo-bar.gtouch-admin.com/api/delete-mycagot/$id'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit supprimé avec succès')),
        );
        fetchBottles();
      } else {
        throw Exception('Failed to delete bottle');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  void _showUpdateDialog(final id, String productName, int currentQuantity) {
    TextEditingController _quantityController = TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le produit : $productName'),
          content: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantité actuelle : $currentQuantity'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                int newQuantity = int.tryParse(_quantityController.text) ?? currentQuantity;
                _updateBottle(id, newQuantity);
                Navigator.of(context).pop();
              },
              child: Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteConfirmation(final id, String name, int qtt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer le produit $name ($qtt bouteilles)'),
          content: Text('Êtes-vous sûr de vouloir supprimer le produit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteBottle(id);
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
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
            final id = bottle['id'];
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
                onTap: () => _showUpdateDialog(id,name, quantity),
                onLongPress: () => _showDeleteConfirmation(id, name, quantity),
              ),
            );
          },
        ),
      ),
    );
  }
}
