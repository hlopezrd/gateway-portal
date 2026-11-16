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
├── site.config.json    # ← LA IDENTIDAD DE LA EMPRESA (un solo lugar)
├── build.py            # Genera dist/ inyectando la identidad
├── check-placeholders.sh # Verifica que no queden tokens sin reemplazar
├── CNAME               # Dominio propio (opcional)
└── docs/
    └── PLAN_WEBSITE_DLOCAL.md
```

---

## Configurar la identidad (un solo lugar)

La identidad de la empresa está **únicamente** en `site.config.json`:

```json
{
  "empresa": "ECF Gateway",
  "correo": "hlopezrd@gmail.com"
}
```

Para cambiarla:

```bash
# 1. editar site.config.json
# 2. regenerar el sitio
python3 build.py
# 3. publicar
git add -A && git commit -m "..." && git push
```

`build.py` lee el JSON y genera `dist/` con los tokens ya reemplazados. **No hay que
tocar ninguna página HTML**: el correo y el nombre aparecen en el footer de las
cinco páginas, en los enlaces `mailto:` y en los textos legales (Términos §1,
Privacidad §1), y todos salen del mismo JSON.

### Por qué un build y no un fetch en runtime

El sitio es HTML estático: los valores llegan ya horneados en el HTML. Es lo que
necesita la revisión de dLocal, que puede leer el sitio sin ejecutar JavaScript.
Un `fetch()` en runtime dejaría el correo invisible sin JavaScript, y la revisión
de dLocal lee el sitio como un cliente más.

### Placeholders

En el HTML fuente los valores aparecen como tokens:

| Token | Sale de |
|---|---|
| `{{EMPRESA}}` | `site.config.json` → `empresa` |
| `{{EMAIL_CONTACTO}}` | `site.config.json` → `correo` |

### Verificar

```bash
./check-placeholders.sh          # informa
./check-placeholders.sh --strict # sale con código 1 si hay problemas (para CI)
python3 build.py --check         # verifica que dist/ esté al día
```

---

## Desarrollo

Es un sitio estático. Para verlo localmente:

```bash
python3 build.py
python3 -m http.server -d dist 8080
# http://localhost:8080
```

Para trabajar sobre el HTML fuente (con tokens) sin generar `dist/`, se puede
servir la raíz, pero los `{{...}}` se ven tal cual.

---

## Deploy

El sitio se despliega automáticamente con **GitHub Actions** (`.github/workflows/pages.yml`):
al hacer `git push` a `main`, el workflow genera `docs/` con `python3 build.py`
y publica el resultado en GitHub Pages.

URL publicada: **https://hlopezrd.github.io/gateway-portal/**

### Cómo actualizar la identidad (sin recompilar nada)

```bash
# 1. editar el JSON
vim site.config.json

# 2. regenerar el sitio
python3 build.py

# 3. publicar
git add -A && git commit -m "actualizar identidad" && git push
```

GitHub Actions se encarga del resto. No hay build de Node ni deploy manual.

### Cloudflare Pages (recomendado para producción)

- Dashboard → Workers & Pages → Create → Pages → Conectar repositorio.
- Build command: `python3 build.py`
- Output directory: `docs`
- Dominio propio: `ecfgateway.com` (agregar `CNAME` con el dominio).


## Antes de publicar

### 1. Revisar la identidad

La identidad sale de `site.config.json`. Verifica que el correo sea **el mismo con el
que te registrás en dLocal Go**:

```bash
cat site.config.json
```

### 2. Checklist de los requisitos de dLocal

- [ ] `./check-placeholders.sh --strict` no reporta nada.
- [ ] `python3 build.py --check` dice que `dist/` está al día.
- [ ] No queda ningún texto de ejemplo ni "en construcción".
- [ ] Los cuatro enlaces del footer (Términos, Privacidad, Reembolso, Envío) funcionan.
- [ ] El nombre y el correo del footer coinciden con los de la cuenta dLocal.
- [ ] El correo del footer es **el mismo** con el que se registró en dLocal.
- [ ] Los precios de la sección de planes coinciden con `e-ncf/docs/PRICING_AND_LIMITS.md`.
- [ ] El sitio se ve bien en móvil y en escritorio.
- [ ] El sitio carga por HTTPS.

### 3. Sobre los precios

La sección de planes incluye una nota que aclara que **los importes y límites son los
vigentes al momento de actualizar el sitio y pueden cambiar** según el mercado, el
volumen y los costos de operación; que siempre prevalecen los precios y límites que
aparezcan en la cuenta del cliente y en el portal al momento de contratar o renovar; y
que los cambios no afectan al período ya contratado.

Es una salvaguarda: si los precios cambian, el sitio publicado no queda prometiendo
un importe que el sistema no aplica. Los Términos §6 dice lo mismo desde el punto de
vista contractual ("Los precios pueden ajustarse con previo aviso. El ajuste no aplica
al período en curso").

Cuando cambien los precios hay que actualizar **las dos** cosas: `index.html` y los
planes cargados en `main_plans` del backend.

---

## Nota sobre la identidad

Por ahora se publica **solo el nombre de la empresa y el correo de contacto**. No se
publica el RNC ni la cédula del titular: dLocal Go acepta el correo electrónico
como identificación ("número de identificación comercial **o** el correo electrónico
con el que te registró"), de modo que no hace falta exponer un documento personal.

Si más adelante se decide publicar también el RNC comercial o el teléfono, se
agregan las claves a `site.config.json` y sus placeholders al footer; el build ya
soporta cualquier clave nueva sin cambiar el HTML a mano.
