import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/new_note_nav_bar.dart';
import 'package:provider/provider.dart';

class BottomMenuBarSettings extends StatefulWidget {
  @override
  _BottomMenuBarSettingsState createState() => _BottomMenuBarSettingsState();
}

class _BottomMenuBarSettingsState extends State<BottomMenuBarSettings> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var body = Column(
      children: [
        Center(
          child: NewNoteNavBar(
            onPressed: (_) {},
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(tr("settings.bottomMenuBar.enable")),
          value: settings.bottomMenuBar,
          onChanged: (bool newVal) {
            setState(() {
              settings.bottomMenuBar = newVal;
              settings.save();
            });
          },
        ),
      ],
    );

    /*
    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(widget.notesFolder.config.defaultEditor),
      child: const Icon(Icons.add),
    );
    */

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.bottomMenuBar.title")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }
}
