import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'models/bible_models.dart';
import 'utils/hebrew_transliteration.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlkitabApp());
}

enum ReadingThemeMode { sepia, light, dark }

// -------------------------------------------------------------
// Kamus Bahasa Aplikasi (Zero Dependency Localization)
// -------------------------------------------------------------
class AppStrings {
  static const Map<String, Map<String, String>> _values = {
    'id': {
      'app_title': 'Alkitabz',
      'home': 'Beranda',
      'bible': 'Alkitab',
      'saved': 'Tersimpan',
      'settings': 'Pengaturan',
      'continue_reading': 'Lanjutkan Membaca',
      'last_read': 'Terakhir Dibaca',
      'daily_verse': 'Ayat Hari Ini',
      'recent_bookmarks': 'Ditandai Baru-baru Ini',
      'no_bookmarks': 'Belum ada ayat yang ditandai',
      'bookmarks_hint': 'Ketuk ayat saat membaca lalu pilih "Tandai Ayat" untuk menyimpannya di sini.',
      'select_book': 'Pilih Kitab',
      'prev_chapter': 'Pasal Sblm',
      'next_chapter': 'Pasal Lanjut',
      'copy_verse': 'Salin Ayat',
      'share_verse': 'Bagikan',
      'bookmark_verse': 'Tandai Ayat',
      'remove_bookmark': 'Hapus Tanda',
      'verse_copied': 'Ayat berhasil disalin ke clipboard!',
      'verse_translations': 'Perbandingan Terjemahan',
      'translate_to': 'Terjemahkan ke:',
      'lang_all': 'Semua',
      'copy_all': 'Salin Semua Terjemahan (TB, KJV & HEB)',
      'all_copied': 'Semua versi ayat berhasil disalin!',
      'search_verse': 'Cari Ayat',
      'search_hint': 'Cari kata / perikop ayat...',
      'all_bible': 'Seluruh Alkitab',
      'current_book_only': 'Kitab Ini Saja',
      'appearance': 'TAMPILAN & TEMA',
      'typography': 'UKURAN & GAYA HURUF',
      'font_size': 'Ukuran Huruf',
      'font_style': 'Gaya Font',
      'serif': 'Serif (Buku)',
      'sans': 'Sans-Serif',
      'preview_text': '“Pada mulanya adalah Firman; Firman itu bersama-sama dengan Allah.”',
      'data_storage': 'DATA & PENYIMPANAN',
      'offline_status': 'Data Alkitab 100% Offline',
      'offline_desc': 'Seluruh 66 Kitab TB, KJV & Ibrani tersimpan lokal di aplikasi. Tidak butuh koneksi internet sama sekali untuk membaca.',
      'clear_bookmarks': 'Hapus Semua Bookmark',
      'confirm_clear_title': 'Hapus Bookmark?',
      'confirm_clear_desc': 'Apakah kamu yakin ingin menghapus semua daftar ayat yang ditandai?',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'about_app': 'TENTANG APLIKASI',
      'about_desc': 'Aplikasi pembaca Alkitab lengkap 66 kitab (Perjanjian Lama dan Perjanjian Baru) dengan dukungan multi-versi (TB, KJV & Ibrani), multi-bahasa, desain bersih, ramah jempol, dan 100% offline.',
      'app_language': 'BAHASA APLIKASI',
      'lang_id': 'Bahasa Indonesia',
      'lang_en': 'English',
      'lang_de': 'Jerman (Deutsch)',
      'bible_version': 'VERSI ALKITAB',
      'ver_tb': 'TB (Indonesia)',
      'ver_kjv': 'KJV (English)',
      'ver_hebrew': 'HEB (עברית / Ibrani)',
      'ver_parallel': 'Paralel (TB + KJV)',
      'choose_version': 'Pilih Versi Alkitab',
      'version_active': 'Versi Aktif',
      'chapters_count': 'Pasal',
      'ot': 'Perjanjian Lama',
      'nt': 'Perjanjian Baru',
      'welcome_title': 'Selamat Datang di Alkitabz',
      'welcome_subtitle': 'Aplikasi firman Tuhan yang cepat, bersih, dan 100% offline.',
      'feat_offline_title': '100% Bebas Internet',
      'feat_offline_desc': 'Seluruh 66 kitab tersimpan di perangkat. Baca firman kapan saja tanpa kuota data.',
      'feat_version_title': 'Multi-Versi & Teks Ibrani',
      'feat_version_desc': 'Mendukung TB Indonesia, KJV Inggris, teks Ibrani Tanakh, dan perbandingan paralel.',
      'feat_instant_title': 'Terjemahan Cepat & Ramah Jempol',
      'feat_instant_desc': 'Cukup ketuk ayat untuk membandingkan terjemahan seketika atau menandai ayat.',
      'quick_theme_label': 'PILIH TEMA MEMBACA',
      'theme_sepia': 'Sepia',
      'theme_light': 'Terang',
      'theme_dark': 'Gelap',
      'start_reading': 'Mulai Membaca Sekarang',
      'reopen_splash': 'Buka Layar Sambutan (Splash)',
      'reopen_splash_desc': 'Lihat kembali panduan fitur & perkenalan aplikasi',
    },
    'en': {
      'app_title': 'Alkitabz',
      'home': 'Home',
      'bible': 'Bible',
      'saved': 'Saved',
      'settings': 'Settings',
      'continue_reading': 'Continue Reading',
      'last_read': 'Last Read',
      'daily_verse': 'Verse of the Day',
      'recent_bookmarks': 'Recently Bookmarked',
      'no_bookmarks': 'No bookmarked verses yet',
      'bookmarks_hint': 'Tap any verse while reading and select "Bookmark Verse" to save it here.',
      'select_book': 'Select Book',
      'prev_chapter': 'Prev Ch.',
      'next_chapter': 'Next Ch.',
      'copy_verse': 'Copy Verse',
      'share_verse': 'Share',
      'bookmark_verse': 'Bookmark Verse',
      'remove_bookmark': 'Remove Bookmark',
      'verse_copied': 'Verse copied to clipboard!',
      'verse_translations': 'Verse Translations',
      'translate_to': 'Translate to:',
      'lang_all': 'All',
      'copy_all': 'Copy All Translations (TB, KJV & HEB)',
      'all_copied': 'All translations copied to clipboard!',
      'search_verse': 'Search Scripture',
      'search_hint': 'Search words or phrases...',
      'all_bible': 'Entire Bible',
      'current_book_only': 'This Book Only',
      'appearance': 'APPEARANCE & THEME',
      'typography': 'FONT SIZE & STYLE',
      'font_size': 'Font Size',
      'font_style': 'Font Style',
      'serif': 'Serif (Book)',
      'sans': 'Sans-Serif',
      'preview_text': '“In the beginning was the Word, and the Word was with God.”',
      'data_storage': 'DATA & STORAGE',
      'offline_status': '100% Offline Bible Data',
      'offline_desc': 'All 66 Books (TB, KJV & Hebrew) are bundled in the app. Works without internet connection.',
      'clear_bookmarks': 'Clear All Bookmarks',
      'confirm_clear_title': 'Clear Bookmarks?',
      'confirm_clear_desc': 'Are you sure you want to delete all bookmarked verses?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'about_app': 'ABOUT APP',
      'about_desc': 'Complete Holy Bible reader with 66 books (Old and New Testament), multi-version support (TB & KJV), multi-language, clean thumb-friendly design, and 100% offline.',
      'app_language': 'APP LANGUAGE',
      'lang_id': 'Bahasa Indonesia',
      'lang_en': 'English',
      'lang_de': 'German (Deutsch)',
      'bible_version': 'BIBLE VERSION',
      'ver_tb': 'TB (Indonesian)',
      'ver_kjv': 'KJV (English)',
      'ver_hebrew': 'HEB (עברית / Hebrew)',
      'ver_parallel': 'Parallel (TB + KJV)',
      'choose_version': 'Select Bible Version',
      'version_active': 'Active Version',
      'chapters_count': 'Chapters',
      'ot': 'Old Testament',
      'nt': 'New Testament',
      'welcome_title': 'Welcome to Alkitabz',
      'welcome_subtitle': 'A fast, clean, and 100% offline Bible reader.',
      'feat_offline_title': '100% Offline Scripture',
      'feat_offline_desc': 'All 66 books stored locally. Read anytime without internet data.',
      'feat_version_title': 'Multi-Version & Hebrew Text',
      'feat_version_desc': 'Supports Indonesian TB, English KJV, Hebrew Tanakh, and parallel reading.',
      'feat_instant_title': 'Instant Translation & Thumb-Friendly',
      'feat_instant_desc': 'Tap any verse for instant inline translation or quick bookmarking.',
      'quick_theme_label': 'CHOOSE READING THEME',
      'theme_sepia': 'Sepia',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'start_reading': 'Start Reading Now',
      'reopen_splash': 'Open Welcome Screen',
      'reopen_splash_desc': 'Revisit the feature guide & app introduction',
    },
    'de': {
      'app_title': 'Alkitabz',
      'home': 'Startseite',
      'bible': 'Bibel',
      'saved': 'Gespeichert',
      'settings': 'Einstellungen',
      'continue_reading': 'Weiterlesen',
      'last_read': 'Zuletzt gelesen',
      'daily_verse': 'Vers des Tages',
      'recent_bookmarks': 'Kürzlich markiert',
      'no_bookmarks': 'Noch keine Verse markiert',
      'bookmarks_hint': 'Tippe beim Lesen auf einen Vers und wähle „Vers markieren“, um ihn hier zu speichern.',
      'select_book': 'Buch auswählen',
      'prev_chapter': 'Vorh. Kap.',
      'next_chapter': 'Nächstes Kap.',
      'copy_verse': 'Vers kopieren',
      'share_verse': 'Teilen',
      'bookmark_verse': 'Vers markieren',
      'remove_bookmark': 'Markierung entfernen',
      'verse_copied': 'Vers in die Zwischenablage kopiert!',
      'verse_translations': 'Übersetzungsvergleich',
      'translate_to': 'Übersetzen nach:',
      'lang_all': 'Alle',
      'copy_all': 'Alle Übersetzungen kopieren (TB, KJV & HEB)',
      'all_copied': 'Alle Versionen in die Zwischenablage kopiert!',
      'search_verse': 'Bibelvers suchen',
      'search_hint': 'Wörter oder Abschnitte suchen...',
      'all_bible': 'Ganze Bibel',
      'current_book_only': 'Nur dieses Buch',
      'appearance': 'ERSCHEINUNGSBILD & DESIGN',
      'typography': 'SCHRIFTGRÖSSE & STIL',
      'font_size': 'Schriftgröße',
      'font_style': 'Schriftart',
      'serif': 'Serif (Buch)',
      'sans': 'Sans-Serif',
      'preview_text': '„Im Anfang war das Wort, und das Wort war bei Gott.“',
      'data_storage': 'DATEN & SPEICHER',
      'offline_status': '100% Offline-Bibeldaten',
      'offline_desc': 'Alle 66 Bücher (TB, KJV & Hebräisch) sind in der App gespeichert. Funktioniert komplett ohne Internet.',
      'clear_bookmarks': 'Alle Lesezeichen löschen',
      'confirm_clear_title': 'Lesezeichen löschen?',
      'confirm_clear_desc': 'Möchtest du wirklich alle markierten Verse löschen?',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'about_app': 'ÜBER DIE APP',
      'about_desc': 'Vollständiger Bibelleser mit 66 Büchern (Altes und Neues Testament), Multi-Version-Unterstützung (TB, KJV & Hebräisch), mehrsprachig, daumenfreundlich und 100% offline.',
      'app_language': 'APP-SPRACHE',
      'lang_id': 'Bahasa Indonesia',
      'lang_en': 'English',
      'lang_de': 'Deutsch',
      'bible_version': 'BIBELVERSION',
      'ver_tb': 'TB (Indonesisch)',
      'ver_kjv': 'KJV (Englisch)',
      'ver_hebrew': 'HEB (עברית / Hebräisch)',
      'ver_parallel': 'Parallel (TB + KJV)',
      'choose_version': 'Bibelversion wählen',
      'version_active': 'Aktive Version',
      'chapters_count': 'Kapitel',
      'ot': 'Altes Testament',
      'nt': 'Neues Testament',
      'welcome_title': 'Willkommen bei Alkitabz',
      'welcome_subtitle': 'Eine schnelle, saubere und 100% offline Bibelleser-App.',
      'feat_offline_title': '100% Offline',
      'feat_offline_desc': 'Alle 66 Bücher lokal gespeichert. Jederzeit ohne Datenvolumen lesen.',
      'feat_version_title': 'Multi-Version & Hebräischer Text',
      'feat_version_desc': 'Unterstützt indonesische TB, englische KJV, hebräischen Tanach-Urtext und Parallelmodus.',
      'feat_instant_title': 'Sofortige Übersetzung & Daumenfreundlich',
      'feat_instant_desc': 'Tippe auf Verse für sofortigen Übersetzungsvergleich oder schnelles Speichern.',
      'quick_theme_label': 'LESE-THEMA WÄHLEN',
      'theme_sepia': 'Sepia',
      'theme_light': 'Hell',
      'theme_dark': 'Dunkel',
      'start_reading': 'Jetzt mit dem Lesen beginnen',
      'reopen_splash': 'Willkommensbildschirm öffnen',
      'reopen_splash_desc': 'Funktionsübersicht & Einführung erneut ansehen',
    },
  };

