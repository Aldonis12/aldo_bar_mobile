import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MouvementCaissePage extends StatefulWidget {
  @override
  _MouvementCaissePageState createState() => _MouvementCaissePageState();
}

class _MouvementCaissePageState extends State<MouvementCaissePage> {
  String _selectedDate = '';
  String? _typeMouvement;
  List<dynamic> _mouvements = [];
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> fetchMouvements() async {
    setState(() {
      _isLoading = true;
    });

    final String url = 'https://aldo-bar.gtouch-admin.com/api/get-mvtcaisse';
    try {
      final response = await http.get(
        Uri.parse('$url?date=$_selectedDate&type=$_typeMouvement'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _mouvements = json.decode(response.body);
        });
      } else {
        _showError('Erreur', 'Impossible de récupérer les données');
      }
    } catch (e) {
      _showError('Erreur', 'Erreur de connexion');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Mouvements de Caisse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
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
                SizedBox(width: screenHeight * 0.011),
                Text(
                  _selectedDate.isEmpty
                      ? 'Aucune date sélectionnée'
                      : 'Date: $_selectedDate',
                  style: TextStyle(fontSize: screenHeight * 0.0184),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.0184),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Type de Mouvement'),
              value: _typeMouvement,
              items: [
                DropdownMenuItem(
                  value: '0',
                  child: Text('Entrée'),
                ),
                DropdownMenuItem(
                  value: '1',
                  child: Text('Sortie'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _typeMouvement = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.0184),
            ElevatedButton(
              onPressed: fetchMouvements,
              child: Text('Rechercher'),
            ),
            SizedBox(height: screenHeight * 0.023),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: _mouvements.isEmpty
                  ? Center(child: Text('Aucun mouvement trouvé'))
                  : ListView.builder(
                itemCount: _mouvements.length,
                itemBuilder: (context, index) {
                  final mouvement = _mouvements[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Prix: ${mouvement['prix']} Ar'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${mouvement['typeMouvement'] == '0' ? 'Entrée' : 'Sortie'}'),
                          Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(mouvement['inserted']))}'),
                          Text('Description: ${mouvement['libelle']}'),
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
