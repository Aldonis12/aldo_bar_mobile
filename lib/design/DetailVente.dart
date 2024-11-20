import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProduitSortantPage extends StatefulWidget {
  @override
  _ProduitSortantPageState createState() => _ProduitSortantPageState();
}

class _ProduitSortantPageState extends State<ProduitSortantPage> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  List<dynamic> _produitsEntrants = [];
  bool _isLoading = false;
  double _totalPrix = 0.0;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchProduitsEntrants();
  }

  Future<void> _fetchProduitsEntrants() async {
    setState(() {
      _isLoading = true;
    });

    final DateTime today = DateTime.now();

    String dateDebut;
    String dateFin;

    late final Uri url;

    if (_dateDebut != null && _dateFin != null) {
      dateDebut = _dateFormat.format(_dateDebut!);
      dateFin = _dateFormat.format(_dateFin!);
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitsortant?date_debut=$dateDebut&date_fin=$dateFin');
    } else if (_dateDebut != null) {
      dateDebut = _dateFormat.format(_dateDebut!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitsortant?date_debut=$dateDebut');
    } else if (_dateFin != null) {
      dateDebut = _dateFormat.format(_dateFin!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitsortant?date_fin=$dateFin');
    } else {
      dateDebut = _dateFormat.format(today);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitsortant');
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _produitsEntrants = data;
        _totalPrix = _produitsEntrants.fold(
          0.0,
              (sum, item) => sum + (double.tryParse(item['PrixTotal'].toString()) ?? 0.0),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des données')),
      );
      print("Erreur: ${response.statusCode}");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _dateDebut = pickedDate;
        } else {
          _dateFin = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vente : Produit Sortant'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0184),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_dateDebut == null
                        ? 'Date Début'
                        : 'Date Début: ${_dateFormat.format(_dateDebut!)}'),
                  ),
                ),
                SizedBox(width: screenHeight * 0.011),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_dateFin == null
                        ? 'Date Fin'
                        : 'Date Fin: ${_dateFormat.format(_dateFin!)}'),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.011),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchProduitsEntrants,
              child: Text(_isLoading ? 'Chargement...' : 'Rechercher'),
            ),
            SizedBox(height: screenHeight * 0.023),
            Text(
              'Somme Totale : ${NumberFormat("#,##0.00", "fr_FR").format(_totalPrix)} AR',
              style: TextStyle(
                fontSize: screenHeight * 0.020,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.023),
            Expanded(
              child: _produitsEntrants.isEmpty
                  ? Center(child: Text('Aucun produit trouvé'))
                  : ListView.builder(
                itemCount: _produitsEntrants.length,
                itemBuilder: (context, index) {
                  final produit = _produitsEntrants[index];

                  final quantity = produit['quantite'];
                  int quantityCagot = produit['produit']['quantite_cagot'] ?? 0;

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
                    child: ListTile(
                      title: Text(
                        produit['produit']['nom'],
                        style: TextStyle(
                          fontSize: screenHeight * 0.020,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'Quantité : ${produit['quantite']}',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            '$resultText',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'Prix Total : ${produit['PrixTotal']} AR',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'Date : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(produit['inserted']))}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                        ],
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
}
