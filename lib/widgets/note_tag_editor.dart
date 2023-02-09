/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitjournal/l10n.dart';

class NoteTagEditor extends StatefulWidget {
  final ISet<String> selectedTags;
  final ISet<String> allTags;

  const NoteTagEditor({required this.selectedTags, required this.allTags});

  @override
  _NoteTagEditorState createState() => _NoteTagEditorState();
}

class _NoteTagEditorState extends State<NoteTagEditor> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  late ISet<String> _selectedTags;
  late ISet<String> _allTags;

  @override
  void initState() {
    super.initState();

    _selectedTags = widget.selectedTags;
    _allTags = widget.allTags;
    _focusNode = FocusNode();
    _textController = TextEditingController();
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var s = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_selectedTags);
          },
        ),
        title: TextField(
          focusNode: _focusNode,
          controller: _textController,
          style: theme.textTheme.titleLarge,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.loc.editorsCommonTags,
            hintStyle: theme.inputDecorationTheme.hintStyle,
          ),
          onSubmitted: _addTag,
        ),
      ),
      body: buildView(_textController.text),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _focusNode.requestFocus();
        },
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_selectedTags);
        return false;
      },
      child: s,
    );
  }

  Widget buildView(String query) {
    var q = query.toLowerCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      children: <Widget>[
        if (query.isNotEmpty && !_allTags.contains(query)) _buildAddTag(query),
        for (var tag in _allTags)
          if (tag.toLowerCase().contains(q)) _buildTagTile(tag),
      ],
    );
  }

  Widget _buildTagTile(String tag) {
    var containsTag = _selectedTags.contains(tag);
    void _onTap() {
      setState(() {
        if (containsTag) {
          _selectedTags = _selectedTags.remove(tag);
        } else {
          _selectedTags = _selectedTags.add(tag);
        }
      });
    }

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
      onTap: () => _addTag(tag),
    );
  }

  void _addTag(String tag) {
    setState(() {
      dynamic _;
      _selectedTags = _selectedTags.add(tag);
      _allTags = _allTags.add(tag);
      _textController.text = "";
    });
  }
}
