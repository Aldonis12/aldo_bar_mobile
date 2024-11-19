import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatistiquesProduitsPage extends StatefulWidget {
  @override
  _StatistiquesProduitsPageState createState() =>
      _StatistiquesProduitsPageState();
}

class _StatistiquesProduitsPageState extends State<StatistiquesProduitsPage> {
  Map<String, double> productData = {};

  @override
  void initState() {
    super.initState();
    fetchProduitSortantData();
  }

  Future<void> fetchProduitSortantData() async {
    final url = Uri.parse('https://aldo-bar.gtouch-admin.com/api/get-produitsortant');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> produitsSortants = json.decode(response.body);

      final Map<String, double> dataByProduct = {};

      for (var produit in produitsSortants) {
        String? produitNom = produit['Produit']?['nom'];
        if (produitNom == null) continue;

        double quantite = double.tryParse(produit['quantite']?.toString() ?? '0') ?? 0.0;

        // Ajouter ou accumuler la quantité pour ce produit
        dataByProduct.update(produitNom, (value) => value + quantite, ifAbsent: () => quantite);
      }

      setState(() {
        productData = dataByProduct;
      });
    } else {
      throw Exception('Échec du chargement des données');
    }
  }

  List<BarChartGroupData> generateBars() {
    int colorIndex = 0;
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];

    List<BarChartGroupData> barGroups = [];
    productData.forEach((productName, quantity) {
      barGroups.add(
        BarChartGroupData(
          x: colorIndex, // L'index du produit
          barRods: [
            BarChartRodData(
              toY: quantity, // Quantité vendue
              color: colors[colorIndex % colors.length], // Couleur de la barre
              width: 30,
            ),
          ],
        ),
      );
      colorIndex++;
    });

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques des Produits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: productData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // Afficher le nom du produit sur l'axe des X
                    List<String> productNames = productData.keys.toList();
                    return Text(
                      productNames[value.toInt()],
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
            barGroups: generateBars(),
          ),
        ),
      ),
    );
  }
}
