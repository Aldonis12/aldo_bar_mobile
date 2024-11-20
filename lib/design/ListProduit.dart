import 'package:demo_gestion/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductGridPage extends StatefulWidget {
  @override
  _ProductGridPageState createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List _products = [];
  List _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();
  double _quantityFilter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('https://aldo-bar.gtouch-admin.com/api/delete-produit/$id'),
    );

    if (response.statusCode == 200) {
      // Réactualiser la liste après suppression
      await fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit supprimé avec succès')),
      );
    } else {
      throw Exception('Échec de la suppression du produit');
    }
  }

  Future<void> _showDeleteConfirmationDialog(int productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await _deleteProduct(productId);
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produits'));
      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _filteredProducts = _products;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
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

  Future<void> _showEditProductDialog(Map<String, dynamic> product) async {
    TextEditingController nameController = TextEditingController(text: product['nom']);
    TextEditingController quantityController = TextEditingController(text: product['quantite'].toString());
    TextEditingController purchasePriceController = TextEditingController(text: product['prix_achat']);
    TextEditingController salePriceController = TextEditingController(text: product['prix']);
    TextEditingController cagPriceController = TextEditingController(text: product['prix_cagot']);
    TextEditingController cagQuantityController = TextEditingController(text: product['quantite_cagot'].toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: InputDecoration(labelText: 'Prix Achat'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: salePriceController,
                  decoration: InputDecoration(labelText: 'Prix Vente'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cagPriceController,
                  decoration: InputDecoration(labelText: 'Prix Cagot'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cagQuantityController,
                  decoration: InputDecoration(labelText: 'Quantité Cagot'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Modifier'),
              onPressed: () async {
                final updatedProduct = {
                  'nom': nameController.text,
                  'quantite': quantityController.text,
                  'prix_achat': purchasePriceController.text,
                  'prix': salePriceController.text,
                  'prix_cagot': cagPriceController.text,
                  'quantite_cagot': cagQuantityController.text,
                };

                await _updateProduct(product['id'], updatedProduct);
                await fetchProducts();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct(int id, Map<String, dynamic> updatedProduct) async {
    final response = await http.put(
      Uri.parse('https://aldo-bar.gtouch-admin.com/api/update-produit/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedProduct),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product['nom'].toLowerCase();
        final searchText = _searchController.text.toLowerCase();
        final quantity = product['quantite'];
        return name.contains(searchText) && quantity >= _quantityFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Produits"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(
        child: Text ("Aucun produit trouvée",
        style: TextStyle(fontSize: screenHeight * 0.02),
      ),
      ) : Padding(
        padding: EdgeInsets.all(screenHeight * 0.0092),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.011),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.011),
            Row(
              children: [
                Text("Quantité minimum :"),
                Slider(
                  value: _quantityFilter,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _quantityFilter.toString(),
                  onChanged: (value) {
                    setState(() {
                      _quantityFilter = value;
                      _filterProducts();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  final isLowStock = product['quantite'] < 5;

                  return GestureDetector(
                    onTap: () => _showEditProductDialog(product),
                    onLongPress: () => _showDeleteConfirmationDialog(product['id']),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: screenHeight * 0.005,
                      color: isLowStock ? Colors.red.shade50 : Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(screenHeight * 0.011),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['nom'],
                              style: TextStyle(
                                fontSize: screenHeight * 0.0184,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? Colors.red : Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.0092),
                            Text("Quantité : ${product['quantite']}"),
                            SizedBox(height: screenHeight * 0.0092),
                            Text("Prix Achat : ${product['prix_achat']} Ar"),
                            SizedBox(height: screenHeight * 0.0092),
                            Text("Prix Vente: ${product['prix']} Ar"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
