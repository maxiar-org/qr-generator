import 'package:flutter/material.dart';

import '../../domain/qr_label_type.dart';
import '../../printing/label_icons.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';
import 'qr_type_navigation.dart';

/// Menú lateral con los tipos de QR, abierto desde el ícono de menú de
/// `AppScreen` en cualquier pantalla.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.currentType});

  /// Tipo de QR de la pantalla actual, para resaltarlo en la lista.
  final QrLabelType? currentType;

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.paper,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: AppBrandTitle(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          for (final type in QrLabelType.values) _DrawerTile(type: type, currentType: currentType),
        ],
      ),
    ),
  );
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.type, required this.currentType});

  final QrLabelType type;
  final QrLabelType? currentType;

  @override
  Widget build(BuildContext context) {
    final selected = type == currentType;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListTile(
          selected: selected,
          // El color de selección ya lo da el fondo Superficie + borde de
          // arriba; se fija acá para que `selected` sólo aporte semántica
          // (lector de pantalla) sin que Material tiña el texto/ícono con
          // el color primario por defecto.
          selectedColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: selected ? AppColors.border : Colors.transparent,
            ),
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: qrTypeAccent(type),
            foregroundColor: Colors.white,
            child: Icon(labelIconFor(type), size: 18),
          ),
          title: Text(
            type.displayName,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          onTap: () => selected
              ? Navigator.of(context).pop()
              : openQrType(context, type),
        ),
      ),
    );
  }
}
