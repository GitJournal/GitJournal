/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class NoteTagEditor extends StatefulWidget {
  final Set<String> selectedTags;
  final Set<String> allTags;

  const NoteTagEditor({required this.selectedTags, required this.allTags});

  @override
  _NoteTagEditorState createState() => _NoteTagEditorState();
}

class _NoteTagEditorState extends State<NoteTagEditor> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  late Set<String> _selectedTags;
  late Set<String> _allTags;

  @override
  void initState() {
    super.initState();

    _selectedTags = Set<String>.from(widget.selectedTags);
    _allTags = Set<String>.from(widget.allTags);
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
          style: theme.textTheme.headline6,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: tr(LocaleKeys.editors_common_tags),
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
    void _onTap() {
      setState(() {
        if (containsTag) {
          var _ = _selectedTags.remove(tag);
        } else {
          var _ = _selectedTags.add(tag);
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
      _ = _selectedTags.add(tag);
      _ = _allTags.add(tag);
      _textController.text = "";
    });
  }
}
