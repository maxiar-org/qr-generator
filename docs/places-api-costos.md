# Búsqueda automática de comercios

La app pide ubicación sólo al tocar **Buscar cerca mío** (requiere HTTPS o localhost).
Busca hasta 20 lugares en 200 m, ordenados por distancia. Maxi confirma nombre y
dirección; si el GPS no alcanza, puede buscar por nombre y localidad. La selección
abre la etiqueta existente. El Place ID manual sigue disponible y no consume API.
No se guarda historial ni se hacen búsquedas mientras se escribe.

## Configuración

Eduardo debe habilitar Places API (New) y facturación en Google Cloud, restringir
la clave a esa API y cargar `GOOGLE_PLACES_API_KEY` en Coolify como variable del
contenedor en ejecución. Reiniciar/recrear el contenedor después de cambiarla.
No se usa como argumento de build ni se incluye en Flutter.

`docker compose up --build` sirve la app en http://localhost:8080. Sin la variable,
los endpoints devuelven 503 y la app ofrece pegar el Place ID. Con la variable,
nginx agrega la clave y la máscara fija
`places.id,places.displayName,places.formattedAddress`. Sólo acepta POST a los
dos endpoints previstos; descarta headers del cliente y verifica TLS de Google.
Los templates se expanden con el mecanismo oficial de nginx.

Límites: 6 pedidos/minuto por IP (ráfaga de 3), 60/minuto globales (ráfaga de 10),
cuerpo máximo 4 KiB. Los límites reducen abuso, pero no reemplazan cuotas de Google
Cloud. Detrás de Coolify, nginx puede ver la IP del proxy y compartir el límite
entre usuarios. Configurar cuotas y alertas de presupuesto; una alerta no corta
el gasto. El DNS saliente del contenedor debe permitir 1.1.1.1 o 8.8.8.8.

## Costo mensual estimado (consulta: 9/10/2026)

La máscara incluye `displayName`: corresponde a **Nearby Search Pro** y
**Text Search Pro**, no al SKU gratuito de IDs solamente.

| SKU | Franquicia mensual | Precio por 1.000 pedidos después de la franquicia, hasta 100.000 |
| --- | ---: | ---: |
| Places API Nearby Search Pro | 5.000 | USD 32 |
| Places API Text Search Pro | 5.000 | USD 32 |

20 búsquedas/día × 30 días = **600 pedidos/mes**: **USD 0/mes** si la franquicia
de cada SKU está disponible. Incluso 20 cercanas más 20 por nombre diarios son
600 de cada SKU y quedan dentro de ambas franquicias. Si otros proyectos de la
misma cuenta de facturación agotan las franquicias, 600 pedidos adicionales
cuestan **USD 19,20** en el primer tramo. No incluye hosting, impuestos ni conversión
a pesos. Cada reintento es otro pedido; seleccionar o imprimir no llama a Google.

Fuentes oficiales: [precios globales](https://developers.google.com/maps/billing-and-pricing/pricing),
[campos de Nearby Search](https://developers.google.com/maps/documentation/places/web-service/nearby-search#fieldmask),
[campos de Text Search](https://developers.google.com/maps/documentation/places/web-service/text-search#fieldmask).

## Entregable visible reproducible

Las capturas de `docs/evidence/issue-19/` usan comercios ficticios y ubicación
simulada en Buenos Aires; no consumen Google ni necesitan clave.

```sh
flutter build web --release
python3 -m http.server 8765 --directory build/web
# En otra terminal:
python3 -m venv /tmp/places-playwright
/tmp/places-playwright/bin/pip install playwright
/tmp/places-playwright/bin/playwright install chromium
/tmp/places-playwright/bin/python scripts/capture_places.py
```

El script intercepta sólo `/api/places/*`, verifica las coordenadas recibidas,
selecciona un negocio y comprueba el link copiado. También captura búsqueda por
nombre y servicio sin clave, y recorre WhatsApp e Instagram hasta copiar y guardar.

Verificación de esta entrega: `flutter analyze`, `flutter test` y build web release.
Se validó nginx local con clave vacía (503), método GET (405) y upstream simulado:
rutas de Nearby/Text, headers fijos frente a intentos de reemplazarlos y límite 429.
El daemon de Docker no estaba disponible en el entorno; no se ejecutó el contenedor
completo ni una consulta real con clave de Google.
