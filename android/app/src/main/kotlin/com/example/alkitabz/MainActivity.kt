package com.example.alkitabz

import android.content.Intent
import android.media.AudioAttributes
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "com.example.alkitabz/tts"
    private var tts: TextToSpeech? = null
    @Volatile private var ttsReady = false
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        initTts()

        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    if (tts == null || !ttsReady) {
                        initTts()
                    }
                    result.success(true)
                }
                "speak" -> {
                    val text = call.argument<String>("text")
                    val lang = call.argument<String>("lang") ?: "id-ID"
                    if (text.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    if (tts == null) {
                        initTts()
                    }

                    // Tunggu hingga binding service TTS selesai (maks 1500 ms) jika pengguna menekan tombol sangat cepat
                    if (!ttsReady) {
                        var waited = 0
                        while (!ttsReady && waited < 1500) {
                            try {
                                Thread.sleep(100)
                            } catch (_: InterruptedException) {}
                            waited += 100
                        }
                    }

                    if (!ttsReady || tts == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    val locale = when {
                        lang.startsWith("he") -> {
                            val locHe = Locale("he", "IL")
                            val locIw = Locale("iw", "IL")
                            if ((tts?.isLanguageAvailable(locHe) ?: -2) >= 0) locHe
                            else if ((tts?.isLanguageAvailable(locIw) ?: -2) >= 0) locIw
                            else locHe
                        }
                        lang.startsWith("id") -> Locale("id", "ID")
                        lang.startsWith("en") -> Locale.US
                        lang.startsWith("de") -> Locale.GERMANY
                        else -> Locale(lang)
                    }

                    val langResult = tts?.setLanguage(locale) ?: TextToSpeech.LANG_NOT_SUPPORTED
                    val isAvailable = langResult >= TextToSpeech.LANG_AVAILABLE

                    if (!isAvailable) {
                        // Voice pack bahasa belum terpasang di perangkat
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Bersihkan tanda vokal kuno / aksen cantillation Niqqud agar engine TTS tidak bingung
                    val cleanText = if (lang.startsWith("he")) {
                        text.replace("׃", "").replace("־", " ").replace(Regex("[\\u0591-\\u05CF]"), "").trim()
                    } else {
                        text
                    }

                    try {
                        tts?.stop()
                        val code = tts?.speak(cleanText, TextToSpeech.QUEUE_FLUSH, null, "utterance_alkitab")
                        result.success(code == TextToSpeech.SUCCESS)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "stop" -> {
                    try {
                        tts?.stop()
                    } catch (_: Exception) {}
                    result.success(true)
                }
                "isLanguageAvailable" -> {
                    val lang = call.argument<String>("lang") ?: "he-IL"
                    if (tts == null) {
                        initTts()
                    }
                    if (!ttsReady) {
                        var waited = 0
                        while (!ttsReady && waited < 1000) {
                            try {
                                Thread.sleep(100)
                            } catch (_: InterruptedException) {}
                            waited += 100
                        }
                    }

                    val isAvailable = if (!ttsReady || tts == null) {
                        false
                    } else if (lang.startsWith("he")) {
                        val locHe = Locale("he", "IL")
                        val locIw = Locale("iw", "IL")
                        (tts?.isLanguageAvailable(locHe) ?: -2) >= 0 || (tts?.isLanguageAvailable(locIw) ?: -2) >= 0
                    } else {
                        val locale = when {
                            lang.startsWith("id") -> Locale("id", "ID")
                            lang.startsWith("en") -> Locale.US
                            lang.startsWith("de") -> Locale.GERMANY
                            else -> Locale(lang)
                        }
                        (tts?.isLanguageAvailable(locale) ?: -2) >= 0
                    }
                    result.success(isAvailable)
                }
                "openTtsSettings" -> {
                    try {
                        val intent = Intent("com.android.settings.TTS_SETTINGS")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initTts() {
        try {
            tts?.shutdown()
        } catch (_: Exception) {}
        ttsReady = false
        // Gunakan Activity context (this) agar binding service terikat ke lifecycle Activity
        tts = TextToSpeech(this, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            ttsReady = true
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build()
            tts?.setAudioAttributes(audioAttributes)

            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {
                    runOnUiThread { channel?.invokeMethod("onStart", utteranceId) }
                }
                override fun onDone(utteranceId: String?) {
                    runOnUiThread { channel?.invokeMethod("onDone", utteranceId) }
                }
                override fun onError(utteranceId: String?) {
                    runOnUiThread { channel?.invokeMethod("onError", utteranceId) }
                }
            })
        } else {
            ttsReady = false
        }
    }

    override fun onDestroy() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
