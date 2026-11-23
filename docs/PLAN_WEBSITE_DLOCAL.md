# Plan: Sitio web público para dLocal (landing page de ECF Gateway)

> **Fecha:** 2026-11-16
> **Estado:** **Obsoleto tras la Vía B (2026-11-25).** dLocal Go fue deprecado en el producto; este plan queda como registro histórico y ya no es un requisito activo. El sitio público se mantiene como landing de ECF Gateway por sus propios motivos.
> **Contexto:** dLocal Go (y dLocal enterprise) exige un sitio web 100% terminado, con políticas visibles e identidad clara, para activar la cuenta de producción. No se puede usar una red social como sitio web.
> **Objetivo:** tener un sitio público que cumpla los requisitos de dLocal y sirva como landing page del producto.
> **Repo:** `gateway-portal` (este repo).

---

## 1. Requisitos de dLocal (lo que exige)

1. **Sitio 100% terminado**: sin textos de ejemplo (placeholders) ni secciones "en construcción".
2. **Políticas visibles y fáciles de encontrar**:
   - Términos y Condiciones
   - Política de envío (delivery policy)
   - Política de reembolso (refund policy)
3. **Identidad visible**:
   - Nombre de la empresa
   - Nombre del responsable / contacto
   - Número de identificación comercial (RNC)
   - Correo electrónico con el que se registró en dLocal Go
4. **No puede ser una red social** (Facebook, Instagram, etc.).
5. El sitio debe ser accesible públicamente (URL propia, no localhost).

---

## 2. Opciones de implementación

### Opción A — Sitio estático en GitHub Pages (recomendada)

- Repo `gateway-portal` (este repo).
- Una sola página HTML con todo el contenido.
- Hospedar en GitHub Pages (gratis, URL propia: `https://<usuario>.github.io/gateway-portal`).
- Desplegar en minutos, sin backend.

**Pros:** gratis, rápido, sin infraestructura.
**Contras:** no se actualiza automáticamente con el portal de la app.

### Opción B — Sección estática dentro del portal

- Agregar rutas públicas (`/landing`, `/terms`, `/privacy`, `/refund`) al portal React (`e-ncf-portal`).
- Servir desde el mismo dominio (`staging.ecfgateway.com/landing`).
- Reutiliza el mismo deploy (Kamal + portal volume).

**Pros:** mismo dominio, mismo deploy.
**Contras:** el portal es una SPA con auth; una sección pública requiere cuidado (no debe pedir login).

### Opción C — Sitio estático en Cloudflare Pages

- Mismo proveedor que el storage (R2).
- Deploy automático desde GitHub.
- Dominio propio (ej. `ecfgateway.com`).

**Pros:** profesional, dominio propio, SSL automático.
**Contras:** requiere comprar el dominio.

### Recomendación: Opción A para empezar, migrar a C cuando haya dominio.

---

## 3. Estructura del sitio (una sola página + políticas)

```
gateway-portal/
├── index.html          # Landing principal
├── terms.html          # Términos y Condiciones
├── privacy.html        # Política de privacidad (opcional pero recomendado)
├── refund.html         # Política de reembolso
├── shipping.html       # Política de envío (delivery policy)
├── assets/
│   ├── css/styles.css
│   └── img/logo.svg
├── CNAME               # si usas dominio propio
├── check-placeholders.sh       # detecta los {{PLACEHOLDERS}} sin reemplazar
└── docs/
    └── PLAN_WEBSITE_DLOCAL.md   # este plan
```

### 3.1 Landing principal (`index.html`)

Secciones:

1. **Hero** — Nombre del producto + tagline + CTA ("Solicita acceso").
2. **Qué es ECF Gateway** — descripción corta: plataforma de facturación electrónica (e-CF) para empresas dominicanas.
3. **Para quién** — empresas obligadas a facturar electrónicamente (Ley 32-23).
4. **Características** — emisión de e-CF, portal, API, OCR, directorio de compradores, dashboard.
5. **Planes** — Free / Starter / Professional / Enterprise (precios de `docs/PRICING_AND_LIMITS.md`).
6. **Identidad** — nombre de la empresa, RNC, correo de contacto.
7. **Footer** — links a Términos, Privacidad, Reembolso, Envío.

