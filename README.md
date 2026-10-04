# Generador de QR

App Flutter para cartelería de comercios de Argentina. Este scaffold muestra
WhatsApp, Instagram, Google Reseñas y Mercado Pago; cada opción abre Próximamente.

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
