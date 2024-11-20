import 'package:demo_gestion/homePage.dart';
import 'package:demo_gestion/test_page.dart';
import 'package:flutter/material.dart';
import 'package:demo_gestion/widgets/NavBar.dart';

class HomeAccueil extends StatefulWidget{
  @override
  _HomeAccueilState createState() => _HomeAccueilState();
}

class _HomeAccueilState extends State<HomeAccueil> {
  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: NavBar(),
      backgroundColor: Color.fromRGBO(244, 243, 243, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
                ),
                padding: EdgeInsets.all(screenHeight * 0.023),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Grossiste', style: TextStyle(color: Colors.black87, fontSize: screenHeight * 0.028),),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Text('Manandona', style: TextStyle(color: Colors.black, fontSize: screenHeight * 0.04, fontWeight: FontWeight.bold),),
                    SizedBox(
                      height: screenHeight * 0.023,
                    ),
                    /*Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 243, 243, 1),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.black87,),
                          hintText: "Search you're looking for",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),*/
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.023,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.023),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ajout', style: TextStyle(fontSize: screenHeight * 0.017, fontWeight: FontWeight.bold),),
                      SizedBox(height: screenHeight * 0.017),
                      Container(
                        height: screenHeight * 0.23,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            promoCard('assets/images/ajout-vente.jpg','Vente', '/ajout-vente'),
                            promoCard('assets/images/ajout-achat.jpg','Achat', '/ajout-achat'),
                            promoCard('assets/images/ajout-caisse.jpg','Mouvement Caisse','/ajout-mvtcaisse'),
                            promoCard('assets/images/ajout-mycagot.jpg','Bouteille','/ajout-mycagot'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.023,
                      ),
                      Text('Details', style: TextStyle(fontSize: screenHeight * 0.017, fontWeight: FontWeight.bold),),
                      SizedBox(height: screenHeight * 0.017),
                      Container(
                        height: screenHeight * 0.23,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            promoCard('assets/images/detail-produit.jpg','Produit','/detail-produit'),
                            promoCard('assets/images/detail-achat.jpg','Achat','/detail-achat'),
                            promoCard('assets/images/detail-vente.jpg','Vente','/detail-vente'),
                            promoCard('assets/images/detail-caisse.jpg','Mouvement Caisse','/detail-mvtcaisse'),
                            promoCard('assets/images/detail-mycagot.jpg','Mes Bouteilles','/detail-mycagot'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.023,
                      ),
                      /*Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/three.jpg')
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  begin: Alignment.bottomRight,
                                  stops: [0.3, 0.9],
                                  colors: [
                                    Colors.black.withOpacity(.8),
                                    Colors.black.withOpacity(.2)
                                  ]
                              ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child : Text('Produit', style: TextStyle(color: Colors.white, fontSize: 20),),
                          ),
                        ),
                        ),
                      )*/
                    ],
                  ),
              )
            ],
          )),
    );
  }

  Widget promoCard(String image, String text, String route) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: AspectRatio(
        aspectRatio: 2.60 / 3,
        child: Container(
          margin: EdgeInsets.only(right: screenHeight * 0.017),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenHeight * 0.023),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(image),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenHeight * 0.023),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                stops: [0.1, 0.9],
                colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.1),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.017),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.023),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

