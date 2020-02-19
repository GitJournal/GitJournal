import 'package:flutter/material.dart';

class PublicKeyEditor extends StatelessWidget {
  final TextEditingController controller;

  PublicKeyEditor(this.controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(controller, _validator);
  }

  String _validator(String val) {
    if (!val.startsWith("ssh-")) {
      return "Invalid Public Key";
    }
    return "";
  }
}

class PrivateKeyEditor extends StatelessWidget {
  final TextEditingController controller;

  PrivateKeyEditor(this.controller);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(controller, _validator);
  }

  String _validator(String val) {
    if (!val.startsWith("-----BEGIN RSA PRIVATE KEY-----")) {
      return "Invalid Private Key";
    }
    if (!val.startsWith("-----END RSA PRIVATE KEY-----")) {
      return "Invalid Private Key";
    }
    return "";
  }
}

class KeyEditor extends StatelessWidget {
  final TextEditingController controller;
  final Function validator;

  KeyEditor(this.controller, this.validator);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.left,
              maxLines: null,
              style: Theme.of(context).textTheme.body1,
              autovalidate: true,
              validator: validator,
            ),
          ),
        ),
      ),
    );
  }
}