### 3.2 Términos y Condiciones (`terms.html`)

- Qué es el servicio (plataforma SaaS de facturación electrónica).
- Quién puede usarlo (empresas con RNC válido en RD).
- Responsabilidad del usuario (datos correctos, certificado DGII).
- Limitación de responsabilidad (no garantizamos disponibilidad 100%).
- Modificación de los términos.
- Jurisdicción (República Dominicana).

### 3.3 Política de reembolso (`refund.html`)

- **No se aceptan reembolsos** una vez emitido un e-CF (es un comprobante fiscal, no se puede deshacer).
- Si el servicio no funcionó por falla del sistema, se acredita el e-CF consumido.
- Las suscripciones se pueden cancelar al fin del período (sin reembolso parcial del mes en curso).
- Contacto para disputas: email de soporte.

### 3.4 Política de envío (`shipping.html`)

- Es un **servicio digital**: no hay envío físico.
- La "entrega" es el acceso a la plataforma y la emisión de los e-CF.
- El acceso se activa inmediatamente tras el pago confirmado.
- Los comprobantes se entregan electrónicamente (PDF + XML) al momento de la emisión.

### 3.5 Identidad visible (en todas las páginas, footer)

La identidad **no** está escrita en el código: son placeholders que se reemplazan
antes de publicar. `./check-placeholders.sh` los detecta (y con `--strict` devuelve
código de error 1, para usarlo en CI).

```
ECF Gateway
RNC: {{RNC_EMPRESA}}
Correo: {{EMAIL_CONTACTO}}
Teléfono: {{TELEFONO}}
Dirección: {{DIRECCION}}
```

| Placeholder | Qué es |
|---|---|
| `{{RNC_EMPRESA}}` | RNC de la empresa |
| `{{EMAIL_CONTACTO}}` | Correo de contacto — **debe ser el mismo con el que se registró en dLocal** |
| `{{TELEFONO}}` | Teléfono de contacto |
| `{{DIRECCION}}` | Domicilio de la empresa |

Están en el bloque `.footer-identity` de las cinco páginas, en los enlaces `mailto:` y
en los textos legales (Términos §1, Privacidad §1).

---

## 4. Contenido mínimo por página

### 4.1 index.html — Hero

```
ECF Gateway
Facturación electrónica para empresas dominicanas

Emite, gestiona y monitorea tus comprobantes fiscales electrónicos (e-CF)
desde una sola plataforma. API + Portal + App.

[Solicita acceso]   [Ver planes]
```

### 4.2 index.html — Planes

| Plan | Precio/mes | e-CF/mes | OCR/mes |
|---|---|---|---|
| Free | RD$0 | 50 | 0 |
| Starter | RD$1,500 | 100 | 30 |
| Professional | RD$4,500 | 500 | 150 |
| Enterprise | RD$12,000 | 2,000 | Ilimitado |

> Los precios definitivos están en `e-ncf/docs/PRICING_AND_LIMITS.md`. Este plan usa los valores de referencia; hay que actualizarlos antes de publicar (los precios mostrados en el sitio deben coincidir con los del sistema).

Descuento anual: 15%. Certificado DGII aparte.

> **Nota de precios (obligatoria):** la sección de planes incluye una advertencia
> que aclara que los importes y límites son los vigentes al momento de actualizar el
> sitio y **pueden cambiar** según las condiciones del mercado, el volumen y los costos
> de operación; que siempre prevalecen los precios y límites que aparezcan en la cuenta
> del cliente y en el portal al contratar o renovar; y que los cambios no afectan al
> período ya contratado. Los Términos §6 lo recoge desde el punto de vista contractual.
>
> Es una salvaguarda: si suben los precios, el sitio publicado no debe quedar
> prometiendo un importe que el sistema no aplica. Cuando cambien los precios hay que
> actualizar **las dos** cosas: `index.html` y los planes en `main_plans` del backend.

