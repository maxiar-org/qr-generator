# Mercado Pago en Argentina: opciones para cartelería QR

Spike del issue #7. Consulta de fuentes oficiales: **4 de octubre de 2026**.
Alcance: comparar mecanismos y recomendar un camino; no implementar ni dar por aprobada una decisión de producto.

## Comparación

| Opción | Qué tiene que darle el comercio a Maxi | ¿Cualquier billetera o banco? | ¿Credenciales de API? | Costos para el comercio |
| --- | --- | --- | --- | --- |
| Transferencia a alias/CVU | Alias vigente, CVU y nombre del titular para verificar el destinatario. | La transferencia a CVU conecta cuentas bancarias y de pago [1]. **No implica que un QR con ese texto se pueda pagar desde sus lectores**: el cliente puede tener que ingresar el dato en “Transferir”. | No para imprimir datos o codificarlos como texto. | Mercado Pago anuncia envío y recepción de transferencias gratis [2]. Eso no equivale a exención de impuestos o retenciones por actividad comercial. |
| Link de pago, incluido uno entregado como `https://link.mercadopago.com.ar/...` | URL completa creada y compartida por el comercio, titular y condiciones del cobro (importe, vencimiento, medios habilitados). No construir la URL a partir del alias. | Se abre un checkout web; acepta los medios habilitados por Mercado Pago y el vendedor. No es un QR interoperable para pagar directamente desde cualquier app bancaria [3]. | No al convertir un enlace existente en QR. El comercio lo crea desde su cuenta. | Crear el enlace no tiene cargo por sí mismo; se cobra al vender. La tarifa depende de provincia, medio y plazo; financiar cuotas puede sumar costos [3]. |
| QR interoperable de Transferencias 3.0 (pago con transferencia, PCT) | QR oficial para imprimir, ya asociado al comercio por Mercado Pago u otro aceptador, y titular para cotejarlo. Pedir archivo original, no un QR de una operación que venza. | Sí, desde billeteras y apps bancarias que ofrecen PCT, con saldo en cuenta CBU/CVU. No significa que toda app tenga lector ni que cualquier QR sea interoperable [4]. | No para reutilizar el QR oficial. No se puede deducir un QR comercial válido solamente del alias/CVU: interviene un aceptador [4]. | BCRA informa **0,6–0,8 % + IVA** para PCT [4]. Mercado Pago publica **0,8 % + IVA**, acreditación inmediata, para dinero en cuenta de Mercado Pago u otras billeteras/bancos [5]. |

## Diferencias que afectan al cartel

**Alias/CVU:** identifica una cuenta, no una orden de cobro. La CVU tiene 22 dígitos y se obtiene del proveedor de la cuenta [1]. Como conclusión técnica de esta comparación, no hay fundamento para prometer que codificar ese número o un alias como texto produzca un QR PCT. Si se ofrece esta alternativa, el cartel debe mostrar el alias y el titular legibles y explicar la transferencia manual. Un cambio de alias exige revisar la cartelería.

**Link:** el QR representa una URL, no el protocolo de cobro interoperable. La página oficial describe crear un enlace con monto, personalizarlo y compartirlo. Publica como referencia 6,29 % al instante, 4,39 % a 10 días, 3,39 % a 18 días y 1,49 % a 35 días [3]. No tomar esos porcentajes como cotización final ni asumir que incluyen todos los impuestos: confirmar el total en la cuenta del comercio. El dominio solicitado en el issue no demuestra que un enlace concreto admita monto libre o uso permanente; hay que comprobar destino, importe, reutilización y vencimiento antes de imprimirlo.

**QR interoperable:** BCRA distingue los pagos comerciales con participación de un aceptador de las transferencias comunes [4]. Mercado Pago ofrece descargar/imprimir un QR para que el comprador ingrese el monto [5]. Es el mecanismo más cercano al cartel permanente buscado. El mismo producto puede ofrecer tarjetas con otras tarifas; el costo de PCT no se debe extender a todos los pagos con QR. Confirmar tasas y posibles bonificaciones en “Tu negocio → Costos” [5]. La integración programática para crear cobros o confirmar pagos queda fuera de este spike; reutilizar un QR existente no exige que Maxi reciba contraseñas ni tokens.

## Recomendación final

**Recomendar para una próxima implementación la importación del QR interoperable oficial del comercio**, conservando su contenido, y acompañarlo con el titular y un alias legible como alternativa manual. Es una propuesta técnica, pendiente de la elección de Eduardo; no modifica la app ni compromete una implementación.

Maxi aporta el diseño y la impresión. El proveedor de pagos aporta el QR comercial y el comercio mantiene su cuenta y verifica las acreditaciones. No presentar el cobro interoperable como una transferencia sin comisión. Si el requisito principal fuera evitar comisión de cobro, ofrecer cartelería de alias/CVU con transferencia manual explícita; si se busca cobrar online o con cuotas, evaluar el enlace como opción separada.

## Preguntas abiertas para Eduardo

Estas preguntas definen el siguiente issue; no impiden entregar esta comparación.

1. ¿Priorizamos pagar escaneando desde distintas billeteras aunque haya comisión, o transferir por alias sin comisión de recepción anunciada?
2. ¿Aceptamos importar el QR oficial que trae el comercio, en lugar de generar uno a partir de su alias?
3. ¿El cartel será permanente y con monto ingresado por el comprador? ¿Hace falta además una opción de link para importes fijos o cuotas?
4. ¿Qué comercio puede aportar su QR y sus condiciones de cobro para validar el circuito? ¿Qué billeteras y bancos usan sus clientes?

## Validación pendiente antes de implementar o vender carteles

No se hicieron pagos reales ni pruebas de escaneo: este entregable es investigación documental. Para el piloto, con autorización del comercio:

- Cotejar titular y cuenta receptora; probar el QR oficial desde Mercado Pago y desde una billetera o app bancaria de otro proveedor con PCT.
- Verificar monto editable, acreditación y comisión efectivamente aplicada en la cuenta del comercio. No usar una captura del comprador como confirmación del pago.
- Imprimir con la Detonger DT01 desde WePrint en iPhone (58 mm, 203 ppp, 464 px útiles), respetar márgenes y comprobar lectura del papel. La densidad del QR original puede limitar el diseño.
- Para un link, abrir la URL entregada y comprobar destinatario, condiciones y vigencia antes de producir carteles.

Las tarifas, promociones y condiciones pueden cambiar. Revalidarlas al implementar y al presupuestar; los impuestos o retenciones dependen de la situación del comercio.

## Fuentes oficiales

1. [BCRA — Clave Virtual Uniforme (CVU)](https://www.bcra.gob.ar/clave-virtual-uniforme-cvu/): identificación de cuenta e interoperabilidad bancaria.
2. [Mercado Pago — Cuenta](https://www.mercadopago.com.ar/cuenta): recepción y envío de transferencias gratis.
3. [Mercado Pago — Link de pago](https://www.mercadopago.com.ar/herramientas-para-vender/link-de-pago): creación, medios, plazos y costos publicados.
4. [BCRA — Transferencias 3.0](https://www.bcra.gob.ar/transferencias-3-0/): rol del aceptador, interoperabilidad PCT y rango de comisión.
5. [Mercado Pago — Cobrar con QR](https://www.mercadopago.com.ar/herramientas-para-vender/cobrar-con-qr): impresión, ingreso del monto y tarifas según medio.
