import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alkitabz/main.dart';
import 'package:alkitabz/models/bible_models.dart';
import 'package:alkitabz/utils/hebrew_transliteration.dart';
import 'package:alkitabz/services/tts_service.dart';

void main() {
  testWidgets('AlkitabApp basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlkitabApp());
    expect(find.byType(AlkitabApp), findsOneWidget);
  });

  testWidgets('WelcomeSplashScreen appears on first install and dismisses on tap', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'alkitab_has_seen_splash': false});
    await tester.pumpWidget(const AlkitabApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify splash screen appears
    expect(find.byType(WelcomeSplashScreen), findsOneWidget);
    expect(find.text('Selamat Datang di Alkitabz'), findsOneWidget);
    expect(find.text('Mulai Membaca Sekarang'), findsOneWidget);

    // Scroll button into view and tap
    await tester.ensureVisible(find.text('Mulai Membaca Sekarang'));
    await tester.tap(find.text('Mulai Membaca Sekarang'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Should transition to MainNavigationShell
    expect(find.byType(WelcomeSplashScreen), findsNothing);
    expect(find.byType(MainNavigationShell), findsOneWidget);

    // Verify preference is persisted
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('alkitab_has_seen_splash'), isTrue);
  });

  testWidgets('Splash screen is skipped when already seen before', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'alkitab_has_seen_splash': true});
    await tester.pumpWidget(const AlkitabApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(WelcomeSplashScreen), findsNothing);
    expect(find.byType(MainNavigationShell), findsOneWidget);
  });

  testWidgets('HomeScreen renders brand logo and app title in AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          themeData: AlkitabThemeData.sepia,
          currentBook: null,
          currentChapter: 1,
          bookmarks: const [],
          books: const [],
          appLanguage: 'id',
          onContinueReading: () {},
          onSelectPassage: (_, __) {},
        ),
      ),
    );

    expect(find.text('Alkitabz'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  test('Verse.cleanHtml strips <br/> and HTML tags cleanly', () {
    const rawTitle = 'Jilid 1<br/>(Mazmur 1-41)<br/>Kebahagiaan Sejati dalam Hukum Allah';
    final cleaned = Verse.cleanHtml(rawTitle);

    expect(cleaned.contains('<br/>'), isFalse);
    expect(cleaned.contains('</br>'), isFalse);
    expect(cleaned.contains('<br>'), isFalse);
    expect(cleaned, equals('Jilid 1\n(Mazmur 1-41)\nKebahagiaan Sejati dalam Hukum Allah'));

    const rawWithTags = '<b>Yesus</b> berkata: <i>“Akulah jalan”</i></br>';
    final cleanedTags = Verse.cleanHtml(rawWithTags);
    expect(cleanedTags, equals('Yesus berkata: “Akulah jalan”'));
  });

  test('BibleVersion includes Hebrew support', () {
    expect(BibleVersion.values.contains(BibleVersion.hebrew), isTrue);
  });

  test('VerseTranslations creates model correctly', () {
    const trans = VerseTranslations(
      tb: 'Pada mulanya',
      kjv: 'In the beginning',
      hebrew: 'בְּרֵאשִׁית',
    );
    expect(trans.tb, equals('Pada mulanya'));
    expect(trans.kjv, equals('In the beginning'));
    expect(trans.hebrew, equals('בְּרֵאשִׁית'));
  });

  testWidgets('BibleService loads Hebrew translations correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final trans = await BibleService.loadVerseTranslations(19, 1, 1);
      expect(trans.tb.isNotEmpty, isTrue);
      expect(trans.kjv.isNotEmpty, isTrue);
      expect(trans.hebrew.isNotEmpty, isTrue);
    });
  });

  test('HebrewTransliterator accurately transliterates pointed Hebrew text to Latin', () {
    const mzm24 = 'יוֹשֵׁב בַּשָּׁמַיִם יִשְׂחָק אֲדֹנָי יִלְעַג־לָמוֹ:';
    final latin = HebrewTransliterator.toLatin(mzm24);

    expect(latin.startsWith('Yoshev'), isTrue);
    expect(latin.contains('bashamayim'), isTrue);
    expect(latin.contains('adonay'), isTrue);
    expect(latin.contains('yil\'ag-lamo'), isTrue);
  });

  test('TtsService state management works correctly', () async {
    TtsService.init();
    expect(TtsService.isSpeaking.value, isFalse);
    expect(TtsService.activeSpeakingKey.value, isNull);

    await TtsService.stop();
    expect(TtsService.isSpeaking.value, isFalse);
  });

  test('German language support and Book.displayName work properly', () {
    expect(AppStrings.tr('app_title', 'de'), equals('Alkitabz'));
    expect(AppStrings.tr('bible', 'de'), equals('Bibel'));
    expect(AppStrings.tr('start_reading', 'de'), equals('Jetzt mit dem Lesen beginnen'));

    final book = Book(
      id: 19,
      name: 'Mazmur',
      englishName: 'Psalms',
      germanName: 'Psalmen',
      abbr: 'Mzm',
      testament: 'PL',
      category: 'Puisi',
      chaptersCount: 150,
    );

    expect(book.displayName('id'), equals('Mazmur'));
    expect(book.displayName('en'), equals('Psalms'));
    expect(book.displayName('de'), equals('Psalmen'));
  });
}
