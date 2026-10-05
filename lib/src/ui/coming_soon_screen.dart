import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.type});

  final QrLabelType type;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(type.displayName)),
    body: const SafeArea(child: Center(child: Text('Próximamente'))),
  );
}
