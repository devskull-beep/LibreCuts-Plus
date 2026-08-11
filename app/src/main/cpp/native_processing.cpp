#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>
#include <cstring>

#define LOG_TAG "LibreCutsNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {

JNIEXPORT void JNICALL
Java_com_librecuts_plus_processing_ai_BackgroundRemoval_nativeAlphaBlend(
    JNIEnv *env,
    jobject /* this */,
    jobject bitmap,
    jbyteArray mask,
    jint width,
    jint height) {
    
    void* bitmapPixels;
    AndroidBitmap_lockPixels(env, bitmap, &bitmapPixels);
    
    jbyte* maskData = env->GetByteArrayElements(mask, nullptr);
    
    auto* pixels = static_cast<uint32_t*>(bitmapPixels);
    for (int i = 0; i < width * height; i++) {
        uint8_t alpha = static_cast<uint8_t>(maskData[i]);
        pixels[i] = (pixels[i] & 0x00FFFFFF) | (alpha << 24);
    }
    
    env->ReleaseByteArrayElements(mask, maskData, JNI_ABORT);
    AndroidBitmap_unlockPixels(env, bitmap);
    
    LOGI("Alpha blending completed: %dx%d", width, height);
}

} // extern "C"
