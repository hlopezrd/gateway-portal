#!/usr/bin/env bash
# Verifica que no queden placeholders sin reemplazar en el sitio.
#
# dLocal exige que la identidad del sitio (RNC, correo, teléfono, dirección)
# sea real y coincida con la del registro. Un {{PLACEHOLDER}} sin reemplazar
# hace que el sitio falle la revisión de dLocal.
#
# Uso:
#   ./check-placeholders.sh          # solo informa
#   ./check-placeholders.sh --strict # sale con codigo 1 si hay placeholders

set -uo pipefail

cd "$(dirname "$0")"

PATTERN='\{\{[A-Z_]+\}\}'
STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

FOUND=$(grep -rEn "$PATTERN" --include="*.html" . || true)

if [ -z "$FOUND" ]; then
  echo "OK: no hay placeholders sin reemplazar."
  exit 0
fi

echo "Placeholders pendientes de reemplazar:"
echo
echo "$FOUND" | sed 's/^/  /'
echo
echo "Reemplazalos por la identidad real de la empresa antes de publicar."
echo "Los valores estan en el bloque .footer-identity de cada pagina y en los"
echo "enlaces mailto: y en los textos legales."

[ "$STRICT" -eq 1 ] && exit 1
exit 0
