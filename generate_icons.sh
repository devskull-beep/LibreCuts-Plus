#!/bin/bash

# Crear directorio de trabajo
mkdir -p temp_icons
cd temp_icons

# Crear una imagen PNG simple usando ImageMagick
# Si no tienes ImageMagick, instálalo: apt-get install imagemagick

# Crear icono base (usando un color sólido como placeholder)
convert -size 192x192 xc:"#FF6B6B" icon_base.png

# Redimensionar a cada densidad necesaria
convert icon_base.png -resize 48x48 ../app/src/main/res/mipmap-mdpi/ic_launcher.png
convert icon_base.png -resize 72x72 ../app/src/main/res/mipmap-hdpi/ic_launcher.png
convert icon_base.png -resize 96x96 ../app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert icon_base.png -resize 144x144 ../app/src/main/res/mipmap-xxhdpi/ic_launcher.png

echo "Iconos generados correctamente"

# Limpiar
cd ..
rm -rf temp_icons
