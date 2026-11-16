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

### 1. Reemplazar los placeholders

La identidad de la empresa **no** está en el código: son placeholders que hay que
reemplazar. El script los detecta:

```bash
./check-placeholders.sh          # informa
./check-placeholders.sh --strict # sale con código 1 si quedan (para CI)
```

Placeholders usados:

| Placeholder | Qué es |
|---|---|
| `{{RNC_EMPRESA}}` | RNC de la empresa |
| `{{EMAIL_CONTACTO}}` | Correo de contacto — **debe ser el mismo con el que te registrás en dLocal** |
| `{{TELEFONO}}` | Teléfono de contacto |
| `{{DIRECCION}}` | Domicilio de la empresa |

Están en el bloque `.footer-identity` de las cinco páginas, en los enlaces `mailto:` y
en los textos legales (Términos §1, Privacidad §1).

### 2. Checklist de los requisitos de dLocal

- [ ] `./check-placeholders.sh --strict` no reporta nada.
- [ ] No queda ningún texto de ejemplo ni "en construcción".
- [ ] Los cuatro enlaces del footer (Términos, Privacidad, Reembolso, Envío) funcionan.
- [ ] El RNC, el correo y el teléfono del footer coinciden con los de la cuenta dLocal.
- [ ] El correo del footer es **el mismo** con el que se registró en dLocal.
- [ ] Los precios de la sección de planes coinciden con `e-ncf/docs/PRICING_AND_LIMITS.md`.
- [ ] El sitio se ve bien en móvil y en escritorio.
- [ ] El sitio carga por HTTPS.

### 3. Sobre los precios

La sección de planes incluye una nota que aclara que **los importes y límites son los
vigentes al momento de actualizar el sitio y pueden cambiar** según el mercado, el
volumen y los costos de operación; que siempre prevalecen los precios que aparecen en
la cuenta del cliente y en el portal, y que los cambios no afectan al período ya
contratado.

Es una salvaguarda: si los precios cambian, el sitio publicado no queda prometiendo
un importe que el sistema no aplica. Los Términos §6 dice lo mismo desde el punto de
vista contractual ("Los precios pueden ajustarse con previo aviso. El ajuste no aplica
al período en curso").

Cuando cambien los precios hay que actualizar **las dos** cosas: `index.html` y los
planes cargados en `main_plans` del backend.

## Nota sobre los precios

Los precios del sitio son de referencia. La fuente de verdad es
`e-ncf/docs/PRICING_AND_LIMITS.md` y, en el sistema, los planes cargados en
`main_plans`. Si cambian, hay que actualizar `index.html`.
