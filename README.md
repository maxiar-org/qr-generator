# Generador de QR

App Flutter para cartelería de comercios de Argentina. WhatsApp permite generar
un QR con un celular argentino y un mensaje opcional. Instagram, Google Reseñas
y Mercado Pago abren Próximamente.

## Probar con Docker

```sh
docker compose up --build
```

Abrí http://localhost:8080. Para detenerlo: Ctrl+C y `docker compose down`.
Necesitás Docker con el daemon activo, Compose e Internet para el primer build.

## Desarrollo

Con Flutter 3.47.6 stable:

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Las plataformas generadas son web e iOS. Encontrás la estructura y las
instrucciones para iOS en [AGENTS.md](AGENTS.md).

## Probar el QR de WhatsApp

1. Ejecutá `docker compose up --build` y abrí http://localhost:8080.
2. Entrá en **WhatsApp**, ingresá tu celular con código de área (por ejemplo,
   `011 15 2345-6789`) y, si querés, un mensaje de hasta 300 caracteres.
3. Tocá **Generar QR**. Debajo aparece el QR y el enlace de destino.
4. Escanealo desde otro celular: WhatsApp abre el chat y prepara el mensaje.
   Usá un número real registrado en WhatsApp para esta prueba.
5. Probá `123`: aparece un error y no se muestra un QR anterior.

La normalización acepta 10 dígitos nacionales, opcionalmente precedidos por `0`,
o el formato internacional `+549` / `549` seguido de esos 10 dígitos. Para el
formato doméstico con `15`, quita el `0` inicial y busca `15` después de 2, 3 o 4
dígitos de área, sólo si quedan 12 dígitos antes de quitarlo. Debe haber una única
separación posible; si hay más de una, ingresá el número sin `0` ni `15`. Un `15`
dentro de un número que ya tiene 10 dígitos se conserva. Se permiten espacios,
guiones y paréntesis. El número nacional debe comenzar con 1, 2 o 3.

Se valida la estructura: no se consulta un padrón de áreas, ni se comprueba que el
número esté asignado, sea móvil o tenga WhatsApp. Los números ingresados sin
prefijo móvil se interpretan como celulares argentinos; los fijos y otros países
quedan fuera de alcance. El formato internacional requiere explícitamente `549`.
