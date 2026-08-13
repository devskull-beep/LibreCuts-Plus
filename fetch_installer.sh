#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO="devskull-beep/LibreCuts-Plus"
WORKFLOW_FILE="build_installer.yml"
BRANCH="main"
ARTIFACT_NAME="LibreCuts-Plus-Windows-Installer"
DEST_DIR="/sdcard/Download"
GITHUB_API="https://api.github.com"

command -v jq >/dev/null 2>&1 || { echo "Instala jq: pkg install jq"; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "Instala unzip: pkg install unzip"; exit 1; }
[ -n "${GITHUB_TOKEN:-}" ] || { echo "Exporta GITHUB_TOKEN antes: export GITHUB_TOKEN=ghp_xxx"; exit 1; }

mkdir -p "$DEST_DIR"

echo "1) Dispatching workflow '$WORKFLOW_FILE' on $REPO (branch $BRANCH)..."
curl -sS -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$GITHUB_API/repos/$REPO/actions/workflows/$WORKFLOW_FILE/dispatches" \
  -d "{\"ref\":\"$BRANCH\"}" \
  >/dev/null

echo "Esperando a que GitHub cree la ejecución (unos segundos)..."
sleep 5

echo "2) Buscando la ejecución más reciente del workflow..."
run_id=""
for i in {1..30}; do
  run_id=$(curl -sS -H "Authorization: token $GITHUB_TOKEN" \
    "$GITHUB_API/repos/$REPO/actions/workflows/$WORKFLOW_FILE/runs?branch=$BRANCH&per_page=1" \
    | jq -r '.workflow_runs[0].id // empty')
  if [ -n "$run_id" ]; then break; fi
  sleep 2
done

[ -n "$run_id" ] || { echo "No pude obtener run_id; espera unos segundos y vuelve a intentar."; exit 1; }
echo "Found run_id: $run_id"

echo "3) Esperando a que la ejecución termine (esto puede tardar varios minutos)..."
while true; do
  sleep 8
  status_json=$(curl -sS -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API/repos/$REPO/actions/runs/$run_id")
  status=$(echo "$status_json" | jq -r '.status // empty')
  conclusion=$(echo "$status_json" | jq -r '.conclusion // empty')
  echo "  status=$status  conclusion=$conclusion"
  if [ "$status" = "completed" ]; then
    echo "Run completed with conclusion=$conclusion"
    break
  fi
done

if [ "$conclusion" != "success" ]; then
  echo "La ejecución no terminó con éxito (conclusion=$conclusion). Revisa los logs en GitHub Actions."
  exit 1
fi

echo "4) Listando artifacts de la ejecución..."
artifacts_json=$(curl -sS -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API/repos/$REPO/actions/runs/$run_id/artifacts")
artifact_id=$(echo "$artifacts_json" | jq -r --arg NAME "$ARTIFACT_NAME" '.artifacts[] | select(.name==$NAME) | .id' )

if [ -z "$artifact_id" ]; then
  # si no hay match por nombre, toma el primero
  artifact_id=$(echo "$artifacts_json" | jq -r '.artifacts[0].id // empty')
  if [ -z "$artifact_id" ]; then
    echo "No se encontraron artifacts. Revisa la ejecución en GitHub."
    exit 1
  else
    echo "No encontré artifact con nombre $ARTIFACT_NAME, usaré el primero disponible."
  fi
fi
echo "Artifact id: $artifact_id"

ZIP_PATH="$DEST_DIR/${ARTIFACT_NAME}.zip"
echo "5) Descargando artifact a: $ZIP_PATH"
curl -sS -L -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/octet-stream" \
  "$GITHUB_API/repos/$REPO/actions/artifacts/$artifact_id/zip" -o "$ZIP_PATH"

[ -f "$ZIP_PATH" ] || { echo "Fallo al descargar el artifact."; exit 1; }
echo "Descargado."

echo "6) Descomprimiendo..."
unzip -o "$ZIP_PATH" -d "$DEST_DIR/${ARTIFACT_NAME}_unzipped" >/dev/null
echo "Archivos extraídos en: $DEST_DIR/${ARTIFACT_NAME}_unzipped"

# Buscar EXE dentro del unzip
exe_path=$(find "$DEST_DIR/${ARTIFACT_NAME}_unzipped" -type f -iname '*.exe' | head -n 1 || true)
if [ -n "$exe_path" ]; then
  echo "Instalador EXE encontrado: $exe_path"
  echo "Listo: abre el EXE en tu gestor de archivos y ejecútalo en Windows (descarga a un PC Windows) o transfiérelo."
else
  echo "No encontré .exe dentro del artifact. Lista de archivos extraídos:"
  find "$DEST_DIR/${ARTIFACT_NAME}_unzipped" -maxdepth 2 -type f -print
fi

echo "Terminado."
