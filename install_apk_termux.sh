#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PRINT() { printf '%s\n' "$*"; }

if ! command -v termux-open >/dev/null 2>&1; then
  PRINT "ERROR: instala termux-api: pkg install termux-api"
  exit 1
fi

INPUT="${1-}"
if [ -z "$INPUT" ]; then
  read -rp "Introduce URL de descarga del APK o ruta local al APK: " INPUT
fi

DEST_DIR="/sdcard/Download"
DEST_FILE="${DEST_DIR}/LibreCuts-Plus.apk"
mkdir -p "$DEST_DIR" || { PRINT "No se pudo crear $DEST_DIR."; exit 1; }

download_apk() {
  url="$1"
  PRINT "Descargando APK desde: $url"
  if [ -n "${GITHUB_TOKEN-}" ]; then
    curl -L --fail --retry 3 --retry-delay 2 -o "$DEST_FILE" -H "Authorization: token ${GITHUB_TOKEN}" "$url" || return 1
  else
    if command -v curl >/dev/null 2>&1; then
      curl -L --fail --retry 3 --retry-delay 2 -o "$DEST_FILE" "$url" || return 1
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$DEST_FILE" "$url" || return 1
    else
      PRINT "Instala curl: pkg install curl"
      return 1
    fi
  fi
  PRINT "Descarga completada: $DEST_FILE"
  return 0
}

copy_local_apk() {
  path="$1"
  if [ ! -f "$path" ]; then
    PRINT "No existe el archivo local: $path"
    return 1
  fi
  cp -f "$path" "$DEST_FILE"
  PRINT "Copia realizada: $DEST_FILE"
  return 0
}

if echo "$INPUT" | grep -Eq '^https?://'; then
  download_apk "$INPUT" || { PRINT "Fallo al descargar."; exit 1; }
else
  copy_local_apk "$INPUT" || exit 1
fi

PRINT ""
PRINT "Abriendo instalador del sistema para: $DEST_FILE"
termux-open "$DEST_FILE" || {
  PRINT "No se pudo abrir con termux-open. Abre $DEST_FILE desde el administrador de archivos."
  exit 1
}
PRINT "Listo."
