import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCagotPage extends StatefulWidget {
  @override
  _AddCagotPageState createState() => _AddCagotPageState();
}

class _AddCagotPageState extends State<AddCagotPage> {
  List _products = [];
  String? _selectedProduct;
  TextEditingController _bottleCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produits'));
      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du chargement des produits'),
      ));
    }
  }

  Future<void> addCagot() async {
    if (_selectedProduct == null || _bottleCountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez sélectionner un produit et entrer un nombre valide.'),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://aldo-bar.gtouch-admin.com/api/add-mycagot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idProduit': _selectedProduct,
          'quantite': int.parse(_bottleCountController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cagot ajouté avec succès !'),
        ));
        _bottleCountController.clear();
        setState(() {
          _selectedProduct = null;
        });
      } else {
        throw Exception('Erreur lors de l\'ajout du cagot');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Une erreur est survenue, veuillez réessayer.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Cagot'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner un produit :',
              style: TextStyle(fontSize: screenHeight * 0.022),
            ),
            SizedBox(height: screenHeight * 0.01),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              hint: Text('Choisissez un produit'),
              value: _selectedProduct,
              items: _products.map((product) {
                return DropdownMenuItem<String>(
                  value: product['id'].toString(),
                  child: Text(product['nom']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Nombre de bouteilles :',
              style: TextStyle(fontSize: screenHeight * 0.022),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _bottleCountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Entrez le nombre de bouteilles',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: addCagot,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                textStyle: TextStyle(fontSize: screenHeight * 0.02),
              ),
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
