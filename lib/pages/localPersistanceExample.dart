import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import  'dart:io'; //for the DatabaseFileRoutines to save and read files
import 'package:path_provider/path_provider.dart'; //for the above class to retrieve the local path to the document directory.
import 'dart:convert'; //for database class to decode and encode JSON
import 'dart:async';

class LocalPersistance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _LocalPersistanceState();
  }


}


class _LocalPersistanceState extends State<LocalPersistance> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Example')
      ),
      body: new Text("local Persistance")
    );
  }

}


class DatabaseFileRoutines {
  DatabaseFileRoutines() {

  }

  //uses the File class to retrive the device local document directory and save and read the data file
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //calls _localPath and returns the persistance file
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }


}


class Database {
  //responsible for encoding and decoding the JSON file and mapping it to a List

}

class Journal {
  //maps each journal entry from and to JSON
}

class JournalEdit {
  //to pass an action (save or cancel) and a journal entry between pages

}