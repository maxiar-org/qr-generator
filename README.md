# Generador de QR

App Flutter para cartelería de comercios de Argentina. Instagram permite generar
un QR al perfil del comercio. WhatsApp, Google Reseñas y Mercado Pago
muestran Próximamente.

## Probar con Docker

```sh
docker compose up --build
```

Abrí http://localhost:8080. Para detenerlo: Ctrl+C y `docker compose down`.
Necesitás Docker con el daemon activo, Compose e Internet para el primer build.

### Probar el QR de Instagram

1. Abrí Instagram desde el inicio de la app.
2. Ingresá `https://www.instagram.com/usuario/`,
   `instagram.com/usuario?igsh=abc`, `@usuario` o `usuario`.
3. Tocá **Generar QR**: aparece el QR y `https://instagram.com/usuario`.
4. Usá el usuario real de tu comercio y escaneá el QR con la cámara del celular
   para abrir el perfil.
5. Probá `usuario inválido`: aparece un error y no se muestra un QR.

Se aceptan de 1 a 30 letras ASCII, números, puntos o guiones bajos.
La app no verifica que el perfil exista.

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