  static String tr(String key, String lang) {
    return _values[lang]?[key] ?? _values['id']?[key] ?? key;
  }
}

class AlkitabThemeData {
  final Color bg;
  final Color surface;
  final Color card;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color pericopeTitle;
  final Color verseNumber;
  final Color border;

  const AlkitabThemeData({
    required this.bg,
    required this.surface,
    required this.card,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.pericopeTitle,
    required this.verseNumber,
    required this.border,
  });

  static const sepia = AlkitabThemeData(
    bg: Color(0xFFF9F5EA),
    surface: Color(0xFFEFE8D6),
    card: Color(0xFFF3ECE0),
    text: Color(0xFF2E261D),
    textMuted: Color(0xFF7A6E5D),
    accent: Color(0xFF9E4B28),
    onAccent: Colors.white,
    pericopeTitle: Color(0xFF6E3319),
    verseNumber: Color(0xFF9E4B28),
    border: Color(0xFFE2D8C0),
  );

  static const light = AlkitabThemeData(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    card: Color(0xFFF1F5F9),
    text: Color(0xFF0F172A),
    textMuted: Color(0xFF64748B),
    accent: Color(0xFF2563EB),
    onAccent: Colors.white,
    pericopeTitle: Color(0xFF1D4ED8),
    verseNumber: Color(0xFF2563EB),
    border: Color(0xFFE2E8F0),
  );

  static const dark = AlkitabThemeData(
    bg: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    card: Color(0xFF192237),
    text: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
    accent: Color(0xFFF59E0B),
    onAccent: Color(0xFF0F172A),
    pericopeTitle: Color(0xFFFBBF24),
    verseNumber: Color(0xFFF59E0B),
    border: Color(0xFF334155),
  );
}

class AlkitabApp extends StatefulWidget {
  const AlkitabApp({super.key});

  @override
  State<AlkitabApp> createState() => _AlkitabAppState();
}

class _AlkitabAppState extends State<AlkitabApp> {
  ReadingThemeMode _themeMode = ReadingThemeMode.sepia;
  double _fontSize = 18.0;
  bool _useSerif = true;
  double _lineHeight = 1.8;
  String _appLanguage = 'id';
  BibleVersion _bibleVersion = BibleVersion.tb;
  String _inlineTargetLanguage = 'all';
  bool _hasSeenSplash = true;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('alkitab_theme') ?? 'sepia';
    final savedFontSize = prefs.getDouble('alkitab_font_size') ?? 18.0;
    final savedSerif = prefs.getBool('alkitab_serif') ?? true;
    final savedLineHeight = prefs.getDouble('alkitab_line_height') ?? 1.8;
    final savedLang = prefs.getString('alkitab_app_lang') ?? 'id';
    final savedVersionStr = prefs.getString('alkitab_bible_version') ?? 'tb';
    final savedInlineLang = prefs.getString('alkitab_inline_target_lang') ?? 'all';
    final savedHasSeenSplash = prefs.getBool('alkitab_has_seen_splash') ?? false;

