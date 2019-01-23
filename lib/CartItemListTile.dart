import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CartItemListTile extends StatefulWidget {
  final DocumentSnapshot snapshot;

  CartItemListTile(this.snapshot);

  @override
  FoodItemListTileState createState() {
    return new FoodItemListTileState(snapshot);
  }
}

class FoodItemListTileState extends State<CartItemListTile> {
  final DocumentSnapshot snapshot;

  FoodItemListTileState(this.snapshot);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.all(10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Image.network(
            snapshot["image"],
            fit: BoxFit.cover,
            height: 80.0,
            width: 80.0,
          ),
          new Expanded(
            child: new Padding(
              padding: EdgeInsets.fromLTRB(3.0, 3.0, 3.0, 3.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Padding(
                    child: new Text(
                      snapshot["name"],
                      style: new TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                    padding: EdgeInsets.fromLTRB(5.0, 2.0, 0.0, 1.0),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 6.0, 0.0, 1.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Icon(
                          Icons.info,
                          color: Colors.brown,
                          size: 13.0,
                        ),
                        new Padding(
                          padding: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                          child: new Text(
                            "Free Delivery",
                            style: new TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.brown,
                              fontSize: 12.0,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 1.0),
                    child: new Divider(
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  new Padding(
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            flex: 1,
                            child: new Text(snapshot["rating"].toString(),
                                style: new TextStyle(fontSize: 13.0))),
                        new Expanded(
                            flex: 1,
                            child: new Text("24 mins",
                                style: new TextStyle(fontSize: 13.0))),
                        new Expanded(
                            flex: 1,
                            child: new Text("₹ ${snapshot["price"]}",
                                maxLines: 1,
                                style: new TextStyle(fontSize: 13.0)))
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(5.0, 2.0, 0.0, 1.0),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
