import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProductPurchaseFormPage extends StatefulWidget {
  @override
  _ProductPurchaseFormPageState createState() =>
      _ProductPurchaseFormPageState();
}

class _ProductPurchaseFormPageState extends State<ProductPurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _formDataList = [
    {'selectedProduct': null, 'selectedQuantityType': 'Nombre', 'quantity': 1}
  ];
  List<Map<String, dynamic>> _products = [];
  String _selectedDate = '';  // Variable pour stocker la date sélectionnée

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produits'));
      if (response.statusCode == 200) {
        List<dynamic> products = json.decode(response.body);
        setState(() {
          _products = products.map((product) {

            final quantiteCagot = int.tryParse(product['quantite_cagot'].toString()) ?? 0;
            final prixAchat = double.tryParse(product['prix_achat'].toString()) ?? 0.0;

            return {
              'id': product['id'],
              'nom': product['nom'],
              'prix': product['prix_achat'],
              'prix_cagot': quantiteCagot * prixAchat,
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
      print('Une erreur : $e');
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

  TextEditingController _totalToPayController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Map de données produits
      final purchaseDataList = _formDataList.map((formData) {
        return {
          'idProduit': formData['selectedProduct'],
          'quantite': formData['quantity'],
          'quantite_type': formData['selectedQuantityType'],
        };
      }).toList();

      // Calcul du total général
      double totalGeneral = _calculateGrandTotal();
      double totalToPay = double.tryParse(_totalToPayController.text) ?? totalGeneral;

      // Structure de la requête
      final requestData = {
        'produits': purchaseDataList,
        'date': _selectedDate.isEmpty ? null : _selectedDate,
        'total': totalToPay,
      };

      print('Request Data: $requestData');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          final double screenHeight = MediaQuery.of(context).size.height;

          return AlertDialog(
            title: Text(
              'Confirmation de l\'achat',
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
                    'Total général: ${_formatTotal(totalGeneral)} Ar',
                    style: TextStyle(fontSize: screenHeight * 0.0184, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: screenHeight * 0.0092),
                  Text(
                    'Total à payer: ${_formatTotal(totalToPay)} Ar',
                    style: TextStyle(fontSize: screenHeight * 0.0184, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue sans soumettre
                },
                icon: Icon(Icons.cancel, color: Colors.red),
                label: Text('Annuler', style: TextStyle(color: Colors.red)),
              ),
              TextButton.icon(
                onPressed: () async {
                  try {
                    final response = await http.post(
                      Uri.parse('https://aldo-bar.gtouch-admin.com/api/add-produitentrant'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(requestData),
                    );

                    // Vérification de la réponse
                    if (response.statusCode == 200 || response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produit(s) acheté(s) avec succès')),
                      );
                      _formKey.currentState!.reset();
                      setState(() {
                        _formDataList = [
                          {'selectedProduct': null, 'selectedQuantityType': 'Nombre', 'quantity': 1}
                        ];
                      });
                      Navigator.of(context).pop();
                    } else {
                      print('Erreur lors de l\'achat du produit: ${response.body}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'achat du produit: ${response.body}')),
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
        title: Text('Achat Produit'),
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
                        'Total général: ',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_formatTotal(_calculateGrandTotal())} Ar',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold, color: Colors.red), // Rouge pour le Total général
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.0092), // Un peu d'espace entre les deux lignes
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Choisir pourcentage: ',
                        style: TextStyle(fontSize: screenHeight * 0.0184, fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                      DropdownButton<double>(
                        value: _selectedPercentage,
                        items: [
                          DropdownMenuItem(
                            value: 0.03,
                            child: Text('3%'),
                          ),
                          DropdownMenuItem(
                            value: 0.04,
                            child: Text('4%'),
                          ),
                        ],
                        onChanged: (double? newValue) {
                          setState(() {
                            _selectedPercentage = newValue ?? 0.04;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.0092), // Un peu d'espace avant le prochain texte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total à payer: ',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_formatTotal(_calculateGrandTotal() - (_calculateGrandTotal() * _selectedPercentage))} Ar',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold, color: Colors.green), // Vert pour le Total à payer
                      ),
                    ],
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total à payer: ',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: screenHeight * 0.15,
                        height: screenHeight * 0.055,
                        child: TextFormField(
                          controller: _totalToPayController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrez la valeur';
                            }
                            final enteredValue = double.tryParse(value);
                            if (enteredValue == null || enteredValue >= _calculateGrandTotal()) {
                              return '? < Total';
                            }
                            return null;
                          },
                        ),
                      ),
                      Text(
                        ' Ar',
                        style: TextStyle(fontSize: screenHeight * 0.020, fontWeight: FontWeight.bold, color: Colors.green),
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
                      backgroundColor: Colors.lightGreen),
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
