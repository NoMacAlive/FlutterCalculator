import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FireStoreExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _FireStoreState();
  }


}


class _FireStoreState extends State<FireStoreExample> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Example'),
      ),
      body: new Text("FireStore"),
    );
  }

}