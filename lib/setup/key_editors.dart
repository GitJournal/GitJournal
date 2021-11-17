/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/logger/logger.dart';

class PublicKeyEditor extends StatelessWidget {
  final Key formKey;
  final TextEditingController _controller;

  const PublicKeyEditor(this.formKey, this._controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(formKey, _controller, _validator);
  }

  String? _validator(String? val) {
    if (val == null) {
      return null;
    }

    val = val.trim();
    if (!val.startsWith("ssh-")) {
      return tr("setup.keyEditors.public");
    }
    return null;
  }
}

class PrivateKeyEditor extends StatelessWidget {
  final Key formKey;
  final TextEditingController _controller;

  const PrivateKeyEditor(this.formKey, this._controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(formKey, _controller, _validator);
  }

  String? _validator(String? val) {
    if (val == null) {
      return null;
    }

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
  final String? Function(String?) validator;

  const KeyEditor(this.formKey, this.textEditingController, this.validator);

  @override
  Widget build(BuildContext context) {
    var inputField = Builder(builder: (context) {
      return TextFormField(
        textAlign: TextAlign.left,
        maxLines: null,
        style: Theme.of(context).textTheme.bodyText2,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        controller: textEditingController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      );
    });

    var screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height / 4,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: inputField,
            ),
          ),
        ),
        OutlinedButton(
          child: Text(
            tr("setup.keyEditors.load"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          onPressed: _pickAndLoadFile,
        ),
      ],
    );
  }

  Future<void> _pickAndLoadFile() async {
    var result = await FilePicker.platform.pickFiles();

    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      var file = File(result.files.single.path!);
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
