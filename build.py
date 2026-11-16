#!/usr/bin/env python3
"""Genera el sitio estatico en docs/ reemplazando los placeholders.

La identidad de la empresa (nombre y correo) vive SOLO en site.config.json.
Para cambiarla:

    1. editar site.config.json
    2. python3 build.py
    3. git add -A && git commit -m "..." && git push

El resultado en dist/ es HTML estatico: se ve igual con JavaScript
desactivado, que es lo que necesita la revision de dLocal.

Uso:
    python3 build.py            # genera dist/
    python3 build.py --check   # solo verifica que dist/ este al dia
"""

import json
import pathlib
import re
import shutil
import sys

ROOT = pathlib.Path(__file__).parent
CONFIG_FILE = ROOT / "site.config.json"
DIST = ROOT / "docs"

TOKEN = re.compile(r"\{\{([A-Z_]+)\}\}")

# Token del HTML -> clave de site.config.json.
TOKEN_TO_KEY = {
    "EMPRESA": "empresa",
    "EMAIL_CONTACTO": "correo",
}


def load_config() -> dict:
    if not CONFIG_FILE.exists():
        sys.exit(f"No se encuentra {CONFIG_FILE}")

    config = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))

    missing = [key for key in ("empresa", "correo") if not config.get(key)]
    if missing:
        sys.exit(f"Faltan en site.config.json: {', '.join(missing)}")

    return config


def render(html: str, config: dict) -> str:
    """Reemplaza los tokens {{CLAVE}} con el valor de la configuracion.

    Un token sin entrada en la configuracion se deja como esta (para que el
    checker lo detecte) en vez de vaciarse en silencio.
    """
    def substitute(match: "re.Match[str]") -> str:
        token = match.group(1)
        key = TOKEN_TO_KEY.get(token)
        value = config.get(key) if key else None
        # Un token sin valor se deja como esta: el checker lo detecta en vez
        # de dejar un hueco silencioso en el sitio publicado.
        return value if value else match.group(0)

    return TOKEN.sub(substitute, html)


def build() -> None:
    config = load_config()

    # El build solo borra lo que genera (html + assets). El plan
    # (docs/PLAN_WEBSITE_DLOCAL.md) y otros archivos de docs/ se conservan.
    DIST.mkdir(parents=True, exist_ok=True)

    for html in DIST.glob("*.html"):
        html.unlink()

    assets_dist = DIST / "assets"
    if assets_dist.exists():
        shutil.rmtree(assets_dist)

    for source in ROOT.glob("*.html"):
        target = DIST / source.name
        target.write_text(render(source.read_text(encoding="utf-8"), config), encoding="utf-8")
        print(f"  {source.name}")

    for folder in ("assets",):
        origin = ROOT / folder
        if origin.exists():
            shutil.copytree(origin, DIST / folder)

    print(f"\nSitio generado en {DIST}/")


def check() -> int:
    """Verifica que dist/ exista y que no le queden tokens sin reemplazar."""
    if not DIST.exists():
        print("docs/ no existe. Ejecuta: python3 build.py")
        return 1

    leftovers = []
    for page in sorted(DIST.glob("*.html")):
        for number, line in enumerate(page.read_text(encoding="utf-8").splitlines(), 1):
            for token in TOKEN.findall(line):
                leftovers.append(f"  {page.name}:{number}  {{{{{token}}}}}")

    if leftovers:
        print("Tokens sin reemplazar en dist/:")
        print("\n".join(leftovers))
        print("\nRevisa site.config.json y vuelve a ejecutar: python3 build.py")
        return 1

    print("OK: dist/ esta al dia y sin tokens sin reemplazar.")
    return 0


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(check())

    print("Generando el sitio...")
    build()
