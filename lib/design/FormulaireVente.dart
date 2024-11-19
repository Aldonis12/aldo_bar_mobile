import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProductsaleFormPage extends StatefulWidget {
  @override
  _ProductsaleFormPageState createState() =>
      _ProductsaleFormPageState();
}

class _ProductsaleFormPageState extends State<ProductsaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _formDataList = [
    {'selectedProduct': null, 'selectedQuantityType': 'Nombre', 'quantity': 1}
  ];
  List<Map<String, dynamic>> _products = [];
  String _selectedDate = '';  // Variable pour stocker la date sélectionnée

  double _selectedPercentage = 0.04;

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produits'));
      if (response.statusCode == 200) {
        List<dynamic> products = json.decode(response.body);
        setState(() {
          _products = products.map((product) {
            return {
              'id': product['id'],
              'nom': product['nom'],
              'prix': product['prix'],
              'prix_cagot': product['prix_cagot'],
            };
          }).toList();
        });
      } else {
        throw Exception('Erreur lors du chargement des produits');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  double _calculateTotal(Map<String, dynamic> formData) {
    final selectedProductId = formData['selectedProduct'];
    if (selectedProductId == null) return 0.0;

    final product = _products.firstWhere(
          (product) => product['id'].toString() == selectedProductId,
      orElse: () => {},
    );

    if (product.isEmpty) return 0.0;

    double price = formData['selectedQuantityType'] == 'Nombre'
        ? double.tryParse(product['prix'].toString()) ?? 0.0
        : double.tryParse(product['prix_cagot'].toString()) ?? 0.0;

    return price * formData['quantity'];
  }

  String _formatTotal(double total) {
    final numberFormat = NumberFormat("#,##0", "fr_FR");  // Format français avec séparateur de milliers
    return numberFormat.format(total);
  }

  double _calculateGrandTotal() {
    return _formDataList.fold(
        0.0, (sum, formData) => sum + _calculateTotal(formData));
  }

  void _addForm() {
    setState(() {
      _formDataList.add({
        'selectedProduct': null,
        'selectedQuantityType': 'Nombre',
        'quantity': 1
      });
    });
  }

  void _removeForm(int index) {
    setState(() {
      _formDataList.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Map de données produits
      final saleDataList = _formDataList.map((formData) {
        return {
          'idProduit': formData['selectedProduct'],
          'quantite': formData['quantity'],
          'quantite_type': formData['selectedQuantityType'],
        };
      }).toList();

      // Structure de la requête
      final requestData = {
        'produits': saleDataList,
        'date': _selectedDate.isEmpty ? null : _selectedDate,
      };

      // Affichage de la structure de la requête pour débogage
      print('Request Data: $requestData');

      // Calcul du total
      double totalGeneral = _calculateGrandTotal();

      // Affichage de la boîte de dialogue de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final double screenHeight = MediaQuery.of(context).size.height;

          return AlertDialog(
            title: Text(
              'Confirmation du vente',
              style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produits choisis :',
                    style: TextStyle(fontSize: screenHeight * 0.0184, fontWeight: FontWeight.bold),
                  ),
                  ..._formDataList.map((formData) {
                    final selectedProductId = formData['selectedProduct'];
                    final product = _products.firstWhere(
                          (product) => product['id'].toString() == selectedProductId,
                      orElse: () => {},
                    );
                    double price = formData['selectedQuantityType'] == 'Nombre'
                        ? double.tryParse(product['prix'].toString()) ?? 0.0
                        : double.tryParse(product['prix_cagot'].toString()) ?? 0.0;
                    double totalPrice = price * formData['quantity'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '- ${product['nom']} : ${formData['quantity']} (${formData['selectedQuantityType']}) => ${_formatTotal(totalPrice)} Ar',
                        style: TextStyle(fontSize: screenHeight * 0.016),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: screenHeight * 0.0184),
                  Text(
                    'Total: ${_formatTotal(totalGeneral)} Ar',
                    style: TextStyle(fontSize: screenHeight * 0.0184, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.cancel, color: Colors.red),
                label: Text('Annuler', style: TextStyle(color: Colors.red)),
              ),
              TextButton.icon(
                onPressed: () async {
                  try {
                    // Requête HTTP POST avec la structure ajustée
                    final response = await http.post(
                      Uri.parse('https://aldo-bar.gtouch-admin.com/api/add-produitsortant'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(requestData), // Utilisation de requestData
                    );

                    // Vérification de la réponse
                    if (response.statusCode == 200 || response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mise en vente avec succès')),
                      );
                      _formKey.currentState!.reset();
                      setState(() {
                        _formDataList = [
                          {'selectedProduct': null, 'selectedQuantityType': 'Nombre', 'quantity': 1}
                        ];
                      });
                      Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    } else {
                      // Affichage de l'erreur avec les détails de la réponse
                      print('Erreur lors du vente du produit: ${response.body}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors du vente du produit: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    print('Exception: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Une erreur est survenue: $e')),
                    );
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue en cas d'erreur
                  }
                },
                icon: Icon(Icons.check, color: Colors.green),
                label: Text('Confirmer', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    }
  }



  // Méthode pour choisir une date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);  // Format de la date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vente Produit'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0184),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Affichage de la date sélectionnée en haut
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.0184),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _selectDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.0184),
                      ),
                      child: Text(
                        'Choisir une Date',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      _selectedDate.isEmpty
                          ? 'Aucune date sélectionnée'
                          : 'Date: $_selectedDate',
                      style: TextStyle(fontSize: screenHeight * 0.0184),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _formDataList.length,
                  itemBuilder: (context, index) {
                    final formData = _formDataList[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0092),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: screenHeight * 0.20,
                                  child: DropdownButtonFormField<String>(
                                    value: formData['selectedProduct'],
                                    items: _products.map((product) {
                                      return DropdownMenuItem<String>(
                                        value: product['id'].toString(),
                                        child: Text(product['nom']),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        formData['selectedProduct'] = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Produit",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Sélectionnez un produit';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: screenHeight * 0.0092),
                                SizedBox(
                                  width: screenHeight * 0.12,
                                  child: DropdownButtonFormField<String>(
                                    value: formData['selectedQuantityType'],
                                    items: ['Cagot', 'Nombre'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        formData['selectedQuantityType'] = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Type",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenHeight * 0.0092),
                                SizedBox(
                                  width: screenHeight * 0.080,
                                  child: TextFormField(
                                    initialValue: formData['quantity'].toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Quantité',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        formData['quantity'] =
                                            int.tryParse(value) ?? 1;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Entrez une quantité';
                                      }
                                      if (int.tryParse(value) == null ||
                                          int.parse(value) <= 0) {
                                        return 'Quantité > 0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: screenHeight * 0.0092),
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: () {
                                    _removeForm(index);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.0092),
                            Text(
                              "Total: ${_formatTotal(_calculateTotal(formData))}",
                              style: TextStyle(fontSize: screenHeight * 0.0184),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.0184),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total : ',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_formatTotal(_calculateGrandTotal())} Ar',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold, color: Colors.green), // Rouge pour le Total général
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.0092),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey),
                    child: Icon(Icons.add, color: Colors.white,),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                    child: Text('Soumettre',
                        style: TextStyle(
                            color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}