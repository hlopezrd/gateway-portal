# ECF Gateway — sitio web público

Sitio público (landing page + políticas legales) de ECF Gateway.

## Propósito

Cumplir los requisitos de **dLocal** para poder activar la cuenta de producción:

1. Sitio 100% terminado (sin placeholders ni secciones "en construcción").
2. Políticas visibles: Términos y Condiciones, Política de Envío, Política de Reembolso (y Privacidad).
3. Identidad visible: nombre de la empresa, RNC, correo de contacto.
4. URL propia (no se puede usar una red social).

Ver [`docs/PLAN_WEBSITE_DLOCAL.md`](./docs/PLAN_WEBSITE_DLOCAL.md) para el plan completo.

## Estructura

```
.
├── index.html          # Landing principal
├── terms.html          # Términos y Condiciones
├── privacy.html        # Política de Privacidad
├── refund.html         # Política de Reembolso
├── shipping.html       # Política de Envío y Entrega
├── assets/
│   ├── css/styles.css  # Estilos (paleta alineada con el portal)
│   └── img/logo.svg    # Logotipo
├── CNAME               # Dominio propio (opcional)
└── docs/
    └── PLAN_WEBSITE_DLOCAL.md
```

## Desarrollo

Es un sitio estático: no hay build step. Para verlo localmente:

```bash
python3 -m http.server 8080
# http://localhost:8080
```

## Deploy

### GitHub Pages

```bash
git remote add origin git@github.com:<usuario>/gateway-portal.git
git push -u origin main

# Settings > Pages > Source: main / (root)
```

Queda en `https://<usuario>.github.io/gateway-portal/`.

### Cloudflare Pages (recomendado para producción)

- Dashboard → Workers & Pages → Create → Pages → Conectar repositorio.
- Build command: *(vacío)*. Output directory: `/`.
- Dominio propio: `ecfgateway.com` (agregar `CNAME` con el dominio).

## Antes de publicar

Checklist de los requisitos de dLocal:

- [ ] No queda ningún texto de ejemplo ni "en construcción".
- [ ] Los cuatro enlaces del footer (Términos, Privacidad, Reembolso, Envío) funcionan.
- [ ] El RNC, el correo y el teléfono del footer coinciden con los de la cuenta dLocal.
- [ ] El correo del footer es **el mismo** con el que se registró en dLocal.
- [ ] Los precios de la sección de planes coinciden con `e-ncf/docs/PRICING_AND_LIMITS.md`.
- [ ] El sitio se ve bien en móvil y en escritorio.
- [ ] El sitio carga por HTTPS.

## Editar la identidad

La identidad de la empresa (RNC, correo, teléfono, dirección) aparece en el footer de
las cinco páginas. Para cambiarla, editar el bloque `.footer-identity` en cada HTML.

## Nota sobre los precios

Los precios del sitio son de referencia. La fuente de verdad es
`e-ncf/docs/PRICING_AND_LIMITS.md` y, en el sistema, los planes cargados en
`main_plans`. Si cambian, hay que actualizar `index.html`.
