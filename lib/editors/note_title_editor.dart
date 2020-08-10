import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;
  final Function onChanged;

  NoteTitleEditor(this.textController, this.onChanged);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.headline6;

    return TextField(
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
        hintText: tr('editors.common.defaultTitleHint'),
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      onChanged: (_) => onChanged(),
    );
  }
}
