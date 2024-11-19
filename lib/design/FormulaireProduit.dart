import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductFormPage extends StatefulWidget {
  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  int _quantity = 0;
  double _price = 0.0;
  double _priceachat = 0.0;
  int _quantityCagot = 0;

  // Calcul automatique du prix cagot
  double get _priceCagot => _price * _quantityCagot;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prépare les données pour l'API (sans prix_cagot)
      final Map<String, dynamic> productData = {
        'nom': _name,
        'quantite': _quantity,
        'prix': _price,
        'prix_achat': _priceachat,
        'quantite_cagot': _quantityCagot > 0 ? _quantityCagot : null,
      };

      try {
        final response = await http.post(
          Uri.parse('https://aldo-bar.gtouch-admin.com/api/add-produit'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(productData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit ajouté avec succès')),
          );
          // Réinitialise le formulaire après la soumission
          _formKey.currentState!.reset();
          setState(() {
            _name = null;
            _quantity = 0;
            _price = 0.0;
            _priceachat = 0.0;
            _quantityCagot = 0;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout du produit. Code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout Produit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.0184),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.0184),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  onSaved: (value) => _name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom du produit';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.0184),
                TextFormField(
                  initialValue: _quantity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantité en stock',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_shopping_cart),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _quantity = int.tryParse(value ?? '0') ?? 0,
                ),
                SizedBox(height: screenHeight * 0.0184),
                TextFormField(
                  initialValue: _priceachat.toStringAsFixed(2),
                  decoration: InputDecoration(
                    labelText: 'Prix Achat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prix d\'achat';
                    }
                    double? priceValue = double.tryParse(value);
                    if (priceValue == null || priceValue <= 0) {
                      return 'Le prix d\'achat doit être supérieur à 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _priceachat = double.tryParse(value) ?? 0.0;
                    });
                  },
                  onSaved: (value) => _priceachat = double.tryParse(value ?? '0') ?? 0.0,
                ),
                SizedBox(height: screenHeight * 0.0184),
                TextFormField(
                  initialValue: _price.toStringAsFixed(2),
                  decoration: InputDecoration(
                    labelText: 'Prix Revente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prix';
                    }
                    double? priceValue = double.tryParse(value);
                    if (priceValue == null || priceValue <= 0) {
                      return 'Le prix doit être supérieur à 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _price = double.tryParse(value) ?? 0.0;
                    });
                  },
                  onSaved: (value) => _price = double.tryParse(value ?? '0') ?? 0.0,
                ),
                SizedBox(height: screenHeight * 0.0184),
                TextFormField(
                  initialValue: _quantityCagot.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantité Cagot',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _quantityCagot = int.tryParse(value) ?? 0;
                    });
                  },
                  onSaved: (value) => _quantityCagot = int.tryParse(value ?? '0') ?? 0,
                ),
                SizedBox(height: screenHeight * 0.0184),
                // Affichage du prix_cagot calculé
                if (_quantityCagot > 0)
                  Text(
                    'Prix Cagot : ${_priceCagot.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: screenHeight * 0.020, color: Colors.blueAccent),
                  ),
                SizedBox(height: screenHeight * 0.02),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0184),
                    textStyle: TextStyle(fontSize: screenHeight * 0.020),
                  ),
                  child: Text('Valider'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