### 4.3 index.html — Características

- Emisión de e-CF (tipos 31, 32, 33, 34, 41, 43, 44, 45, 46, 47).
- Portal web con dashboard, facturas, compradores, usuarios.
- API REST para integración con sistemas existentes.
- OCR de facturas con IA.
- Directorio de compradores por tenant.
- Generación de PDF con QR y XML firmado.
- Monitoreo con AppSignal.
- Multi-tenant con aislamiento por RNC.

### 4.4 index.html — Identidad (footer)

```
ECF Gateway
RNC: 000000000
Correo: contacto@ecfgateway.com
© 2026 ECF Gateway. Todos los derechos reservados.
Términos y Condiciones | Privacidad | Reembolso | Envío
```

---

## 5. Requisitos técnicos

- **HTML/CSS puro** (sin framework, sin build step): más fácil de hospedar en cualquier lado.
- **Responsive**: móvil y desktop.
- **SEO básico**: meta tags, title, description.
- **Sin placeholders**: todo el texto debe ser real.
- **Sin "en construcción"**: si una sección no está lista, no la incluyas.

### 5.1 Stack sugerido

- HTML + CSS (Bootstrap o Tailwind via CDN).
- Sin JavaScript (o mínimo).
- Hospedado en GitHub Pages o Cloudflare Pages.

### 5.2 Estructura de archivos

```
gateway-portal/
├── index.html
├── terms.html
├── privacy.html
├── refund.html
├── shipping.html
├── assets/
│   ├── css/
│   │   └── styles.css
│   └── img/
│       └── logo.svg
├── CNAME               # si usas dominio propio
└── README.md
```

---

## 6. Pasos de implementación

| Paso | Qué | Tiempo estimado |
|---|---|---|
| 1 | Crear el repo `gateway-portal` | 5 min |
| 2 | Escribir el HTML/CSS de la landing | 2-3 horas |
| 3 | Escribir las 4 políticas (T&C, privacidad, reembolso, envío) | 1-2 horas |
| 4 | Agregar logo y branding | 30 min |
| 5 | Reemplazar los placeholders de identidad (`./check-placeholders.sh`) | 15 min |
| 6 | Hospedar en GitHub Pages / Cloudflare Pages | 15 min |
| 7 | Verificar que cumple los requisitos de dLocal | 15 min |
| 8 | Crear la cuenta en dLocal Go con el email del sitio | 15 min |

**Tiempo total estimado: 4-6 horas.**

---

## 7. Lo que NO entra en este plan

- El portal (`e-ncf-portal`) ya existe y no se toca.
- El backend (`e-ncf`) ya existe y no se toca.
- El sitio web es **solo** para cumplir los requisitos de dLocal y servir como landing page del producto.
- No hay integración con el backend: el sitio es estático.

---

## 8. Relación con el Plan B.7

| Fase | Depende de este plan |
|---|---|
| B.7.1–B.7.5 | **No**: se desarrollan contra el sandbox de dLocal, que no valida el sitio. |
| B.7.6 (activación de cuenta) | **Sí**: dLocal valida el sitio antes de activar la cuenta para producción. |

En otras palabras: **puedes implementar B.7.1–B.7.5 ahora** (el código ya está listo para las credenciales de sandbox), y el sitio web solo se necesita para pasar a producción.

---

## Referencias

- `e-ncf/docs/PRICING_AND_LIMITS.md` §4 (planes y precios), §9 (recomendaciones).
- `e-ncf/docs/PLAN_SUBSCRIPTION_RENEWAL_AND_BILLING.md` §B.4.1 (decisión de dLocal), §B.7 (fases).
- Requisitos de dLocal Go: https://dlocalgo.com/en/welcome-to-dlocalgo
