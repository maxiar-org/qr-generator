import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Armazón compartido por las pantallas de la app: `AppBar` + columna
/// centrada de ancho máximo 600px + el mismo padding de `DESIGN.md`. Evita
/// repetir el mismo `Scaffold`/`SafeArea`/`ConstrainedBox` pantalla por
/// pantalla.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.title,
    required this.children,
    this.leading,
  });

  final String title;
  final List<Widget> children;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), leading: leading),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: children,
          ),
        ),
      ),
    ),
  );
}
