import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddMouvementCaissePage extends StatefulWidget {
  @override
  _AddMouvementCaissePageState createState() => _AddMouvementCaissePageState();
}

class _AddMouvementCaissePageState extends State<AddMouvementCaissePage> {
  final _formKey = GlobalKey<FormState>();
  String? _typeMouvement = '1';
  String? _prix;
  String? _description;
  String _selectedDate = '';
  bool _isSubmitting = false;

  Future<void> addMouvementCaisse() async {
    final String url = 'https://aldo-bar.gtouch-admin.com/api/add-mvtcaisse';

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_isSubmitting) {
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'typeMouvement': _typeMouvement,
            'prix': _prix,
            'libelle': _description,
            'date': _selectedDate,
          }),
        );

        if (response.statusCode == 201) {
          _showDialog('Succès', 'Mouvement ajouté avec succès');
        } else {
          _showDialog('Erreur', 'Erreur lors de l\'ajout du mouvement');
        }
      } catch (e) {
        _showDialog('Erreur', 'Erreur de connexion');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showDialog(String title, String content) {
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
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _typeMouvement = '1';
      _prix = '';
      _description = '';
      _selectedDate = '';
      _formKey.currentState?.reset();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un Mouvement Caisse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
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
                validator: (value) {
                  if (value == null) {
                    return 'Sélectionnez un type de mouvement';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
                onSaved: (value) => _prix = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLength: 100,
                maxLines: 3,
                onSaved: (value) => _description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est obligatoire';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.0184),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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

              SizedBox(height: screenHeight * 0.023),

              ElevatedButton(
                onPressed: _isSubmitting ? null : addMouvementCaisse,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
