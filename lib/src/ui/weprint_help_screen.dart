import 'package:flutter/material.dart';

import 'widgets/app_screen.dart';

class WePrintHelpScreen extends StatelessWidget {
  const WePrintHelpScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScreen(
    screenTitle: 'Cómo imprimir con WePrint',
    children: const [
      ListTile(
        title: Text('1. Guardá la imagen'),
        subtitle: Text(
          'Tocá Guardar imagen y elegí Guardar imagen en la hoja de compartir. '
          'Si se descarga, abrí el PNG desde Descargas de Safari y usá '
          'Compartir → Guardar imagen para llevarlo a Fotos.',
        ),
      ),
      ListTile(title: Text('2. Abrí WePrint')),
      ListTile(title: Text('3. Creá una nueva etiqueta')),
      ListTile(title: Text('4. Tocá Imagen')),
      ListTile(
        title: Text('5. Elegí la foto'),
        subtitle: Text('Seleccioná la etiqueta que acabás de guardar en Fotos.'),
      ),
      ListTile(
        title: Text('6. Imprimí'),
        subtitle: Text(
          'Revisá la vista previa y mandá a imprimir desde WePrint.',
        ),
      ),
    ],
  );
}
