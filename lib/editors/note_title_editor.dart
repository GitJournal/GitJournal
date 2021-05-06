import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;
  final Function onChanged;

  NoteTitleEditor(this.textController, this.onChanged);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.headline6;

    return TextField(
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
        hintText: tr('editors.common.defaultTitleHint'),
        border: InputBorder.none,
        isDense: true,
        fillColor: theme.scaffoldBackgroundColor,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      onChanged: (_) => onChanged(),
    );
  }
}
