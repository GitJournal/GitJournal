import 'package:flutter/material.dart';

class FutureBuilderWithProgress<T> extends StatelessWidget {
  final Future<T> future;

  const FutureBuilderWithProgress({
    Key? key,
    required this.future,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const CircularProgressIndicator();
      },
      future: future,
    );
  }
}
