import 'package:flutter/material.dart';

class Journal {
  final DateTime creationDateTime;
  final String body;

  const Journal({this.creationDateTime, this.body});

  factory Journal.fromJson(Map<String, dynamic> json) {
    return new Journal(
      creationDateTime: json['creationDateTime'],
      body: json['body'],
    );
  }
}

// How to load this dynamically?
// I can put this in a widget with a state
// and do an async call.
var state = <Journal>[
  Journal(
    creationDateTime: new DateTime.now(),
    body: "The quick brown fox jumped over the very lazy dog, who then ran"
        "all around the garden untill he fell down",
  ),
  Journal(
    creationDateTime: new DateTime.now().subtract(new Duration(days: 1)),
    body: "This is the body",
  ),
];

void main() => runApp(new MyApp());

class JournalList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    var createButton = new FloatingActionButton(
      onPressed: () => _newPost(context),
      child: new Icon(Icons.add),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Journal'),
      ),
      body: _buildSuggestions(context),
      floatingActionButton: createButton,
    );
  }

  Widget _buildRow(BuildContext context, Journal journal) {
    var title = journal.creationDateTime.toString();
    var time = "10:24";
    var body = journal.body;

    return new ListTile(
      isThreeLine: true,
      title: new Text(
        title,
        style: _biggerFont,
      ),
      subtitle: new Text(time + "\n" + body),
      onTap: () => _itemTapped(context, title, body),
    );
  }

  void _itemTapped(BuildContext context, String title, String body) {
    // FIXME: Add some kind of a header?
    body = """Hello

This is a sample note. Blah Blooh foo foo foo foo bfoooo
The quick brown fox
jumped over the lazy dog.
So now what is going to happen?
    """;

    var bodyWidget = new SingleChildScrollView(
      child: new Text(body, style: _biggerFont),
      padding: const EdgeInsets.all(8.0),
    );

    var showJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: bodyWidget,
    );

    var route = new MaterialPageRoute(builder: (context) => showJournalScreen);
    Navigator.of(context).push(route);
  }

  Widget _buildSuggestions(BuildContext context) {
    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, i) {
        if (i >= state.length) {
          return null;
        }
        //if (i.isOdd) return new Divider();
        return _buildRow(context, state[i]);
      },
    );
  }

  void _newPost(BuildContext context) {
    var bodyWidget = new Container(
      child: new TextField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: 500,
        decoration: new InputDecoration(
          hintText: 'Write here',
        ),
      ),
      padding: const EdgeInsets.all(8.0),
    );

    var newJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text("May 15, 17:35"),
      ),
      body: bodyWidget,
    );

    var route = new MaterialPageRoute(builder: (context) => newJournalScreen);
    Navigator.of(context).push(route);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Journal', home: new JournalList());
  }
}
