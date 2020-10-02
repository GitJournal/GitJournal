import 'dart:io';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';

import 'package:gitjournal/utils/logger.dart';

class PublicKeyEditor extends StatelessWidget {
  final Key formKey;
  final TextEditingController _controller;

  PublicKeyEditor(this.formKey, this._controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(formKey, _controller, _validator);
  }

  String _validator(String val) {
    val = val.trim();
    if (!val.startsWith("ssh-rsa ")) {
      return tr("setup.keyEditors.public");
    }
    return null;
  }
}

class PrivateKeyEditor extends StatelessWidget {
  final Key formKey;
  final TextEditingController _controller;

  PrivateKeyEditor(this.formKey, this._controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(formKey, _controller, _validator);
  }

  String _validator(String val) {
    val = val.trim();
    if (!val.startsWith("-----BEGIN ")) {
      return tr("setup.keyEditors.private");
    }
    if (!val.endsWith("PRIVATE KEY-----")) {
      return tr("setup.keyEditors.private");
    }

    return null;
  }
}

class KeyEditor extends StatelessWidget {
  final Key formKey;
  final TextEditingController textEditingController;
  final Function validator;

  KeyEditor(this.formKey, this.textEditingController, this.validator) {
    assert(formKey != null);
    assert(textEditingController != null);
    assert(validator != null);
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: formKey,
      child: Builder(builder: (context) {
        return TextFormField(
          textAlign: TextAlign.left,
          maxLines: null,
          style: Theme.of(context).textTheme.bodyText2,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          controller: textEditingController,
        );
      }),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );

    var screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height / 4,
          ),
          color: Theme.of(context).buttonColor,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: form,
            ),
          ),
        ),
        OutlineButton(
          child: Text(tr("setup.keyEditors.load")),
          onPressed: _pickAndLoadFile,
        ),
      ],
    );
  }

  void _pickAndLoadFile() async {
    var result = await FilePicker.platform.pickFiles();

    if (result != null) {
      var file = File(result.files.single.path);
      try {
        var data = await file.readAsString();
        textEditingController.text = data.trim();
      } catch (e, stackTrace) {
        Log.e(
          "Open File for importing SSH Key",
          ex: e,
          stacktrace: stackTrace,
        );
      }
    }
  }
}
