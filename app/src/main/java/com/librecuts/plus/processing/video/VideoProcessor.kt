package com.librecuts.plus.processing.video

import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Procesador de video usando FFmpeg.
 */
class VideoProcessor {
    
    suspend fun trim(
        inputPath: String,
        outputPath: String,
        startTime: Double,
        endTime: Double
    ): Boolean = withContext(Dispatchers.IO) {
        val cmd = "-i \"$inputPath\" -ss $startTime -to $endTime -c copy \"$outputPath\""
        val session = FFmpegKit.execute(cmd)
        session.returnCode == ReturnCode.SUCCESS
    }
    
    suspend fun changeSpeed(
        inputPath: String,
        outputPath: String,
        speed: Float
    ): Boolean = withContext(Dispatchers.IO) {
        val setpts = 1.0f / speed
        val atempo = speed.coerceIn(0.5f, 2.0f)
        val cmd = "-i \"$inputPath\" -filter_complex \"[0:v]setpts=${setpts}*PTS[v];[0:a]atempo=${atempo}[a]\" -map \"[v]\" -map \"[a]\" \"$outputPath\""
        val session = FFmpegKit.execute(cmd)
        session.returnCode == ReturnCode.SUCCESS
    }
    
    suspend fun applyColorAdjustments(
        inputPath: String,
        outputPath: String,
        brightness: Float = 0f,
        contrast: Float = 1f,
        saturation: Float = 1f
    ): Boolean = withContext(Dispatchers.IO) {
        val cmd = "-i \"$inputPath\" -vf \"eq=brightness=$brightness:contrast=$contrast:saturation=$saturation\" \"$outputPath\""
        val session = FFmpegKit.execute(cmd)
        session.returnCode == ReturnCode.SUCCESS
    }
    
    suspend fun overlayImage(
        baseVideoPath: String,
        overlayImagePath: String,
        outputPath: String,
        x: Int = 0,
        y: Int = 0
    ): Boolean = withContext(Dispatchers.IO) {
        val cmd = "-i \"$baseVideoPath\" -i \"$overlayImagePath\" -filter_complex \"overlay=$x:$y\" \"$outputPath\""
        val session = FFmpegKit.execute(cmd)
        session.returnCode == ReturnCode.SUCCESS
    }
    
    suspend fun reverse(
        inputPath: String,
        outputPath: String
    ): Boolean = withContext(Dispatchers.IO) {
        val cmd = "-i \"$inputPath\" -vf reverse -af areverse \"$outputPath\""
        val session = FFmpegKit.execute(cmd)
        session.returnCode == ReturnCode.SUCCESS
    }
}