    setState(() {
      _themeMode = ReadingThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ReadingThemeMode.sepia,
      );
      _fontSize = savedFontSize;
      _useSerif = savedSerif;
      _lineHeight = savedLineHeight;
      _appLanguage = savedLang;
      _bibleVersion = BibleVersion.values.firstWhere(
        (e) => e.name == savedVersionStr,
        orElse: () => BibleVersion.tb,
      );
      _inlineTargetLanguage = savedInlineLang;
      _hasSeenSplash = savedHasSeenSplash;
      _isLoadingSettings = false;
    });
  }

  void _completeSplash() async {
    setState(() => _hasSeenSplash = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alkitab_has_seen_splash', true);
  }

  void _reopenSplash() {
    setState(() => _hasSeenSplash = false);
  }

  void _updateTheme(ReadingThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alkitab_theme', mode.name);
  }

  void _updateFontSize(double size) async {
    setState(() => _fontSize = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('alkitab_font_size', size);
  }

  void _updateFontFamily(bool serif) async {
    setState(() => _useSerif = serif);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alkitab_serif', serif);
  }

  void _updateLineHeight(double height) async {
    setState(() => _lineHeight = height);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('alkitab_line_height', height);
  }

  void _updateAppLanguage(String lang) async {
    setState(() => _appLanguage = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alkitab_app_lang', lang);
  }

  void _updateBibleVersion(BibleVersion version) async {
    setState(() => _bibleVersion = version);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alkitab_bible_version', version.name);
  }

  void _updateInlineTargetLanguage(String lang) async {
    setState(() => _inlineTargetLanguage = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alkitab_inline_target_lang', lang);
  }

  AlkitabThemeData get currentTheme {
    switch (_themeMode) {
      case ReadingThemeMode.light:
        return AlkitabThemeData.light;
      case ReadingThemeMode.dark:
        return AlkitabThemeData.dark;
      case ReadingThemeMode.sepia:
        return AlkitabThemeData.sepia;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = currentTheme;
    final isDark = _themeMode == ReadingThemeMode.dark;

    Widget body;
    if (_isLoadingSettings) {
      body = Scaffold(
        key: const ValueKey('loading_init'),
        backgroundColor: t.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alkitabz',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: t.text,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!_hasSeenSplash) {
      body = WelcomeSplashScreen(
        key: const ValueKey('welcome_splash'),
        themeData: t,
        themeMode: _themeMode,
        appLanguage: _appLanguage,
        onThemeChanged: _updateTheme,
        onLanguageChanged: _updateAppLanguage,
        onGetStarted: _completeSplash,
      );
    } else {
      body = MainNavigationShell(
        key: const ValueKey('main_shell'),
        themeData: t,
        themeMode: _themeMode,
        fontSize: _fontSize,
        useSerif: _useSerif,
        lineHeight: _lineHeight,
        appLanguage: _appLanguage,
        bibleVersion: _bibleVersion,
        inlineTargetLanguage: _inlineTargetLanguage,
        onThemeChanged: _updateTheme,
        onFontSizeChanged: _updateFontSize,
        onFontFamilyChanged: _updateFontFamily,
        onLineHeightChanged: _updateLineHeight,
        onLanguageChanged: _updateAppLanguage,
        onVersionChanged: _updateBibleVersion,
        onInlineTargetLanguageChanged: _updateInlineTargetLanguage,
        onReopenSplash: _reopenSplash,
      );
    }

    return MaterialApp(
      title: AppStrings.tr('app_title', _appLanguage),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: t.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: t.accent,
          brightness: isDark ? Brightness.dark : Brightness.light,
          surface: t.surface,
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: body,
      ),
    );
  }
}

// -------------------------------------------------------------
// Layar Sambutan Pertama Kali (First-Run Welcome Splash Screen)
// -------------------------------------------------------------
class WelcomeSplashScreen extends StatelessWidget {
  final AlkitabThemeData themeData;
  final ReadingThemeMode themeMode;
  final String appLanguage;
  final ValueChanged<ReadingThemeMode> onThemeChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onGetStarted;

  const WelcomeSplashScreen({
    super.key,
    required this.themeData,
    required this.themeMode,
    required this.appLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final lang = appLanguage;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar: Quick language switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: t.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: t.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLangPill('id', '🇮🇩 ID', lang, t),
                                _buildLangPill('en', '🇬🇧 EN', lang, t),
                                _buildLangPill('de', '🇩🇪 DE', lang, t),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Logo & App Name
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.tr('welcome_title', lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: t.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.tr('welcome_subtitle', lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.textMuted,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 3 Feature Highlights
                      _buildFeatureCard(
                        icon: Icons.wifi_off_rounded,
                        title: AppStrings.tr('feat_offline_title', lang),
                        desc: AppStrings.tr('feat_offline_desc', lang),
                        t: t,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        icon: Icons.translate_rounded,
                        title: AppStrings.tr('feat_version_title', lang),
                        desc: AppStrings.tr('feat_version_desc', lang),
                        t: t,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        icon: Icons.touch_app_rounded,
                        title: AppStrings.tr('feat_instant_title', lang),
                        desc: AppStrings.tr('feat_instant_desc', lang),
                        t: t,
                      ),

                      const SizedBox(height: 20),

                      // Quick Theme Picker
                      Text(
                        AppStrings.tr('quick_theme_label', lang),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: t.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThemeChoice(
                              mode: ReadingThemeMode.sepia,
                              title: AppStrings.tr('theme_sepia', lang),
                              dotColor: const Color(0xFFEFE8D6),
                              isSelected: themeMode == ReadingThemeMode.sepia,
                              t: t,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeChoice(
                              mode: ReadingThemeMode.light,
                              title: AppStrings.tr('theme_light', lang),
                              dotColor: const Color(0xFFFFFFFF),
                              isSelected: themeMode == ReadingThemeMode.light,
                              t: t,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeChoice(
                              mode: ReadingThemeMode.dark,
                              title: AppStrings.tr('theme_dark', lang),
                              dotColor: const Color(0xFF0F172A),
                              isSelected: themeMode == ReadingThemeMode.dark,
                              t: t,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 22),

                      // Primary CTA (Thumb Zone)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onGetStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.accent,
                            foregroundColor: t.onAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.tr('start_reading', lang),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: t.onAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20, color: t.onAccent),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'v1.2.0 • 100% Offline • Bebas Iklan',
                          style: TextStyle(fontSize: 11, color: t.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLangPill(String code, String label, String currentLang, AlkitabThemeData t) {
    final isSelected = currentLang == code;
    return GestureDetector(
      onTap: () => onLanguageChanged(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? t.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? t.onAccent : t.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required AlkitabThemeData t,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: t.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: t.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChoice({
    required ReadingThemeMode mode,
    required String title,
    required Color dotColor,
    required bool isSelected,
    required AlkitabThemeData t,
  }) {
    return InkWell(
      onTap: () => onThemeChanged(mode),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? t.accent : t.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 0.8),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? t.accent : t.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Shell Navigasi Bawah (Bottom Navigation Bar)
// -------------------------------------------------------------
class MainNavigationShell extends StatefulWidget {
  final AlkitabThemeData themeData;
  final ReadingThemeMode themeMode;
  final double fontSize;
  final bool useSerif;
  final double lineHeight;
  final String appLanguage;
  final BibleVersion bibleVersion;
  final String inlineTargetLanguage;
  final ValueChanged<ReadingThemeMode> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onFontFamilyChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<BibleVersion> onVersionChanged;
  final ValueChanged<String> onInlineTargetLanguageChanged;
  final VoidCallback onReopenSplash;

  const MainNavigationShell({
    super.key,
    required this.themeData,
    required this.themeMode,
    required this.fontSize,
    required this.useSerif,
    required this.lineHeight,
    required this.appLanguage,
    required this.bibleVersion,
    required this.inlineTargetLanguage,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
    required this.onLineHeightChanged,
    required this.onLanguageChanged,
    required this.onVersionChanged,
    required this.onInlineTargetLanguageChanged,
    required this.onReopenSplash,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  List<Book> _books = [];
  Book? _currentBook;
  int _currentChapter = 1;
  List<Verse> _verses = [];
  bool _isLoading = true;
  List<BookmarkItem> _bookmarks = [];
  final ScrollController _readerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(covariant MainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bibleVersion != widget.bibleVersion && _currentBook != null) {
      _reloadVersesForCurrentVersion();
    }
  }

  Future<void> _reloadVersesForCurrentVersion() async {
    if (_currentBook == null) return;
    try {
      final verses = await BibleService.loadVerses(
        _currentBook!.id,
        _currentChapter,
        version: widget.bibleVersion,
      );
      if (mounted) {
        setState(() => _verses = verses);
      }
    } catch (e) {
      debugPrint('Error reloading verses: $e');
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final books = await BibleService.loadBooks();
    final prefs = await SharedPreferences.getInstance();
    final lastBookId = prefs.getInt('alkitab_last_book_id') ?? 43; // Default Yohanes
    final lastChapter = prefs.getInt('alkitab_last_chapter') ?? 1;

    final rawBookmarks = prefs.getStringList('alkitab_bookmarks') ?? [];
    final loadedBookmarks = rawBookmarks
        .map((s) => BookmarkItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    final book = books.firstWhere((b) => b.id == lastBookId, orElse: () => books.first);
    final verses = await BibleService.loadVerses(
      book.id,
      lastChapter,
      version: widget.bibleVersion,
    );

    setState(() {
      _books = books;
      _currentBook = book;
      _currentChapter = lastChapter;
      _verses = verses;
      _bookmarks = loadedBookmarks;
      _isLoading = false;
    });
  }

  Future<void> _changePassage(Book book, int chapter) async {
    final verses = await BibleService.loadVerses(
      book.id,
      chapter,
      version: widget.bibleVersion,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alkitab_last_book_id', book.id);
    await prefs.setInt('alkitab_last_chapter', chapter);

    if (!mounted) return;
    setState(() {
      _currentBook = book;
      _currentChapter = chapter;
      _verses = verses;
    });

    if (_readerScrollController.hasClients) {
      _readerScrollController.jumpTo(0);
    }
  }

  void _navigateToPassage(Book book, int chapter) {
    _changePassage(book, chapter);
    setState(() => _currentIndex = 1);
  }

  bool _isBookmarked(int verseNum) {
    if (_currentBook == null) return false;
    return _bookmarks.any(
      (b) => b.bookId == _currentBook!.id && b.chapter == _currentChapter && b.verse == verseNum,
    );
  }

  Future<void> _toggleBookmark(Verse verse) async {
    if (_currentBook == null) return;
    final exists = _isBookmarked(verse.verse);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (exists) {
        _bookmarks.removeWhere(
          (b) => b.bookId == _currentBook!.id && b.chapter == _currentChapter && b.verse == verse.verse,
        );
      } else {
        _bookmarks.insert(
          0,
          BookmarkItem(
            bookId: _currentBook!.id,
            bookName: _currentBook!.displayName(widget.appLanguage),
            chapter: _currentChapter,
            verse: verse.verse,
            text: verse.text,
            date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            version: widget.bibleVersion.name.toUpperCase(),
          ),
        );
      }
    });

    final serialized = _bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList('alkitab_bookmarks', serialized);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exists
                ? AppStrings.tr('remove_bookmark', widget.appLanguage)
                : '${AppStrings.tr('bookmark_verse', widget.appLanguage)}: ${_currentBook!.displayName(widget.appLanguage)} $_currentChapter:${verse.verse}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alkitab_bookmarks');
    setState(() => _bookmarks.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr('no_bookmarks', widget.appLanguage)),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final lang = widget.appLanguage;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: t.accent))
          : IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  themeData: t,
                  currentBook: _currentBook,
                  currentChapter: _currentChapter,
                  bookmarks: _bookmarks,
                  books: _books,
                  appLanguage: lang,
                  onContinueReading: () => setState(() => _currentIndex = 1),
                  onSelectPassage: _navigateToPassage,
                ),
                BibleReaderView(
                  themeData: t,
                  themeMode: widget.themeMode,
                  fontSize: widget.fontSize,
                  useSerif: widget.useSerif,
                  lineHeight: widget.lineHeight,
                  appLanguage: lang,
                  bibleVersion: widget.bibleVersion,
                  inlineTargetLanguage: widget.inlineTargetLanguage,
                  books: _books,
                  currentBook: _currentBook,
                  currentChapter: _currentChapter,
                  verses: _verses,
                  isBookmarked: _isBookmarked,
                  scrollController: _readerScrollController,
                  onChangePassage: _changePassage,
                  onToggleBookmark: _toggleBookmark,
                  onOpenSearch: _openSearchScreen,
                  onVersionChanged: widget.onVersionChanged,
                  onInlineTargetLanguageChanged: widget.onInlineTargetLanguageChanged,
                ),
                BookmarksView(
                  bookmarks: _bookmarks,
                  themeData: t,
                  appLanguage: lang,
                  onGoToBible: () => setState(() => _currentIndex = 1),
                  onSelectBookmark: (bookmark) {
                    final book = _books.firstWhere((b) => b.id == bookmark.bookId);
                    _navigateToPassage(book, bookmark.chapter);
                  },
                  onRemoveBookmark: (bookmark) async {
                    setState(() {
                      _bookmarks.removeWhere((b) =>
                          b.bookId == bookmark.bookId &&
                          b.chapter == bookmark.chapter &&
                          b.verse == bookmark.verse);
                    });
                    final prefs = await SharedPreferences.getInstance();
                    final serialized = _bookmarks.map((b) => jsonEncode(b.toJson())).toList();
                    await prefs.setStringList('alkitab_bookmarks', serialized);
                  },
                ),
                SettingsScreen(
                  themeData: t,
                  themeMode: widget.themeMode,
                  fontSize: widget.fontSize,
                  useSerif: widget.useSerif,
                  lineHeight: widget.lineHeight,
                  appLanguage: lang,
                  bibleVersion: widget.bibleVersion,
                  inlineTargetLanguage: widget.inlineTargetLanguage,
                  bookmarksCount: _bookmarks.length,
                  onThemeChanged: widget.onThemeChanged,
                  onFontSizeChanged: widget.onFontSizeChanged,
                  onFontFamilyChanged: widget.onFontFamilyChanged,
                  onLineHeightChanged: widget.onLineHeightChanged,
                  onLanguageChanged: widget.onLanguageChanged,
                  onVersionChanged: widget.onVersionChanged,
                  onInlineTargetLanguageChanged: widget.onInlineTargetLanguageChanged,
                  onClearBookmarks: _clearAllBookmarks,
                  onReopenSplash: widget.onReopenSplash,
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: t.surface,
        indicatorColor: t.accent.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: t.textMuted),
            selectedIcon: Icon(Icons.home_rounded, color: t.accent),
            label: AppStrings.tr('home', lang),
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: t.textMuted),
            selectedIcon: Icon(Icons.menu_book_rounded, color: t.accent),
            label: AppStrings.tr('bible', lang),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _bookmarks.isNotEmpty,
              label: Text('${_bookmarks.length}', style: const TextStyle(fontSize: 10)),
              backgroundColor: t.accent,
              child: Icon(Icons.bookmark_border_rounded, color: t.textMuted),
            ),
            selectedIcon: Badge(
              isLabelVisible: _bookmarks.isNotEmpty,
              label: Text('${_bookmarks.length}', style: const TextStyle(fontSize: 10)),
              backgroundColor: t.accent,
              child: Icon(Icons.bookmark_rounded, color: t.accent),
            ),
            label: AppStrings.tr('saved', lang),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: t.textMuted),
            selectedIcon: Icon(Icons.settings_rounded, color: t.accent),
            label: AppStrings.tr('settings', lang),
          ),
        ],
      ),
    );
  }

  void _openSearchScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BibleSearchScreen(
          books: _books,
          currentBookId: _currentBook?.id,
          themeData: widget.themeData,
          appLanguage: widget.appLanguage,
          bibleVersion: widget.bibleVersion,
          onSelectVerse: (book, chapter, verse) {
            Navigator.pop(ctx);
            _navigateToPassage(book, chapter);
          },
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: Beranda (Home Screen)
// -------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final AlkitabThemeData themeData;
  final Book? currentBook;
  final int currentChapter;
  final List<BookmarkItem> bookmarks;
  final List<Book> books;
  final String appLanguage;
  final VoidCallback onContinueReading;
  final void Function(Book book, int chapter) onSelectPassage;

  const HomeScreen({
    super.key,
    required this.themeData,
    required this.currentBook,
    required this.currentChapter,
    required this.bookmarks,
    required this.books,
    required this.appLanguage,
    required this.onContinueReading,
    required this.onSelectPassage,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final lang = appLanguage;
    final now = DateTime.now();

    final dayNamesId = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNamesId = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayNamesEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthNamesEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayNamesDe = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    final monthNamesDe = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];

    final dateString = lang == 'en'
        ? '${dayNamesEn[now.weekday - 1]}, ${monthNamesEn[now.month - 1]} ${now.day}, ${now.year}'
        : (lang == 'de'
            ? '${dayNamesDe[now.weekday - 1]}, ${now.day}. ${monthNamesDe[now.month - 1]} ${now.year}'
            : '${dayNamesId[now.weekday - 1]}, ${now.day} ${monthNamesId[now.month - 1]} ${now.year}');

    final dailyCitation = lang == 'en'
        ? 'Jeremiah 29:11'
        : (lang == 'de' ? 'Jeremia 29:11' : 'Yeremia 29:11');
    final dailyText = lang == 'en'
        ? '“For I know the plans I have for you,” declares the LORD, “plans to prosper you and not to harm you, plans to give you hope and a future.”'
        : (lang == 'de'
            ? '„Denn ich weiß wohl, was ich für Gedanken über euch habe, spricht der HERR: Gedanken des Friedens und nicht des Leides, dass ich euch gebe Zukunft und Hoffnung.“'
            : '“Sebab Aku ini mengetahui rancangan-rancangan apa yang ada pada-Ku mengenai kamu, demikianlah firman TUHAN, yaitu rancangan damai sejahtera dan bukan rancangan kecelakaan, untuk memberikan kepadamu hari depan yang penuh harapan.”');

    final bookDisplayName = currentBook != null
        ? '${currentBook!.displayName(lang)} $currentChapter'
        : (lang == 'en' ? 'Gospel of John' : (lang == 'de' ? 'Johannesevangelium' : 'Kitab Yohanes'));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.tr('app_title', lang),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: t.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Kartu Lanjutkan Membaca
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.accent, t.accent.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.tr('last_read', lang),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  bookDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentBook != null
                      ? '${currentBook!.category} • ${currentBook!.chaptersCount} ${AppStrings.tr('chapters_count', lang)}'
                      : '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: t.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onContinueReading,
                    child: Text(
                      AppStrings.tr('continue_reading', lang),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Akses Cepat / Quick Shortcuts
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: lang == 'en' ? 'Psalms' : 'Kitab Mazmur',
                  subtitle: lang == 'en' ? 'Praise & Prayer' : 'Pujian & Doa',
                  icon: Icons.auto_stories_rounded,
                  t: t,
                  onTap: () {
                    final mazmur = books.firstWhere((b) => b.id == 19, orElse: () => books.first);
                    onSelectPassage(mazmur, 1);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  title: lang == 'en' ? 'Gospel of John' : 'Injil Yohanes',
                  subtitle: lang == 'en' ? 'Life of Jesus' : 'Kabar Sukacita',
                  icon: Icons.menu_book_rounded,
                  t: t,
                  onTap: () {
                    final yohanes = books.firstWhere((b) => b.id == 43, orElse: () => books.first);
                    onSelectPassage(yohanes, 1);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // 3. Ayat Hari Ini (Dengan Tombol Salin dan Bagikan)
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: t.accent),
              const SizedBox(width: 6),
              Text(
                AppStrings.tr('daily_verse', lang),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dailyText,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: t.text,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dailyCitation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: t.accent,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: t.textMuted,
                          tooltip: AppStrings.tr('copy_verse', lang),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '$dailyCitation\n$dailyText'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.tr('verse_copied', lang)),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 18),
                          color: t.accent,
                          tooltip: AppStrings.tr('share_verse', lang),
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text: '$dailyCitation\n$dailyText\n\n— ${AppStrings.tr('app_title', lang)}',
                                subject: dailyCitation,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Riwayat Ayat Ditandai (Terbaru)
          if (bookmarks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tr('recent_bookmarks', lang),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.text),
                ),
                Text(
                  '${bookmarks.length} ${AppStrings.tr('saved', lang).toLowerCase()}',
                  style: TextStyle(fontSize: 12, color: t.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${bookmarks.first.bookName} ${bookmarks.first.chapter}:${bookmarks.first.verse}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: t.accent, fontSize: 14),
                ),
                subtitle: Text(
                  bookmarks.first.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.text, fontSize: 13, height: 1.4),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  final b = books.firstWhere((item) => item.id == bookmarks.first.bookId);
                  onSelectPassage(b, bookmarks.first.chapter);
                },
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.bookmark_border_rounded, size: 18, color: t.textMuted),
                const SizedBox(width: 6),
                Text(
                  AppStrings.tr('recent_bookmarks', lang),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.text),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bookmark_add_outlined, color: t.accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == 'en' ? 'No bookmarked verses yet' : 'Belum ada ayat yang ditandai',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: t.text),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lang == 'en'
                              ? 'Tap any verse while reading to bookmark it here.'
                              : 'Ketuk ayat mana saja saat membaca untuk menandainya di sini.',
                          style: TextStyle(fontSize: 12, color: t.textMuted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required AlkitabThemeData t,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: t.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: t.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: t.text),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: t.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: Alkitab (Pembaca Ayat)
// -------------------------------------------------------------
class BibleReaderView extends StatefulWidget {
  final AlkitabThemeData themeData;
  final ReadingThemeMode themeMode;
  final double fontSize;
  final bool useSerif;
  final double lineHeight;
  final String appLanguage;
  final BibleVersion bibleVersion;
  final String inlineTargetLanguage;
  final List<Book> books;
  final Book? currentBook;
  final int currentChapter;
  final List<Verse> verses;
  final bool Function(int verseNum) isBookmarked;
  final ScrollController scrollController;
  final void Function(Book book, int chapter) onChangePassage;
  final void Function(Verse verse) onToggleBookmark;
  final VoidCallback onOpenSearch;
  final ValueChanged<BibleVersion> onVersionChanged;
  final ValueChanged<String> onInlineTargetLanguageChanged;

  const BibleReaderView({
    super.key,
    required this.themeData,
    required this.themeMode,
    required this.fontSize,
    required this.useSerif,
    required this.lineHeight,
    required this.appLanguage,
    required this.bibleVersion,
    required this.inlineTargetLanguage,
    required this.books,
    required this.currentBook,
    required this.currentChapter,
    required this.verses,
    required this.isBookmarked,
    required this.scrollController,
    required this.onChangePassage,
    required this.onToggleBookmark,
    required this.onOpenSearch,
    required this.onVersionChanged,
    required this.onInlineTargetLanguageChanged,
  });

  @override
  State<BibleReaderView> createState() => _BibleReaderViewState();
}

class _BibleReaderViewState extends State<BibleReaderView> {
  int? _expandedVerse;
  VerseTranslations? _expandedTranslations;

  bool _isHebrewText(String s) {
    for (final rune in s.runes) {
      if (rune >= 0x0590 && rune <= 0x05FF) return true;
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant BibleReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBook?.id != widget.currentBook?.id ||
        oldWidget.currentChapter != widget.currentChapter ||
        oldWidget.bibleVersion != widget.bibleVersion) {
      TtsService.stop();
      _expandedVerse = null;
      _expandedTranslations = null;
    }
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  void _nextChapter() {
    if (widget.currentBook == null) return;
    if (widget.currentChapter < widget.currentBook!.chaptersCount) {
      widget.onChangePassage(widget.currentBook!, widget.currentChapter + 1);
    } else {
      final currentIndex = widget.books.indexOf(widget.currentBook!);
      if (currentIndex < widget.books.length - 1) {
        final nextBook = widget.books[currentIndex + 1];
        widget.onChangePassage(nextBook, 1);
      }
    }
  }

  void _prevChapter() {
    if (widget.currentBook == null) return;
    if (widget.currentChapter > 1) {
      widget.onChangePassage(widget.currentBook!, widget.currentChapter - 1);
    } else {
      final currentIndex = widget.books.indexOf(widget.currentBook!);
      if (currentIndex > 0) {
        final prevBook = widget.books[currentIndex - 1];
        widget.onChangePassage(prevBook, prevBook.chaptersCount);
      }
    }
  }

  void _showBookPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.themeData.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BookPickerSheet(
          books: widget.books,
          currentBook: widget.currentBook,
          currentChapter: widget.currentChapter,
          themeData: widget.themeData,
          appLanguage: widget.appLanguage,
          onSelectPassage: (book, chapter) {
            Navigator.pop(ctx);
            widget.onChangePassage(book, chapter);
          },
        );
      },
    );
  }

  void _showVersionPicker(BuildContext context) {
    final t = widget.themeData;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.tr('choose_version', widget.appLanguage),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.text),
                ),
                const SizedBox(height: 16),
                _buildVersionTile(
                  context,
                  'TB (Terjemahan Baru)',
                  'Bahasa Indonesia',
                  BibleVersion.tb,
                ),
                _buildVersionTile(
                  context,
                  'KJV (King James Version)',
                  'English',
                  BibleVersion.kjv,
                ),
                _buildVersionTile(
                  context,
                  'HEB (עברית / Ibrani)',
                  'Tanakh (WLC) & Perjanjian Baru Ibrani (DHNT)',
                  BibleVersion.hebrew,
                ),
                _buildVersionTile(
                  context,
                  'Paralel / Bilingual (TB + KJV)',
                  'Indonesia & English Berdampingan',
                  BibleVersion.parallel,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionTile(
    BuildContext context,
    String title,
    String subtitle,
    BibleVersion version,
  ) {
    final t = widget.themeData;
    final isSelected = widget.bibleVersion == version;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? t.accent.withValues(alpha: 0.12) : null,
      leading: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: isSelected ? t.accent : t.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? t.accent : t.text,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: t.textMuted, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        widget.onVersionChanged(version);
      },
    );
  }

  void _toggleInlineVerse(Verse v) async {
    if (_expandedVerse == v.verse) {
      setState(() {
        _expandedVerse = null;
        _expandedTranslations = null;
      });
      return;
    }

    setState(() {
      _expandedVerse = v.verse;
      _expandedTranslations = null;
    });

    final trans = await BibleService.loadVerseTranslations(
      widget.currentBook?.id ?? 1,
      widget.currentChapter,
      v.verse,
    );

    if (mounted && _expandedVerse == v.verse) {
      setState(() {
        _expandedTranslations = trans;
      });
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.tr('verse_copied', widget.appLanguage)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInlineTranslationBox(Verse v, VerseTranslations? trans) {
    final t = widget.themeData;
    final bookName = widget.currentBook?.displayName(widget.appLanguage) ?? '';
    final citation = '$bookName ${widget.currentChapter}:${v.verse}';
    final bookmarked = widget.isBookmarked(v.verse);

    if (trans == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
          ),
        ),
      );
    }

    final isTb = widget.bibleVersion == BibleVersion.tb;
    final isKjv = widget.bibleVersion == BibleVersion.kjv;
    final isHeb = widget.bibleVersion == BibleVersion.hebrew;

    final tbText = trans.tb.isNotEmpty ? trans.tb : (isTb ? v.text : '');
    final kjvText = trans.kjv.isNotEmpty ? trans.kjv : (isKjv ? v.text : '');
    final hebText = trans.hebrew.isNotEmpty ? trans.hebrew : (isHeb && _isHebrewText(v.text) ? v.text : '');
    final hebLatin = hebText.isNotEmpty ? HebrewTransliterator.toLatin(hebText) : '';

    final currentTarget = widget.inlineTargetLanguage;
    final showAll = currentTarget == 'all';
    final showTb = currentTarget == 'tb' || (showAll && !isTb && tbText.isNotEmpty);
    final showKjv = currentTarget == 'kjv' || (showAll && !isKjv && kjvText.isNotEmpty);
    final showHeb = currentTarget == 'hebrew' || (showAll && !isHeb);

    final copyBuffer = StringBuffer()..writeln(citation);
    if (showTb && tbText.isNotEmpty) copyBuffer.writeln('(TB): "$tbText"');
    if (showKjv && kjvText.isNotEmpty) copyBuffer.writeln('(KJV): "$kjvText"');
    if (showHeb && hebText.isNotEmpty) {
      copyBuffer.writeln('(HEB): "$hebText"');
      if (hebLatin.isNotEmpty) {
        copyBuffer.writeln('Cara Baca: "$hebLatin"');
      }
    }
    copyBuffer.write('— ${AppStrings.tr('app_title', widget.appLanguage)}');
    final copyPayload = copyBuffer.toString();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.translate_rounded, size: 16, color: t.accent),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.tr('translate_to', widget.appLanguage),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: t.text,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  TtsService.stop();
                  setState(() {
                    _expandedVerse = null;
                    _expandedTranslations = null;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.border.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: t.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildLangChip('all', 'Semua'),
              _buildLangChip('kjv', 'Inggris (KJV)'),
              _buildLangChip('hebrew', 'Ibrani (HEB)'),
              _buildLangChip('tb', 'Indonesia (TB)'),
            ],
          ),
          const SizedBox(height: 12),
          // 1. TB Translation
          if (showTb) ...[
            _buildInlineRow(
              badge: 'TB',
              badgeColor: t.accent,
              title: 'Indonesia',
              text: tbText,
              ttsLang: 'id-ID',
              speakingKey: 'tb_${v.verse}',
              onCopy: () => _copyText('$citation (TB)\n"$tbText"'),
            ),
            const SizedBox(height: 8),
          ],
          // 2. KJV Translation
          if (showKjv) ...[
            _buildInlineRow(
              badge: 'KJV',
              badgeColor: const Color(0xFF0D9488),
              title: 'English',
              text: kjvText,
              isItalic: true,
              ttsLang: 'en-US',
              speakingKey: 'kjv_${v.verse}',
              onCopy: () => _copyText('$citation (KJV)\n"$kjvText"'),
            ),
            const SizedBox(height: 8),
          ],
          // 3. Hebrew Translation
          if (showHeb) ...[
            if (hebText.isNotEmpty)
              _buildInlineRow(
                badge: 'HEB',
                badgeColor: const Color(0xFFEA580C),
                title: 'Ibrani (עברית)',
                text: hebText,
                transliteration: hebLatin,
                isRtl: true,
                ttsLang: 'he-IL',
                speakingKey: 'heb_${v.verse}',
                onCopy: () {
                  final copyMsg = hebLatin.isNotEmpty
                      ? '$citation (HEB)\n"$hebText"\nCara Baca: "$hebLatin"'
                      : '$citation (HEB)\n"$hebText"';
                  _copyText(copyMsg);
                },
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Teks Ibrani belum terpasang di runtime. Jika aplikasi sedang berjalan saat file aset hebrew.json ditambahkan, harap lakukan Hot Restart (tekan huruf R di terminal) agar file hebrew.json terpasang di aplikasi.',
                        style: TextStyle(fontSize: 11.5, color: Colors.amber.shade900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
          // Quick actions toolbar
          Divider(color: t.border.withValues(alpha: 0.8), height: 14),
          Row(
            children: [
              _buildActionPill(
                icon: Icons.copy_rounded,
                label: showAll ? 'Salin Semua' : 'Salin',
                color: t.accent,
                onTap: () => _copyText(copyPayload),
                t: t,
              ),
              const SizedBox(width: 8),
              _buildActionPill(
                icon: Icons.share_rounded,
                label: 'Bagikan',
                color: t.textMuted,
                onTap: () {
                  SharePlus.instance.share(ShareParams(text: copyPayload, subject: citation));
                },
                t: t,
              ),
              const SizedBox(width: 8),
              _buildActionPill(
                icon: bookmarked ? Icons.bookmark_remove : Icons.bookmark_add_outlined,
                label: bookmarked ? 'Tersimpan' : 'Tandai',
                color: bookmarked ? Colors.redAccent : t.textMuted,
                onTap: () => widget.onToggleBookmark(v),
                t: t,
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  TtsService.stop();
                  setState(() {
                    _expandedVerse = null;
                    _expandedTranslations = null;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.border.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 16, color: t.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required AlkitabThemeData t,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineRow({
    required String badge,
    required Color badgeColor,
    required String title,
    required String text,
    String? transliteration,
    bool isItalic = false,
    bool isRtl = false,
    required String ttsLang,
    required String speakingKey,
    required VoidCallback onCopy,
  }) {
    final t = widget.themeData;
    return Column(
      crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: t.textMuted),
            ),
            const Spacer(),
            ValueListenableBuilder<String?>(
              valueListenable: TtsService.activeSpeakingKey,
              builder: (context, activeKey, _) {
                final isSpeakingThis = activeKey == speakingKey;
                return InkWell(
                  onTap: () async {
                    // Jika teks Ibrani dan perangkat belum mengunduh suara Ibrani asli,
                    // putar fonetik Latin agar pengguna tetap mendengar lafalnya dengan jelas.
                    if (ttsLang.startsWith('he')) {
                      final hasHebVoice = await TtsService.isLanguageAvailable('he-IL');
                      if (!hasHebVoice && transliteration != null && transliteration.isNotEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Memutar pelafalan fonetik Latin (Voice pack Ibrani belum diunduh di sistem HP).',
                              ),
                              action: SnackBarAction(
                                label: 'Setelan TTS',
                                onPressed: TtsService.openTtsSettings,
                              ),
                              duration: const Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        await TtsService.speak(
                          transliteration,
                          lang: 'en-US',
                          key: speakingKey,
                        );
                        return;
                      }
                    }

                    final success = await TtsService.speak(
                      text,
                      lang: ttsLang,
                      key: speakingKey,
                    );
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ttsLang.startsWith('he')
                                ? 'Voice pack bahasa Ibrani belum aktif di sistem HP.'
                                : 'Tidak dapat memutar suara untuk bahasa ini.',
                          ),
                          action: ttsLang.startsWith('he')
                              ? SnackBarAction(
                                  label: 'Setelan TTS',
                                  onPressed: TtsService.openTtsSettings,
                                )
                              : null,
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSpeakingThis ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                            key: ValueKey(isSpeakingThis),
                            size: 16,
                            color: isSpeakingThis ? badgeColor : t.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.copy_rounded, size: 14, color: t.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            text,
            style: TextStyle(
              fontSize: isRtl ? 15.5 : 14,
              height: isRtl ? 1.55 : 1.45,
              color: t.text,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        if (transliteration != null && transliteration.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.record_voice_over_outlined, size: 13, color: badgeColor),
                    const SizedBox(width: 5),
                    Text(
                      'Cara Baca (Fonetik):',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                SelectableText(
                  transliteration,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: t.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLangChip(String key, String label) {
    final t = widget.themeData;
    final isSelected = widget.inlineTargetLanguage == key;
    return InkWell(
      onTap: () => widget.onInlineTargetLanguageChanged(key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? t.accent : t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.accent : t.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? t.onAccent : t.textMuted,
          ),
        ),
      ),
    );
  }

  String get _versionLabel {
    switch (widget.bibleVersion) {
      case BibleVersion.tb:
        return 'TB';
      case BibleVersion.kjv:
        return 'KJV';
      case BibleVersion.hebrew:
        return 'HEB';
      case BibleVersion.parallel:
        return 'TB + KJV';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final fontFamily = widget.useSerif ? 'serif' : null;
    final bookName = widget.currentBook?.displayName(widget.appLanguage) ?? '';

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: GestureDetector(
          onTap: () => _showBookPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.currentBook != null ? '$bookName ${widget.currentChapter}' : AppStrings.tr('select_book', widget.appLanguage),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: t.text,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: t.accent),
              ],
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () => _showVersionPicker(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: t.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    _versionLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: t.accent),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: t.accent),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: t.text,
            tooltip: AppStrings.tr('search_verse', widget.appLanguage),
            onPressed: widget.onOpenSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          SelectionArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: ListView.builder(
                key: ValueKey('${widget.currentBook?.id}_${widget.currentChapter}_${widget.bibleVersion.name}'),
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                itemCount: widget.verses.length,
                itemBuilder: (ctx, index) {
                  final v = widget.verses[index];
                  final bookmarked = widget.isBookmarked(v.verse);
                  final isExpanded = _expandedVerse == v.verse;
                  final isHebrew = widget.bibleVersion == BibleVersion.hebrew && _isHebrewText(v.text);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Perikop title
                      if (v.title != null && v.title!.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        Text(
                          v.title!,
                          style: TextStyle(
                            fontSize: widget.fontSize * 1.05,
                            fontWeight: FontWeight.bold,
                            color: t.pericopeTitle,
                            letterSpacing: -0.2,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      InkWell(
                        onTap: () => _toggleInlineVerse(v),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? t.accent.withValues(alpha: 0.12)
                                : (bookmarked ? t.accent.withValues(alpha: 0.08) : null),
                            borderRadius: BorderRadius.circular(8),
                            border: isExpanded
                                ? Border.all(color: t.accent.withValues(alpha: 0.4), width: 1)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
                                child: RichText(
                                  textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.top,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: isHebrew ? 8 : 0,
                                            right: isHebrew ? 0 : 8,
                                            top: 2,
                                          ),
                                          child: Container(
                                            constraints: const BoxConstraints(minWidth: 26),
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: (isExpanded || bookmarked)
                                                  ? t.accent
                                                  : t.verseNumber.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${v.verse}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: (isExpanded || bookmarked) ? Colors.white : t.verseNumber,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: v.text,
                                        style: TextStyle(
                                          fontSize: isHebrew ? widget.fontSize * 1.08 : widget.fontSize,
                                          height: isHebrew ? widget.lineHeight * 1.2 : widget.lineHeight,
                                          color: t.text,
                                          fontFamily: isHebrew ? null : fontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (v.secondaryText != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: t.accent.withValues(alpha: 0.4),
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    v.secondaryText!,
                                    style: TextStyle(
                                      fontSize: widget.fontSize * 0.92,
                                      height: widget.lineHeight,
                                      color: t.textMuted,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                              // INLINE TRANSLATION BOX
                              if (isExpanded)
                                _buildInlineTranslationBox(v, _expandedTranslations),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: t.border.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        color: t.accent,
                        tooltip: AppStrings.tr('prev_chapter', widget.appLanguage),
                        onPressed: (widget.currentBook == null || (widget.currentBook!.id == 1 && widget.currentChapter == 1))
                            ? null
                            : _prevChapter,
                      ),
                      InkWell(
                        onTap: () => _showBookPicker(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 16, color: t.accent),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.currentBook?.displayName(widget.appLanguage) ?? widget.currentBook?.abbr ?? ''} ${widget.currentChapter}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: t.text),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.unfold_more_rounded, size: 18, color: t.textMuted),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                        color: t.accent,
                        tooltip: AppStrings.tr('next_chapter', widget.appLanguage),
                        onPressed: (widget.currentBook == null ||
                                (widget.currentBook!.id == 66 && widget.currentChapter == widget.currentBook!.chaptersCount))
                            ? null
                            : _nextChapter,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: Bookmark (Ayat Tersimpan)
// -------------------------------------------------------------
class BookmarksView extends StatelessWidget {
  final List<BookmarkItem> bookmarks;
  final AlkitabThemeData themeData;
  final String appLanguage;
  final void Function(BookmarkItem bookmark) onSelectBookmark;
  final void Function(BookmarkItem bookmark) onRemoveBookmark;
  final VoidCallback? onGoToBible;

  const BookmarksView({
    super.key,
    required this.bookmarks,
    required this.themeData,
    required this.appLanguage,
    required this.onSelectBookmark,
    required this.onRemoveBookmark,
    this.onGoToBible,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final lang = appLanguage;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text(
          '${AppStrings.tr('saved', lang)} (${bookmarks.length})',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: t.text),
        ),
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: t.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bookmark_border_rounded, size: 48, color: t.accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.tr('no_bookmarks', lang),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: t.text),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.tr('bookmarks_hint', lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.textMuted, fontSize: 13, height: 1.5),
                    ),
                    if (onGoToBible != null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.accent,
                          foregroundColor: t.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(
                          lang == 'en' ? 'Start Reading Bible' : 'Mulai Membaca Alkitab',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: onGoToBible,
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: t.border),
              itemBuilder: (ctx, idx) {
                final b = bookmarks[idx];

                return Dismissible(
                  key: Key('${b.bookId}_${b.chapter}_${b.verse}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          lang == 'en' ? 'Delete' : 'Hapus',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) => onRemoveBookmark(b),
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${b.bookName} ${b.chapter}:${b.verse}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: t.accent, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('• ${b.version}', style: TextStyle(color: t.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                          if (b.date.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(b.date, style: TextStyle(color: t.textMuted, fontSize: 11)),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.share_rounded, size: 16),
                            color: t.textMuted,
                            tooltip: AppStrings.tr('share_verse', lang),
                            onPressed: () {
                              final text = '${b.bookName} ${b.chapter}:${b.verse}\n"${b.text}"\n\n— ${AppStrings.tr('app_title', lang)}';
                              SharePlus.instance.share(ShareParams(text: text, subject: '${b.bookName} ${b.chapter}:${b.verse}'));
                            },
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          b.text,
                          style: TextStyle(color: t.text, fontSize: 14, height: 1.5),
                        ),
                      ),
                      onTap: () => onSelectBookmark(b),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------
// TAB 4: Pengaturan (Settings Screen)
// -------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  final AlkitabThemeData themeData;
  final ReadingThemeMode themeMode;
  final double fontSize;
  final bool useSerif;
  final double lineHeight;
  final String appLanguage;
  final BibleVersion bibleVersion;
  final String inlineTargetLanguage;
  final int bookmarksCount;
  final ValueChanged<ReadingThemeMode> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onFontFamilyChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<BibleVersion> onVersionChanged;
  final ValueChanged<String> onInlineTargetLanguageChanged;
  final VoidCallback onClearBookmarks;
  final VoidCallback onReopenSplash;

  const SettingsScreen({
    super.key,
    required this.themeData,
    required this.themeMode,
    required this.fontSize,
    required this.useSerif,
    required this.lineHeight,
    required this.appLanguage,
    required this.bibleVersion,
    required this.inlineTargetLanguage,
    required this.bookmarksCount,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
    required this.onLineHeightChanged,
    required this.onLanguageChanged,
    required this.onVersionChanged,
    required this.onInlineTargetLanguageChanged,
    required this.onClearBookmarks,
    required this.onReopenSplash,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final lang = appLanguage;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text(
          AppStrings.tr('settings', lang),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: t.text),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. BAHASA APLIKASI
          _buildSectionHeader(AppStrings.tr('app_language', lang), t),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    label: '🇮🇩 Indonesia',
                    selected: lang == 'id',
                    onTap: () => onLanguageChanged('id'),
                    t: t,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    label: '🇬🇧 English',
                    selected: lang == 'en',
                    onTap: () => onLanguageChanged('en'),
                    t: t,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    label: '🇩🇪 Deutsch',
                    selected: lang == 'de',
                    onTap: () => onLanguageChanged('de'),
                    t: t,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. VERSI ALKITAB
          _buildSectionHeader(AppStrings.tr('bible_version', lang), t),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                _buildRadioTile(
                  title: AppStrings.tr('ver_tb', lang),
                  subtitle: 'Alkitab Terjemahan Baru (Bahasa Indonesia)',
                  selected: bibleVersion == BibleVersion.tb,
                  onTap: () => onVersionChanged(BibleVersion.tb),
                  t: t,
                ),
                const Divider(height: 1),
                _buildRadioTile(
                  title: AppStrings.tr('ver_kjv', lang),
                  subtitle: 'King James Version (English)',
                  selected: bibleVersion == BibleVersion.kjv,
                  onTap: () => onVersionChanged(BibleVersion.kjv),
                  t: t,
                ),
                const Divider(height: 1),
                _buildRadioTile(
                  title: AppStrings.tr('ver_hebrew', lang),
                  subtitle: 'Tanakh (WLC) & Perjanjian Baru Ibrani (DHNT)',
                  selected: bibleVersion == BibleVersion.hebrew,
                  onTap: () => onVersionChanged(BibleVersion.hebrew),
                  t: t,
                ),
                const Divider(height: 1),
                _buildRadioTile(
                  title: AppStrings.tr('ver_parallel', lang),
                  subtitle: 'Bilingual (Indonesia & English Berdampingan)',
                  selected: bibleVersion == BibleVersion.parallel,
                  onTap: () => onVersionChanged(BibleVersion.parallel),
                  t: t,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. TERJEMAHAN AYAT LANGSUNG (INLINE QUICK TRANSLATION)
          _buildSectionHeader('TERJEMAHAN AYAT LANGSUNG', t),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih bahasa terjemahan default yang otomatis muncul saat ayat diketuk saat membaca:',
                  style: TextStyle(fontSize: 12.5, color: t.textMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInlineLangChip(
                      key: 'all',
                      label: 'Semua Bahasa',
                      current: inlineTargetLanguage,
                      onChanged: onInlineTargetLanguageChanged,
                      t: t,
                    ),
                    _buildInlineLangChip(
                      key: 'kjv',
                      label: 'Inggris (KJV)',
                      current: inlineTargetLanguage,
                      onChanged: onInlineTargetLanguageChanged,
                      t: t,
                    ),
                    _buildInlineLangChip(
                      key: 'hebrew',
                      label: 'Ibrani (HEB)',
                      current: inlineTargetLanguage,
                      onChanged: onInlineTargetLanguageChanged,
                      t: t,
                    ),
                    _buildInlineLangChip(
                      key: 'tb',
                      label: 'Indonesia (TB)',
                      current: inlineTargetLanguage,
                      onChanged: onInlineTargetLanguageChanged,
                      t: t,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. TEMA WARNA
          _buildSectionHeader(AppStrings.tr('appearance', lang), t),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                _buildThemeCard(
                  label: AppStrings.tr('theme_sepia', lang),
                  mode: ReadingThemeMode.sepia,
                  bg: const Color(0xFFF9F5EA),
                  textCol: const Color(0xFF2E261D),
                  icon: Icons.auto_stories_rounded,
                  t: t,
                ),
                const SizedBox(width: 8),
                _buildThemeCard(
                  label: AppStrings.tr('theme_light', lang),
                  mode: ReadingThemeMode.light,
                  bg: Colors.white,
                  textCol: const Color(0xFF0F172A),
                  icon: Icons.light_mode_rounded,
                  t: t,
                ),
                const SizedBox(width: 8),
                _buildThemeCard(
                  label: AppStrings.tr('theme_dark', lang),
                  mode: ReadingThemeMode.dark,
                  bg: const Color(0xFF0F172A),
                  textCol: const Color(0xFFF8FAFC),
                  icon: Icons.dark_mode_rounded,
                  t: t,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. TIPOGRAFI
          _buildSectionHeader(AppStrings.tr('typography', lang), t),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.tr('font_size', lang), style: TextStyle(color: t.text, fontWeight: FontWeight.w600)),
                    Text('${fontSize.toInt()} px', style: TextStyle(color: t.accent, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: fontSize,
                  min: 14,
                  max: 26,
                  divisions: 6,
                  activeColor: t.accent,
                  onChanged: onFontSizeChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(AppStrings.tr('font_style', lang), style: TextStyle(color: t.text, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    ChoiceChip(
                      label: Text(AppStrings.tr('serif', lang)),
                      selected: useSerif,
                      onSelected: (_) => onFontFamilyChanged(true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(AppStrings.tr('sans', lang)),
                      selected: !useSerif,
                      onSelected: (_) => onFontFamilyChanged(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(AppStrings.tr('preview_text', lang),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: useSerif ? 'serif' : null,
                      height: lineHeight,
                      color: t.text,
                      fontStyle: FontStyle.italic,
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. DATA & PENYIMPANAN (100% OFFLINE)
          _buildSectionHeader(AppStrings.tr('data_storage', lang), t),
          Container(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.offline_pin_rounded, color: Colors.green, size: 28),
                  title: Text(AppStrings.tr('offline_status', lang), style: TextStyle(fontWeight: FontWeight.bold, color: t.text)),
                  subtitle: Text(AppStrings.tr('offline_desc', lang), style: TextStyle(fontSize: 12, color: t.textMuted, height: 1.4)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: Text(AppStrings.tr('clear_bookmarks', lang), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  subtitle: Text('$bookmarksCount ${AppStrings.tr('saved', lang).toLowerCase()}', style: TextStyle(fontSize: 12, color: t.textMuted)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppStrings.tr('confirm_clear_title', lang)),
                        content: Text(AppStrings.tr('confirm_clear_desc', lang)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppStrings.tr('cancel', lang)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onClearBookmarks();
                            },
                            child: Text(AppStrings.tr('delete', lang), style: const TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. TENTANG APLIKASI
          _buildSectionHeader(AppStrings.tr('about_app', lang), t),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.tr('app_title', lang), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: t.text)),
                        Text('Versi 1.2.0 • 100% Offline Multi-Version', style: TextStyle(color: t.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.tr('about_desc', lang),
                  style: TextStyle(fontSize: 13, height: 1.5, color: t.textMuted),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: onReopenSplash,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_outlined, color: t.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.tr('reopen_splash', lang),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: t.accent,
                                ),
                              ),
                              Text(
                                AppStrings.tr('reopen_splash_desc', lang),
                                style: TextStyle(fontSize: 11, color: t.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: t.accent, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AlkitabThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: t.textMuted,
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required AlkitabThemeData t,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? t.accent.withValues(alpha: 0.15) : t.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? t.accent : t.border, width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? t.accent : t.text,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineLangChip({
    required String key,
    required String label,
    required String current,
    required ValueChanged<String> onChanged,
    required AlkitabThemeData t,
  }) {
    final isSelected = current == key;
    return InkWell(
      onTap: () => onChanged(key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? t.accent : t.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.accent : t.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? t.onAccent : t.text,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required AlkitabThemeData t,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: selected ? t.accent : t.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          color: selected ? t.accent : t.text,
          fontSize: 14,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: t.textMuted, fontSize: 12)),
      onTap: onTap,
    );
  }

  Widget _buildThemeCard({
    required String label,
    required ReadingThemeMode mode,
    required Color bg,
    required Color textCol,
    required IconData icon,
    required AlkitabThemeData t,
  }) {
    final isSelected = themeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => onThemeChanged(mode),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 72,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? t.accent : t.border.withValues(alpha: 0.8),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: t.accent.withValues(alpha: 0.16),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? t.accent : textCol.withValues(alpha: 0.75),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? t.accent : textCol,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: t.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Sheet Pemilih Kitab & Pasal
// -------------------------------------------------------------
class BookPickerSheet extends StatefulWidget {
  final List<Book> books;
  final Book? currentBook;
  final int currentChapter;
  final AlkitabThemeData themeData;
  final String appLanguage;
  final void Function(Book book, int chapter) onSelectPassage;

  const BookPickerSheet({
    super.key,
    required this.books,
    required this.currentBook,
    required this.currentChapter,
    required this.themeData,
    required this.appLanguage,
    required this.onSelectPassage,
  });

  @override
  State<BookPickerSheet> createState() => _BookPickerSheetState();
}

class _BookPickerSheetState extends State<BookPickerSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Book? _selectedBookForChapters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.currentBook?.testament == 'PB' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final lang = widget.appLanguage;
    final plBooks = widget.books.where((b) => b.testament == 'PL').toList();
    final pbBooks = widget.books.where((b) => b.testament == 'PB').toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: t.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedBookForChapters != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: t.text,
                      onPressed: () => setState(() => _selectedBookForChapters = null),
                    ),
                    Expanded(
                      child: Text(
                        '${AppStrings.tr('select_book', lang)} - ${_selectedBookForChapters!.displayName(lang)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _selectedBookForChapters!.chaptersCount,
                  itemBuilder: (ctx, idx) {
                    final chapterNum = idx + 1;
                    final isCurrent = widget.currentBook?.id == _selectedBookForChapters!.id &&
                        widget.currentChapter == chapterNum;

                    return InkWell(
                      onTap: () => widget.onSelectPassage(_selectedBookForChapters!, chapterNum),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent ? t.accent : t.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent ? t.accent : t.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$chapterNum',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? t.onAccent : t.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: t.border.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: t.onAccent,
                  unselectedLabelColor: t.textMuted,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: '${AppStrings.tr('ot', lang)} (${plBooks.length})'),
                    Tab(text: '${AppStrings.tr('nt', lang)} (${pbBooks.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookList(plBooks, scrollController, t, lang),
                    _buildBookList(pbBooks, scrollController, t, lang),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBookList(List<Book> list, ScrollController controller, AlkitabThemeData t, String lang) {
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: t.border.withValues(alpha: 0.5)),
      itemBuilder: (ctx, idx) {
        final book = list[idx];
        final isSelected = widget.currentBook?.id == book.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: isSelected ? t.accent.withValues(alpha: 0.1) : null,
          title: Text(
            book.displayName(lang),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? t.accent : t.text,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            '${book.category} • ${book.chaptersCount} ${AppStrings.tr('chapters_count', lang)}',
            style: TextStyle(fontSize: 12, color: t.textMuted),
          ),
          trailing: Text(
            book.abbr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? t.accent : t.textMuted,
              fontSize: 13,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedBookForChapters = book;
            });
          },
        );
      },
    );
  }
}

// -------------------------------------------------------------
// Layar Pencarian Ayat
// -------------------------------------------------------------
class BibleSearchScreen extends StatefulWidget {
  final List<Book> books;
  final int? currentBookId;
  final AlkitabThemeData themeData;
  final String appLanguage;
  final BibleVersion bibleVersion;
  final void Function(Book book, int chapter, int verse) onSelectVerse;

  const BibleSearchScreen({
    super.key,
    required this.books,
    this.currentBookId,
    required this.themeData,
    required this.appLanguage,
    required this.bibleVersion,
    required this.onSelectVerse,
  });

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _searchOnlyCurrentBook = false;

  void _performSearch() async {
    final q = _searchController.text.trim();
    if (q.length < 2) return;

    setState(() => _isSearching = true);
    final results = await BibleService.searchVerses(
      q,
      specificBookId: _searchOnlyCurrentBook ? widget.currentBookId : null,
      version: widget.bibleVersion,
    );

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final lang = widget.appLanguage;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: t.text, fontSize: 16),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: AppStrings.tr('search_hint', lang),
            hintStyle: TextStyle(color: t.textMuted),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    color: t.textMuted,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _results = []);
                    },
                  )
                : null,
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: t.accent,
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: t.surface,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(AppStrings.tr('all_bible', lang)),
                  selected: !_searchOnlyCurrentBook,
                  onSelected: (val) {
                    setState(() => _searchOnlyCurrentBook = false);
                    _performSearch();
                  },
                ),
                const SizedBox(width: 8),
                if (widget.currentBookId != null)
                  ChoiceChip(
                    label: Text(AppStrings.tr('current_book_only', lang)),
                    selected: _searchOnlyCurrentBook,
                    onSelected: (val) {
                      setState(() => _searchOnlyCurrentBook = true);
                      _performSearch();
                    },
                  ),
              ],
            ),
          ),
          if (_results.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: t.surface.withValues(alpha: 0.6),
              child: Text(
                lang == 'en'
                    ? 'Found ${_results.length} verses${_results.length >= 60 ? ' (showing top 60)' : ''}'
                    : 'Ditemukan ${_results.length} ayat${_results.length >= 60 ? ' (menampilkan 60 teratas)' : ''}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textMuted),
              ),
            ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator(color: t.accent))
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchController.text.isEmpty ? Icons.search_rounded : Icons.search_off_rounded,
                              size: 48,
                              color: t.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? (lang == 'en' ? 'Type at least 2 letters to start searching' : 'Ketik minimal 2 huruf untuk mulai mencari')
                                  : (lang == 'en' ? 'No verses found' : 'Tidak ada ayat ditemukan'),
                              style: TextStyle(color: t.textMuted, fontSize: 13.5),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: t.border),
                        itemBuilder: (ctx, idx) {
                          final item = _results[idx];
                          final book = item['book'] as Book;
                          final chapter = item['chapter'] as int;
                          final verse = item['verse'] as int;
                          final text = item['text'] as String;

                          return ListTile(
                            title: Text(
                              '${book.displayName(lang)} $chapter:$verse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.accent,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                text,
                                style: TextStyle(color: t.text, fontSize: 14, height: 1.4),
                              ),
                            ),
                            onTap: () => widget.onSelectVerse(book, chapter, verse),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
