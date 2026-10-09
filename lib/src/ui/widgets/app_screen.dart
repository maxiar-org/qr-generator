import 'package:flutter/material.dart';

import '../../domain/qr_label_type.dart';
import '../theme/app_theme.dart';
import 'app_drawer.dart';
import 'app_logo.dart';

/// Armazón compartido por las pantallas de la app: cabecera de marca (logo +
/// "Generador de QR", constante en toda la app, con el botón "Atrás" cuando
/// corresponde) + menú lateral de tipos de QR + columna centrada de ancho
/// máximo 600px con el mismo padding de `DESIGN.md`. Evita repetir el mismo
/// `Scaffold`/`SafeArea`/`ConstrainedBox` pantalla por pantalla.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    this.screenTitle,
    required this.children,
    this.currentType,
  });

  /// Título de la pantalla actual, mostrado como encabezado dentro del
  /// cuerpo (p. ej. "WhatsApp"). `null` en Inicio, donde el nombre de la app
  /// ya cumple ese rol en la cabecera.
  final String? screenTitle;
  final List<Widget> children;

  /// Tipo de QR de esta pantalla, para resaltarlo en el menú lateral.
  /// `null` cuando la pantalla no corresponde a un tipo (Inicio, ayuda de
  /// WePrint).
  final QrLabelType? currentType;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const AppBrandTitle(),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú de tipos de QR',
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    ),
    endDrawer: AppDrawer(currentType: currentType),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (screenTitle != null) ...[
                Text(
                  screenTitle!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}
