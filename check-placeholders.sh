#!/usr/bin/env bash
# Verifica que el sitio generado no tenga placeholders sin reemplazar.
#
# La identidad de la empresa vive en site.config.json y se inyecta al
# generar docs/ (ver build.py). Este script verifica que:
#   1. site.config.json tenga los datos de identidad.
#   2. docs/ (sitio generado) exista y no le queden tokens sin reemplazar.
#
# dLocal exige que la identidad del sitio sea real y coincida con la del
# registro. Un {{PLACEHOLDER}} sin reemplazar hace que el sitio falle la
# revision de dLocal.
#
# Uso:
#   ./check-placeholders.sh          # solo informa
#   ./check-placeholders.sh --strict # sale con codigo 1 si hay problemas

set -uo pipefail

cd "$(dirname "$0")"

STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

PATTERN='\{\{[A-Z_]+\}\}'
PROBLEMS=0

# --- 1. Configuracion -------------------------------------------------------

if [ ! -f site.config.json ]; then
  echo "FALTA: site.config.json no existe."
  PROBLEMS=1
else
  for key in empresa correo; do
    if ! grep -q "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]\+" site.config.json; then
      echo "FALTA: site.config.json no tiene un valor para '$key'."
      PROBLEMS=1
    fi
  done
fi

# --- 2. Tokens sin reemplazar en el sitio generado -------------------------

if [ ! -d docs ]; then
  echo "FALTA: docs/ (sitio generado) no existe. Ejecuta: python3 build.py"
  PROBLEMS=1
else
  LEFTOVERS=$(grep -rEn "$PATTERN" --include="*.html" docs || true)
  if [ -n "$LEFTOVERS" ]; then
    echo "Tokens sin reemplazar en docs/:"
    echo "$LEFTOVERS" | sed 's/^/  /'
    echo
    PROBLEMS=1
  fi
fi

# --- 3. Tokens sin reemplazar en el fuente --------------------------------

SOURCE=$(grep -rEn "$PATTERN" --include="*.html" . --exclude-dir=dist || true)
if [ -n "$SOURCE" ]; then
  echo "Tokens en el HTML fuente (se reemplazan al generar docs/):"
  echo "$SOURCE" | sed 's/^/  /'
  echo
fi

# --- Resultado --------------------------------------------------------------

if [ "$PROBLEMS" -eq 0 ]; then
  echo "OK: el sitio generado esta al dia y sin placeholders sin reemplazar."
  exit 0
fi

echo "Resolvelo antes de publicar: completa site.config.json y ejecuta python3 build.py"
[ "$STRICT" -eq 1 ] && exit 1
exit 0
