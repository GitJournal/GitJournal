import 'package:flutter/material.dart';

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
      return "Invalid Public Key - Doesn't start with ssh-rsa";
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
      return "Invalid Private Key";
    }
    if (!val.endsWith("PRIVATE KEY-----")) {
      return "Invalid Private Key";
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
          autovalidate: true,
          validator: validator,
          controller: textEditingController,
        );
      }),
      autovalidate: true,
    );

    return SizedBox(
      width: double.infinity,
      height: 80.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: form,
          ),
        ),
      ),
    );
  }
}
