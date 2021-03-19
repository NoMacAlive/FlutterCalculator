import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io'; //for the DatabaseFileRoutines to save and read files
import 'package:path_provider/path_provider.dart'; //for the above class to retrieve the local path to the document directory.
import 'dart:convert'; //for database class to decode and encode JSON
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_app/pages/edit_entry.dart';



/*The DatabaseFileRoutines class handles locating the device’s local document directory path through
the path_provider package. You used the File class to handle the saving and reading of the database
file by importing the dart:io library. The file is text-based containing the key/value pair of
JSON objects.
The Database class uses json.encode and json.decode to serialize and deserialize JSON objects
by importing the dart:convert library. You use the Database.fromJson named constructor to
retrieve and map the JSON objects to a List<Journal>. You use the toJson() method to convert the
List<Journal> to JSON objects.
The Journal class is responsible for tracking individual journal entries through the String id, date,
mood, and note variables. You use the Journal.fromJson() named constructor to take the argument of
Map<String, dynamic>, which maps the String key with a dynamic value, the JSON key/value pair.
You use the toJson() method to convert the Journal class into a JSON object.
The JournalEdit class is used to pass data between pages. You declared a String action variable and
a Journal journal variable. The action variable passes an action to 'Save' or 'Cancel', editing an
entry. You learn’ll to use the JournalEdit class in the “Creating the Journal Entry Page” and “Finishing
the Home Page” exercises. The journal variable passes the journal entry values.*/
class LocalPersistance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _LocalPersistanceState();
  }
}

class _LocalPersistanceState extends State<LocalPersistance> {
  Database _database;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(title: new Text('Journal List')),
      body: FutureBuilder(
        initialData: [],
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : _buildListViewSeparated(snapshot);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(24.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: Icon(Icons.add),
        onPressed: () {
          _addOrEditJournal(add: true, index: -1, journal: Journal());
        },
      ),
    );
  }

  void _addOrEditJournal({bool add, int index, Journal journal}) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EditEntry(
                add: add,
                index: index,
                journalEdit: _journalEdit,
              ),
          fullscreenDialog: true
      ),
    );
    switch (_journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journal.add(_journalEdit.journal);
          });
        } else {
          setState(() {
            _database.journal[index] = _journalEdit.journal;
          });
        }
        DatabaseFileRoutines().writeJournals(databaseToJson(_database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  Future<List<Journal>> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalsJson) {
      _database = databaseFromJson(journalsJson);
      _database.journal.sort((comp1, comp2) =>
          comp2.date.compareTo(comp1.date));
    });
    return _database.journal;
  }

  // Build the ListView with Separator
  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        String _titleDate = DateFormat.yMMMd().format(DateTime.parse(snapshot
            .data[index].date));
        String _subtitle = snapshot.data[index].mood + "\n" + snapshot
            .data[index].note;
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Column(
              children: <Widget>[
                Text(DateFormat.d().format(
                    DateTime.parse(snapshot.data[index].date)),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.blue),
                ),
                Text(DateFormat.E().format(
                    DateTime.parse(snapshot.data[index].date))),
              ],
            ),
            title: Text(
              _titleDate,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_subtitle),
            onTap: () {
              _addOrEditJournal(
                add: false,
                index: index,
                journal: snapshot.data[index],
              );
            },
          ),
          onDismissed: (direction) {
            setState(() {
              _database.journal.removeAt(index);
            });
            DatabaseFileRoutines().writeJournals(databaseToJson(_database));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey,
        );
      },
    );
  }
}


class DatabaseFileRoutines {

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

  //read from file and return a future string containing the JSON information
  Future<String> readJournals() async {
    try {
      final file = await _localFile;
      //if no such file, create one
      if (!file.existsSync()) {
        print("File does not Exist: ${file.absolute}");
        await writeJournals('{"journals": []}');
      }
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print("error readJournals: $e");
      return "";
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$json');
  }

}
// To read and parse from JSON data - databaseFromJson(jsonString);
Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str);
  return Database.fromJson(dataFromJson);
}

// To save and parse to JSON Data - databaseToJson(jsonString);
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

class Database {
  //responsible for encoding and decoding the JSON file and mapping it to a List
  List<Journal> journal;
  Database({
    this.journal,
  });

  // To read and parse from JSON data - databaseFromJson(jsonString);
  Database databaseFromJson(String str) {
    final dataFromJson = json.decode(str);
    return Database.fromJson(dataFromJson);
  }

  /*factory method returns a database instance*/
  factory Database.fromJson(Map<String, dynamic> json) => Database(
    journal: List<Journal>.from(json["journals"].map((x) => Journal.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
  };
}

class Journal {
  //maps each journal entry from and to JSON
  String id;
  String date;
  String mood;
  String note;
  Journal({
    this.id,
    this.date,
    this.mood,
    this.note,
  });

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
    id: json["id"],
    date: json["date"],
    mood: json["mood"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "mood": mood,
    "note": note,
  };

}

class JournalEdit {
  //to pass an action (save or cancel) and a journal entry between pages
  String action;
  Journal journal;
  JournalEdit({this.action, this.journal});
}
