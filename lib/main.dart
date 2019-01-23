import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_food/CartItemListTile.dart';


Future<Food> fetchFood() async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Food.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Food {
  final String name;
  final double rating;
  final double price;
  final String imageUrl;
  final int quantity;
  final DocumentReference reference;

  Food(
      {this.name,
      this.rating,
      this.price,
      this.imageUrl,
      this.quantity,
      this.reference});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['item_name'],
      rating: json['average_rating'],
      price: json['item_price'],
      imageUrl: json['image_url'],
      quantity: 0,
    );
  }

  Food.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        rating = map['rating'],
        price = map['price'],
        quantity = map['quantity'],
        imageUrl = map['image'];

  Food.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record: $name";
}

void main() {
  runApp(SampleApp(
    food: fetchFood(),
  ));
}

class SampleApp extends StatelessWidget {
  final Future<Food> food;

  SampleApp({Key key, this.food}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleAppPage(),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  @override
  void initState() {
    super.initState();

    //loadData();
  }

  void _pushItemsinCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CartPage()));
  }

  void _showSnackbar(BuildContext context, String message) {
   final snackBar = SnackBar(
     content: Text(message),
   );

   Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Widget getRow(DocumentSnapshot snapshot, BuildContext context) {
      return new ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: Image.network(
            snapshot["image"],
            width: 84.0,
            height: 84.0,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Text(
                "${snapshot["name"]}",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.indeterminate_check_box,
                color: Colors.black,
              ),
              onPressed: () {
                Firestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot freshSnap =
                                  await transaction.get(snapshot.reference);
                  if(freshSnap['quantity'] != 0)
                  await transaction.update(freshSnap.reference, {
                      'quantity' : freshSnap['quantity'] - 1
                  });
                });

                _showSnackbar(context, "Removed from cart!");
              },
            ),
            Text(snapshot["quantity"].toString()),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                Firestore.instance.runTransaction((transaction) async {
                    DocumentSnapshot freshSnap =
                        await transaction.get(snapshot.reference);
                    await transaction.update(freshSnap.reference, {
                      "quantity": freshSnap['quantity'] + 1
                    });

                    _showSnackbar(context, "Added to cart!");
                });
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(document: snapshot)));
        },
        // ... to here.
      );
    }

    Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
      return Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            child: getRow(snapshot, context),
          ));
    }

    Widget _buildBody(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('food').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, int index) =>
                _buildListItem(context, snapshot.data.documents[index]),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Food App"),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.shopping_cart),
              onPressed: _pushItemsinCart),
        ],
      ),
      body: Builder(builder: (BuildContext context){
        return _buildBody(context);
      }),
    );
  }

//  loadData() async {
//    String dataURL = "https://android-full-time-task.firebaseio.com/data.json";
//    http.Response response = await http.get(dataURL);
//    setState(() {
//      foodItems = json.decode(response.body);
//    });
//  }

}

class DetailPage extends StatelessWidget {
  final DocumentSnapshot document;
  DetailPage({Key key, this.document}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(document["name"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    document["image"],
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            Expanded(
              child: Text(
                document["desc"],
                style: TextStyle(fontSize: 18.0, ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text("remove"),
                    padding: const EdgeInsets.all(12.0),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: (){},
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("add"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){},
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Code for Cart screen
class CartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Food App"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('food')
          .where('quantity', isGreaterThan: 0).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, int index) {
            return new InkWell(
                child: new CartItemListTile(snapshot.data.documents[index]));
          }
        );
      },
    );

  }
}
