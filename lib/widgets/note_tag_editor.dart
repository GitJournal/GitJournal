import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoteTagEditor extends StatefulWidget {
  final Set<String> selectedTags;
  final Set<String> allTags;

  NoteTagEditor({@required this.selectedTags, @required this.allTags});

  @override
  _NoteTagEditorState createState() => _NoteTagEditorState();
}

class _NoteTagEditorState extends State<NoteTagEditor> {
  TextEditingController _textController;

  Set<String> _selectedTags;
  Set<String> _allTags;

  @override
  void initState() {
    super.initState();

    _selectedTags = Set<String>.from(widget.selectedTags);
    _allTags = Set<String>.from(widget.allTags);
    _textController = TextEditingController();
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_selectedTags);
          },
        ),
        title: TextField(
          controller: _textController,
          style: theme.textTheme.headline6,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: tr('editors.common.tags'),
            hintStyle: theme.inputDecorationTheme.hintStyle,
          ),
        ),
      ),
      body: buildView(_textController.text),
    );
  }

  Widget buildView(String query) {
    var q = query.toLowerCase();

    return ListView(
      children: <Widget>[
        if (query.isNotEmpty && !_allTags.contains(query)) _buildAddTag(query),
        for (var tag in _allTags)
          if (tag.toLowerCase().contains(q)) _buildTagTile(tag),
      ],
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
    );
  }

  Widget _buildTagTile(String tag) {
    var containsTag = _selectedTags.contains(tag);
    var _onTap = () {
      setState(() {
        if (containsTag) {
          _selectedTags.remove(tag);
        } else {
          _selectedTags.add(tag);
        }
      });
    };
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.tag),
      title: Text(tag),
      trailing: Checkbox(value: containsTag, onChanged: (_) => _onTap()),
      onTap: _onTap,
    );
  }

  Widget _buildAddTag(String tag) {
    return ListTile(
      leading: const Icon(Icons.add),
      title: Text(tag),
      onTap: () {
        setState(() {
          _selectedTags.add(tag);
          _allTags.add(tag);
          _textController.text = "";
        });
      },
    );
  }
}
