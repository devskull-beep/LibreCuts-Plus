# LibreCuts Plus

Editor de video para Android con herramientas profesionales de superposición.

## Características

- 🪄 Eliminación de fondo con IA
- 🖌️ Pincel selectivo (estilo CapCut)
- 🎨 Igualación de color entre capas
- 🌑 Sombras proyectadas
- 📐 Escalado HD/4K
- ⏱ Control de tiempo (velocidad, freeze, reverse)
- 📑 Compositor multicapa con keyframes
- 🧹 Eliminación de ruido y defectos
- 🧍 Modificación corporal

## Compilar APK

La APK se compila automáticamente con GitHub Actions al hacer push.

O manualmente con Android Studio abriendo este directorio.

## Motor Python

El motor de procesamiento está en `plugins/ai_engine/`.

```bash
cd plugins/ai_engine
python lcplus_cli.py --help
cd ~/proyecto-libre/librecuts && mkdir -p .github/workflows
cat > .github/workflows/build_apk.yml << 'EOF'
name: Build LibreCuts Plus APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - uses: android-actions/setup-android@v3
      - name: Build APK
        run: |
          chmod +x gradlew
          ./gradlew assembleRelease
      - uses: actions/upload-artifact@v4
        with:
          name: LibreCuts-Plus-APK
          path: app/build/outputs/apk/release/*.apk
