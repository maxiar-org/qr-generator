# Corrección del selector de variantes

El selector usa disposición vertical cuando el ancho disponible o el tamaño de
texto no permiten mostrar cómodamente las tres opciones en una fila. Conserva
la selección única, la tilde y las tres variantes de impresión.

## Entregable visible

- [Mostrador en móvil, 390 × 844](mostrador-390.png).
- [Mostrador en escritorio, 1280 × 900](mostrador-1280.png).

Para reproducir: compilar y servir la app según AGENTS.md, abrir Mercado Pago,
subir `test/fixtures/mercado_pago/link.png`, confirmar y seleccionar Mostrador.

## Verificación

- TDD: los tests nuevos fallaron antes del cambio a 320 y 390 px, con texto
  normal y ampliado al doble. Después pasan las seis combinaciones de ancho
  (320, 390 y 1280 px) y escala (1 y 2), seleccionando las tres variantes.
- Los tests cargan IBM Plex Sans y comprueban que cada nombre ocupa una sola
  línea, cabe completo y actualiza las dimensiones de impresión.
- Playwright: galería, cámara simulada, permisos denegados, QR ajeno, EMVCo,
  copia exacta y exportación de las tres variantes con nueva decodificación.
  También se recorrieron WhatsApp e Instagram, incluida copia y descarga.
- El detector HTML/CSS de Impeccable no aplica al árbol de widgets Flutter.

La aceptación física sigue pendiente: hace falta un iPhone y una Detonger DT01
para verificar Safari, cámara trasera, Fotos, importación en WePrint y lectura
del papel. Registrar modelo, versión de iOS y resultados antes de cerrar esa
aceptación. La simulación de cámara no reemplaza esta prueba.
