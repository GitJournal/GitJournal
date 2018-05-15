import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class JournalList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    var createButton = new FloatingActionButton(
      onPressed: _newPost,
      child: new Icon(Icons.add),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Journal'),
      ),
      body: _buildSuggestions(),
      floatingActionButton: createButton,
    );
  }

  Widget _buildRow() {
    var body = "The quick brown fox jumped over the very lazy dog, who then ran"
        "all around the garden untill he fell down";

    return new ListTile(
      isThreeLine: true,
      title: new Text(
        "May 5, 2018",
        style: _biggerFont,
      ),
      subtitle: new Text("10:24" + "\n" + body),
      onTap: () {
        print("Item tapped");
      },
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        return _buildRow();
      },
    );
  }

  void _newPost() {
    print("FOoOO");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Journal', home: new JournalList());
  }
}
