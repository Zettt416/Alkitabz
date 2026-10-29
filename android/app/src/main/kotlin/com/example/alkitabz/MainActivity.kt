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
    private var ttsReady = false
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tts = TextToSpeech(applicationContext, this)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text")
                    val lang = call.argument<String>("lang") ?: "he-IL"
                    if (text.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
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
                        // Language voice data is not installed on this Android device
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Strip cantillation accents that confuse the TTS engine
                    val cleanText = if (lang.startsWith("he")) {
                        text.replace("׃", "").replace("־", " ").replace(Regex("[\\u0591-\\u05AF\\u05BD]"), "")
                    } else {
                        text
                    }

                    tts?.stop()
                    val code = tts?.speak(cleanText, TextToSpeech.QUEUE_FLUSH, null, "utterance_alkitab")
                    result.success(code == TextToSpeech.SUCCESS)
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                "isLanguageAvailable" -> {
                    val lang = call.argument<String>("lang") ?: "he-IL"
                    val isAvailable = if (lang.startsWith("he")) {
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
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
