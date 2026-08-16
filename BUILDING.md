Construcción y firma de la APK (instrucciones)

Sigue estos pasos para generar un keystore en tu equipo y añadirlo como secretos en GitHub (recomendado).

1) Generar keystore en tu máquina:

   keytool -genkeypair -v -keystore librecuts.keystore -alias librecuts -keyalg RSA -keysize 2048 -validity 10000

   - Anota el path al archivo generado (por ejemplo /home/usuario/librecuts.keystore) y las contraseñas que elegiste.

2) Codificar keystore en base64 para subir como secreto (en Linux/macOS):

   base64 librecuts.keystore > librecuts.keystore.base64

   Abre librecuts.keystore.base64 y copia todo su contenido.

3) En la configuración del repositorio (Settings -> Secrets and variables -> Actions) crea los siguientes secrets:

   - KSTORE_BASE64: (contenido completo del archivo base64)
   - STORE_PASSWORD: contraseña del keystore
   - KEY_ALIAS: librecuts
   - KEY_PASSWORD: contraseña de la clave

4) Ejecutar el workflow de GitHub Actions:

   - Ve a la pestaña Actions -> Build Release APK -> Run workflow (o haz un push a la rama devskullcut)
   - Cuando el run termine, descarga el artefacto "app-release-apk" desde el run.

5) Opcional: Si prefieres no usar Actions, copia keystore.properties.example a keystore.properties en el root del repo y rellena con las rutas/contraseñas. Luego ejecuta localmente:

   ./gradlew clean assembleRelease

Notas de seguridad:
- NO subas nunca el archivo librecuts.keystore ni el archivo keystore.properties con contraseñas al repositorio.
- Guarda el keystore de forma segura; lo necesitarás para actualizaciones futuras de la app.
