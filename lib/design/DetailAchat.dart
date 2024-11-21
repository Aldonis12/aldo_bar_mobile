import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProduitEntrantPage extends StatefulWidget {
  @override
  _ProduitEntrantPageState createState() => _ProduitEntrantPageState();
}

class _ProduitEntrantPageState extends State<ProduitEntrantPage> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  List<dynamic> _produitsEntrants = [];
  List<dynamic> _paiementAchat = [];
  bool _isLoading = false;
  double _totalPrix = 0.0;
  double _totalPourcentage = 0.0;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchProduitsEntrants();
    _fetchProduitPaiement();
  }

  Future<void> _fetchProduitPaiement() async {

    final DateTime today = DateTime.now();

    String dateDebut;
    String dateFin;

    late final Uri url;

    if (_dateDebut != null && _dateFin != null) {
      dateDebut = _dateFormat.format(_dateDebut!);
      dateFin = _dateFormat.format(_dateFin!);
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-paiementAchat?date_debut=$dateDebut&date_fin=$dateFin');
    } else if (_dateDebut != null) {
      dateDebut = _dateFormat.format(_dateDebut!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-paiementAchat?date_debut=$dateDebut');
    } else if (_dateFin != null) {
      dateDebut = _dateFormat.format(_dateFin!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-paiementAchat?date_fin=$dateFin');
    } else {
      dateDebut = _dateFormat.format(today);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-paiementAchat');
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _paiementAchat = data;
        _totalPourcentage = _paiementAchat.fold(
          0.0,
              (sum, item) => sum + (double.tryParse(item['PrixTotal'].toString()) ?? 0.0),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des données du PaiementAchat')),
      );
    }
  }

  void _deleteProduitByDate(String date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer les achats du $date'),
          content: Text('Êtes-vous sûr de vouloir supprimer les achats pour cette date ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteFromServer(date);
                Navigator.of(context).pop();
                setState(() {
                  _fetchProduitPaiement();
                  _fetchProduitsEntrants();
                });
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFromServer(String date) async {
    final response = await http.delete(
      Uri.parse('https://aldo-bar.gtouch-admin.com/api/delete-produitentrant/$date'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _fetchProduitPaiement();
        _fetchProduitsEntrants();
      });
    } else {
      _showError('Erreur', 'Suppression échouée');
    }
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
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitentrant?date_debut=$dateDebut&date_fin=$dateFin');
    } else if (_dateDebut != null) {
      dateDebut = _dateFormat.format(_dateDebut!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitentrant?date_debut=$dateDebut');
    } else if (_dateFin != null) {
      dateDebut = _dateFormat.format(_dateFin!);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitentrant?date_fin=$dateFin');
    } else {
      dateDebut = _dateFormat.format(today);
      dateFin = dateDebut;
      url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitentrant');
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
        title: Text('Achat : Produit Entrant'),
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
              onPressed: _isLoading ? null : () {
                _fetchProduitsEntrants();
                _fetchProduitPaiement();
              },
              child: Text(_isLoading ? 'Chargement...' : 'Rechercher'),
            ),
            SizedBox(height: screenHeight * 0.023),
            /*Text(
              'Somme Totale : ${NumberFormat("#,##0.00", "fr_FR").format(_totalPrix)} AR',
              style: TextStyle(
                fontSize: screenHeight * 0.020,
                fontWeight: FontWeight.bold,
              ),
            ),*/
            Text(
              'Somme Total : ${NumberFormat("#,##0.00", "fr_FR").format(_totalPourcentage)} AR',
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
                          /*Text(
                            'Prix Total : ${produit['PrixTotal']} AR',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),*/
                          Text(
                            'Date : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(produit['inserted']))}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenHeight * 0.0184,
                            ),
                          ),
                        ],
                      ),
                      onLongPress: () {
                        _deleteProduitByDate(
                          DateFormat('yyyy-MM-dd').format(DateTime.parse(produit['inserted'])),
                        );
                      },
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
