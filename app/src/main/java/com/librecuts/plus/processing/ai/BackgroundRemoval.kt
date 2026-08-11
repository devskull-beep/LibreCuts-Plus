package com.librecuts.plus.processing.ai

import ai.onnxruntime.*
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

/**
 * Motor de eliminación de fondo usando ONNX Runtime.
 * Modelo: BiRefNet (lightweight, high quality)
 */
class BackgroundRemoval {
    private var session: OrtSession? = null
    private var env: OrtEnvironment? = null
    
    suspend fun initialize(modelPath: String) = withContext(Dispatchers.IO) {
        env = OrtEnvironment.getEnvironment()
        val options = OrtSession.SessionOptions()
        options.setOptimizationLevel(OrtSession.SessionOptions.OptLevel.ALL_OPT)
        session = env?.createSession(modelPath, options)
    }
    
    suspend fun removeBackground(
        inputBitmap: Bitmap,
        brushMask: Bitmap? = null
    ): Bitmap = withContext(Dispatchers.IO) {
        val width = inputBitmap.width
        val height = inputBitmap.height
        
        // Preprocesar imagen
        val inputTensor = preprocessBitmap(inputBitmap, width, height)
        
        // Inferencia
        val inputs = mapOf("input" to inputTensor)
        val outputs = session?.run(inputs)
        
        // Postprocesar
        val mask = outputs?.get("output") as? OnnxTensor
        postprocessMask(inputBitmap, mask, width, height)
    }
    
    private fun preprocessBitmap(bitmap: Bitmap, width: Int, height: Int): OnnxTensor {
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
        
        val buffer = FloatBuffer.allocate(1 * 3 * height * width)
        for (pixel in pixels) {
            buffer.put(((pixel shr 16) and 0xFF) / 255.0f) // R
            buffer.put(((pixel shr 8) and 0xFF) / 255.0f)  // G
            buffer.put((pixel and 0xFF) / 255.0f)           // B
        }
        buffer.rewind()
        
        return OnnxTensor.createTensor(
            env,
            buffer,
            longArrayOf(1, 3, height.toLong(), width.toLong())
        )
    }
    
    private fun postprocessMask(
        original: Bitmap,
        mask: OnnxTensor?,
        width: Int,
        height: Int
    ): Bitmap {
        val result = original.copy(Bitmap.Config.ARGB_8888, true)
        if (mask == null) return result
        
        val maskData = mask.floatBuffer
        val pixels = IntArray(width * height)
        
        for (y in 0 until height) {
            for (x in 0 until width) {
                val alpha = (maskData.get(y * width + x) * 255).toInt()
                    .coerceIn(0, 255)
                val pixel = pixels[y * width + x]
                pixels[y * width + x] = (alpha shl 24) or (pixel and 0x00FFFFFF)
            }
        }
        
        result.setPixels(pixels, 0, width, 0, 0, width, height)
        return result
    }
    
    fun release() {
        session?.close()
        env?.close()
    }
}
