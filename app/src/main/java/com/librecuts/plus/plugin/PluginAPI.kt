package com.librecuts.plugin

/**
 * API de plugins para LibreCuts Plus.
 * Permite conectar motores externos (IA, efectos, etc.)
 */
interface LibreCutsPlugin {
    val name: String
    val version: String
    
    /**
     * Procesa un frame de video/imagen.
     * @param input Array RGBA de la imagen
     * @param width Ancho en píxeles
     * @param height Alto en píxeles
     * @return Array RGBA procesado
     */
    fun processFrame(input: ByteArray, width: Int, height: Int): ByteArray
    
    /**
     * Configura el plugin con parámetros específicos.
     */
    fun configure(params: Map<String, Any>)
    
    /**
     * Libera recursos.
     */
    fun release()
}
