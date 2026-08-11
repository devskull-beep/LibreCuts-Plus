#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>
#include <algorithm>

#define LOG_TAG "ImageUtils"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {

JNIEXPORT void JNICALL
Java_com_librecuts_plus_processing_ai_BackgroundRemoval_nativeAdjustColors(
    JNIEnv *env,
    jobject /* this */,
    jobject bitmap,
    jfloat brightness,
    jfloat contrast,
    jfloat saturation) {
    
    AndroidBitmapInfo info;
    AndroidBitmap_getInfo(env, bitmap, &info);
    
    void* bitmapPixels;
    AndroidBitmap_lockPixels(env, bitmap, &bitmapPixels);
    
    auto* pixels = static_cast<uint32_t*>(bitmapPixels);
    int pixelCount = info.width * info.height;
    
    for (int i = 0; i < pixelCount; i++) {
        uint32_t pixel = pixels[i];
        
        // Extraer componentes
        int r = (pixel >> 16) & 0xFF;
        int g = (pixel >> 8) & 0xFF;
        int b = pixel & 0xFF;
        int a = (pixel >> 24) & 0xFF;
        
        // Aplicar brillo
        r = std::clamp(static_cast<int>(r + brightness * 255), 0, 255);
        g = std::clamp(static_cast<int>(g + brightness * 255), 0, 255);
        b = std::clamp(static_cast<int>(b + brightness * 255), 0, 255);
        
        // Aplicar contraste
        float factor = (259.0f * (contrast * 255 + 255)) / (255.0f * (259.0f - contrast * 255));
        r = std::clamp(static_cast<int>(factor * (r - 128) + 128), 0, 255);
        g = std::clamp(static_cast<int>(factor * (g - 128) + 128), 0, 255);
        b = std::clamp(static_cast<int>(factor * (b - 128) + 128), 0, 255);
        
        // Reconstruir píxel
        pixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }
    
    AndroidBitmap_unlockPixels(env, bitmap);
    LOGI("Color adjustment completed");
}

} // extern "C"
