import 'package:flutter/material.dart';

class PublicKeyEditor extends StatelessWidget {
  final Function valueChanged;

  PublicKeyEditor(this.valueChanged);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(valueChanged, _validator);
  }

  String _validator(String val) {
    if (!val.startsWith("ssh-")) {
      return "Invalid Public Key";
    }
    return "";
  }
}

class PrivateKeyEditor extends StatelessWidget {
  final Function valueChanged;

  PrivateKeyEditor(this.valueChanged);

  @override
  Widget build(BuildContext context) {
    return KeyEditor(valueChanged, _validator);
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
  final Function valueChanged;
  final Function validator;

  KeyEditor(this.valueChanged, this.validator);

  @override
  Widget build(BuildContext context) {
    var form = Form(
      child: Builder(builder: (context) {
        return TextFormField(
          textAlign: TextAlign.left,
          maxLines: null,
          style: Theme.of(context).textTheme.body1,
          autovalidate: true,
          validator: validator,
          onChanged: (String newVal) {
            if (Form.of(context).validate()) {
              valueChanged(newVal);
            } else {
              valueChanged("");
            }
          },
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
