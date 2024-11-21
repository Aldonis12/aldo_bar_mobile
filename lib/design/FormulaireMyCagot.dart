import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCagotPage extends StatefulWidget {
  @override
  _AddCagotPageState createState() => _AddCagotPageState();
}

class _AddCagotPageState extends State<AddCagotPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _formDataList = [
    {'selectedProduct': null, 'selectedQuantityType': 'Nombre', 'quantity': 1}
  ];
  List<Map<String, dynamic>> _products = [];

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

      final saleDataList = _formDataList.map((formData) {
        return {
          'idProduit': formData['selectedProduct'],
          'quantite': formData['quantity'],
          'quantite_type': formData['selectedQuantityType'],
        };
      }).toList();

      final requestData = {'produits': saleDataList};

      showDialog(
        context: context,
        builder: (BuildContext context) {
          final double screenHeight = MediaQuery.of(context).size.height;

          return AlertDialog(
            title: Text(
              'Confirmation de l\'ajout des bouteilles',
              style: TextStyle(
                  fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produits choisis :',
                    style: TextStyle(
                        fontSize: screenHeight * 0.0184,
                        fontWeight: FontWeight.bold),
                  ),
                  ..._formDataList.map((formData) {
                    final selectedProductId = formData['selectedProduct'];
                    final product = _products.firstWhere(
                          (product) =>
                      product['id'].toString() == selectedProductId,
                      orElse: () => {},
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '- ${product['nom']} : ${formData['quantity']} (${formData['selectedQuantityType']})',
                        style: TextStyle(fontSize: screenHeight * 0.016),
                      ),
                    );
                  }).toList(),
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
                    final response = await http.post(
                      Uri.parse(
                          'https://aldo-bar.gtouch-admin.com/api/add-mycagot'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(requestData),
                    );

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mise en stock avec succès')),
                      );
                      _formKey.currentState!.reset();
                      setState(() {
                        _formDataList = [
                          {
                            'selectedProduct': null,
                            'selectedQuantityType': 'Nombre',
                            'quantity': 1
                          }
                        ];
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur : ${response.body}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Une erreur est survenue : $e')),
                    );
                    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de mes bouteilles'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.0184),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _formDataList.length,
                  itemBuilder: (context, index) {
                    final formData = _formDataList[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0092),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
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
                              width: screenHeight * 0.08,
                              child: TextFormField(
                                initialValue: formData['quantity'].toString(),
                                decoration: InputDecoration(
                                  labelText: 'Quantité',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    formData['quantity'] = int.tryParse(value) ?? 1;
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
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.0184),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed: _addForm,
                      child: Icon(Icons.add, color: Colors.white,),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: _submitForm,
                      child: Text(
                        'Valider',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
