import 'dart:convert';
import 'package:flutter/services.dart';

enum BibleVersion { tb, kjv, hebrew, parallel }

class VerseTranslations {
  final String tb;
  final String kjv;
  final String hebrew;

  const VerseTranslations({
    required this.tb,
    required this.kjv,
    required this.hebrew,
  });
}

class Book {
  final int id;
  final String name;
  final String englishName;
  final String germanName;
  final String abbr;
  final String testament; // "PL" or "PB"
  final String category;
  final int chaptersCount;

  Book({
    required this.id,
    required this.name,
    required this.englishName,
    this.germanName = '',
    required this.abbr,
    required this.testament,
    required this.category,
    required this.chaptersCount,
  });

  factory Book.fromJson(Map<String, dynamic> json, String englishName, [String? germanName]) {
    return Book(
      id: json['id'] as int,
      name: json['name'] as String,
      englishName: englishName,
      germanName: germanName ?? englishName,
      abbr: json['abbr'] as String,
      testament: json['testament'] as String,
      category: json['category'] as String,
      chaptersCount: json['chaptersCount'] as int,
    );
  }

  String displayName(String lang) {
    if (lang == 'de' && germanName.isNotEmpty) return germanName;
    if (lang == 'en') return englishName;
    return name;
  }
}

class Verse {
  final int verse;
  final String text;
  final String? title;
  final String? secondaryText; // Untuk mode paralel (KJV / TB)

  Verse({
    required this.verse,
    required this.text,
    this.title,
    this.secondaryText,
  });

  static String cleanHtml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll(RegExp(r'</?br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  factory Verse.fromJson(Map<String, dynamic> json, {String? secondaryText}) {
    final rawTitle = json['title'] as String?;
    final rawText = json['text'] as String;
    return Verse(
      verse: json['verse'] as int,
      text: cleanHtml(rawText),
      title: rawTitle != null ? cleanHtml(rawTitle) : null,
      secondaryText: secondaryText != null ? cleanHtml(secondaryText) : null,
    );
  }
}

class BookmarkItem {
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String date;
  final String version;

  BookmarkItem({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.date,
    this.version = 'TB',
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'date': date,
    'version': version,
  };

  factory BookmarkItem.fromJson(Map<String, dynamic> json) => BookmarkItem(
    bookId: json['bookId'] as int,
    bookName: json['bookName'] as String,
    chapter: json['chapter'] as int,
    verse: json['verse'] as int,
    text: Verse.cleanHtml(json['text'] as String),
    date: json['date'] as String? ?? '',
    version: json['version'] as String? ?? 'TB',
  );
}

class BibleService {
  static List<Book>? _cachedBooks;
  static final Map<int, Map<String, dynamic>> _cachedBookContents = {};
  static List<dynamic>? _cachedKjvData;
  static List<dynamic>? _cachedHebrewData;

  static const List<String> _englishBookNames = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua',
    'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings',
    '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job',
    'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
    'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah',
    'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke',
    'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
    'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy',
    '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter',
    '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'
  ];

  static const List<String> _germanBookNames = [
    '1. Mose', '2. Mose', '3. Mose', '4. Mose', '5. Mose', 'Josua',
    'Richter', 'Rut', '1. Samuel', '2. Samuel', '1. Könige', '2. Könige',
    '1. Chronik', '2. Chronik', 'Esra', 'Nehemia', 'Ester', 'Hiob',
    'Psalmen', 'Sprüche', 'Prediger', 'Hohelied', 'Jesaja', 'Jeremia',
    'Klagelieder', 'Hesekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadja', 'Jona', 'Micha', 'Nahum', 'Habakuk', 'Zefanja',
    'Haggai', 'Sacharja', 'Maleachi', 'Matthäus', 'Markus', 'Lukas',
    'Johannes', 'Apostelgeschichte', 'Römer', '1. Korinther', '2. Korinther', 'Galater',
    'Epheser', 'Philipper', 'Kolosser', '1. Thessalonicher', '2. Thessalonicher', '1. Timotheus',
    '2. Timotheus', 'Titus', 'Philemon', 'Hebräer', 'Jakobus', '1. Petrus',
    '2. Petrus', '1. Johannes', '2. Johannes', '3. Johannes', 'Judas', 'Offenbarung'
  ];

  static Future<List<Book>> loadBooks() async {
    if (_cachedBooks != null) return _cachedBooks!;
    final String raw = await rootBundle.loadString('assets/books.json');
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;

    _cachedBooks = [];
    for (int i = 0; i < list.length; i++) {
      final engName = i < _englishBookNames.length ? _englishBookNames[i] : (list[i]['name'] as String);
      final gerName = i < _germanBookNames.length ? _germanBookNames[i] : engName;
      _cachedBooks!.add(Book.fromJson(list[i] as Map<String, dynamic>, engName, gerName));
    }
    return _cachedBooks!;
  }

  static Future<List<dynamic>> _loadKjvData() async {
    if (_cachedKjvData != null) return _cachedKjvData!;
    final String raw = await rootBundle.loadString('assets/kjv.json');
    _cachedKjvData = jsonDecode(raw) as List<dynamic>;
    return _cachedKjvData!;
  }

  static Future<List<dynamic>> _loadHebrewData() async {
    if (_cachedHebrewData != null) return _cachedHebrewData!;
    final String raw = await rootBundle.loadString('assets/hebrew.json');
    _cachedHebrewData = jsonDecode(raw) as List<dynamic>;
    return _cachedHebrewData!;
  }

  static Future<List<Verse>> loadVerses(
    int bookId,
    int chapter, {
    BibleVersion version = BibleVersion.tb,
  }) async {
    // 1. Ambil data TB (Bahasa Indonesia) dari assets lokal
    Map<String, dynamic>? tbData = _cachedBookContents[bookId];
    if (tbData == null) {
      final String raw = await rootBundle.loadString('assets/books/$bookId.json');
      tbData = jsonDecode(raw) as Map<String, dynamic>;
      _cachedBookContents[bookId] = tbData;
    }

    final chapters = tbData['chapters'] as Map<String, dynamic>;
    final chapterKey = chapter.toString();
    final List<dynamic> rawTbVerses = chapters[chapterKey] as List<dynamic>? ?? [];

    // 2. Ambil data KJV / Hebrew dari assets lokal jika dibutuhkan
    List<dynamic> rawKjvVerses = [];
    List<dynamic> rawHebVerses = [];
    if (version == BibleVersion.kjv || version == BibleVersion.parallel) {
      final kjvList = await _loadKjvData();
      final bookIndex = bookId - 1;
      if (bookIndex >= 0 && bookIndex < kjvList.length) {
        final bookMap = kjvList[bookIndex] as Map<String, dynamic>;
        final kjvChapters = bookMap['chapters'] as List<dynamic>;
        final chapterIndex = chapter - 1;
        if (chapterIndex >= 0 && chapterIndex < kjvChapters.length) {
          rawKjvVerses = kjvChapters[chapterIndex] as List<dynamic>;
        }
      }
    } else if (version == BibleVersion.hebrew) {
      try {
        final hebList = await _loadHebrewData();
        final bookIndex = bookId - 1;
        if (bookIndex >= 0 && bookIndex < hebList.length) {
          final bookMap = hebList[bookIndex] as Map<String, dynamic>;
          final hebChapters = bookMap['chapters'] as List<dynamic>;
          final chapterIndex = chapter - 1;
          if (chapterIndex >= 0 && chapterIndex < hebChapters.length) {
            rawHebVerses = hebChapters[chapterIndex] as List<dynamic>;
          }
        }
      } catch (_) {
        rawHebVerses = [];
      }
    }

    // 3. Gabungkan dan bersihkan tag HTML (<br/>, dll)
    final List<Verse> result = [];

    if (version == BibleVersion.kjv) {
      for (int i = 0; i < rawKjvVerses.length; i++) {
        final verseNum = i + 1;
        final kjvText = Verse.cleanHtml(rawKjvVerses[i] as String);
        String? title;
        if (i < rawTbVerses.length) {
          title = Verse.cleanHtml(rawTbVerses[i]['title'] as String?);
        }
        result.add(Verse(
          verse: verseNum,
          text: kjvText,
          title: title,
        ));
      }
    } else if (version == BibleVersion.hebrew) {
      if (rawHebVerses.isEmpty) {
        result.add(Verse(
          verse: 1,
          text: 'Teks Ibrani belum termuat. Jika baru menambahkan file aset hebrew.json, lakukan Hot Restart di terminal (tekan R kapital) agar aset terpasang di runtime.',
          title: 'Perhatian: Perlu Hot Restart (R)',
        ));
      } else {
        for (int i = 0; i < rawHebVerses.length; i++) {
          final verseNum = i + 1;
          final hebText = Verse.cleanHtml(rawHebVerses[i] as String);
          String? title;
          if (i < rawTbVerses.length) {
            title = Verse.cleanHtml(rawTbVerses[i]['title'] as String?);
          }
          result.add(Verse(
            verse: verseNum,
            text: hebText,
            title: title,
          ));
        }
      }
    } else if (version == BibleVersion.parallel) {
      for (int i = 0; i < rawTbVerses.length; i++) {
        final tbMap = rawTbVerses[i] as Map<String, dynamic>;
        final verseNum = tbMap['verse'] as int;
        final tbText = Verse.cleanHtml(tbMap['text'] as String);
        final title = Verse.cleanHtml(tbMap['title'] as String?);

        String? kjvText;
        if (i < rawKjvVerses.length) {
          kjvText = Verse.cleanHtml(rawKjvVerses[i] as String);
        }

        result.add(Verse(
          verse: verseNum,
          text: tbText,
          title: title,
          secondaryText: kjvText,
        ));
      }
    } else {
      // Default: Versi TB (Terjemahan Baru)
      for (final item in rawTbVerses) {
        result.add(Verse.fromJson(item as Map<String, dynamic>));
      }
    }

    return result;
  }

  static Future<List<Map<String, dynamic>>> searchVerses(
    String query, {
    int? specificBookId,
    BibleVersion version = BibleVersion.tb,
  }) async {
    final books = await loadBooks();
    final List<Map<String, dynamic>> results = [];
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.length < 2) return results;

    final targetBooks = specificBookId != null
        ? books.where((b) => b.id == specificBookId)
        : books;

    if (version == BibleVersion.kjv) {
      final kjvList = await _loadKjvData();
      for (final book in targetBooks) {
        final bookIndex = book.id - 1;
        if (bookIndex < 0 || bookIndex >= kjvList.length) continue;
        final bookMap = kjvList[bookIndex] as Map<String, dynamic>;
        final kjvChapters = bookMap['chapters'] as List<dynamic>;

        for (int c = 0; c < kjvChapters.length; c++) {
          final chapterNum = c + 1;
          final verseList = kjvChapters[c] as List<dynamic>;
          for (int v = 0; v < verseList.length; v++) {
            final text = Verse.cleanHtml(verseList[v] as String);
            if (text.toLowerCase().contains(lowerQuery)) {
              results.add({
                'book': book,
                'chapter': chapterNum,
                'verse': v + 1,
                'text': text,
              });
              if (results.length >= 60) return results;
            }
          }
        }
      }
    } else if (version == BibleVersion.hebrew) {
      final hebList = await _loadHebrewData();
      for (final book in targetBooks) {
        final bookIndex = book.id - 1;
        if (bookIndex < 0 || bookIndex >= hebList.length) continue;
        final bookMap = hebList[bookIndex] as Map<String, dynamic>;
        final hebChapters = bookMap['chapters'] as List<dynamic>;

        for (int c = 0; c < hebChapters.length; c++) {
          final chapterNum = c + 1;
          final verseList = hebChapters[c] as List<dynamic>;
          for (int v = 0; v < verseList.length; v++) {
            final text = Verse.cleanHtml(verseList[v] as String);
            if (text.toLowerCase().contains(lowerQuery)) {
              results.add({
                'book': book,
                'chapter': chapterNum,
                'verse': v + 1,
                'text': text,
              });
              if (results.length >= 60) return results;
            }
          }
        }
      }
    } else {
      for (final book in targetBooks) {
        Map<String, dynamic>? bookData = _cachedBookContents[book.id];
        if (bookData == null) {
          try {
            final String raw = await rootBundle.loadString('assets/books/${book.id}.json');
            bookData = jsonDecode(raw) as Map<String, dynamic>;
            _cachedBookContents[book.id] = bookData;
          } catch (_) {
            continue;
          }
        }

        final chapters = bookData['chapters'] as Map<String, dynamic>;
        for (final entry in chapters.entries) {
          final chapterNum = int.tryParse(entry.key) ?? 1;
          final list = entry.value as List<dynamic>;
          for (final v in list) {
            final verseMap = v as Map<String, dynamic>;
            final text = Verse.cleanHtml(verseMap['text'] as String? ?? '');
            if (text.toLowerCase().contains(lowerQuery)) {
              results.add({
                'book': book,
                'chapter': chapterNum,
                'verse': verseMap['verse'] as int,
                'text': text,
                'title': Verse.cleanHtml(verseMap['title'] as String?),
              });
              if (results.length >= 60) return results;
            }
          }
        }
      }
    }
    return results;
  }
  static Future<VerseTranslations> loadVerseTranslations(
    int bookId,
    int chapter,
    int verseNum,
  ) async {
    // 1. TB text
    String tbText = '';
    Map<String, dynamic>? tbData = _cachedBookContents[bookId];
    if (tbData == null) {
      try {
        final String raw = await rootBundle.loadString('assets/books/$bookId.json');
        tbData = jsonDecode(raw) as Map<String, dynamic>;
        _cachedBookContents[bookId] = tbData;
      } catch (_) {}
    }
    if (tbData != null) {
      final chapters = tbData['chapters'] as Map<String, dynamic>;
      final list = chapters[chapter.toString()] as List<dynamic>? ?? [];
      for (final item in list) {
        if (item['verse'] == verseNum) {
          tbText = Verse.cleanHtml(item['text'] as String? ?? '');
          break;
        }
      }
    }

    // 2. KJV text
    String kjvText = '';
    try {
      final kjvList = await _loadKjvData();
      final bookIndex = bookId - 1;
      if (bookIndex >= 0 && bookIndex < kjvList.length) {
        final bookMap = kjvList[bookIndex] as Map<String, dynamic>;
        final kjvChapters = bookMap['chapters'] as List<dynamic>;
        final cIndex = chapter - 1;
        if (cIndex >= 0 && cIndex < kjvChapters.length) {
          final versesList = kjvChapters[cIndex] as List<dynamic>;
          final vIndex = verseNum - 1;
          if (vIndex >= 0 && vIndex < versesList.length) {
            kjvText = Verse.cleanHtml(versesList[vIndex] as String);
          }
        }
      }
    } catch (_) {}

    // 3. Hebrew text
    String hebText = '';
    try {
      final hebList = await _loadHebrewData();
      final bookIndex = bookId - 1;
      if (bookIndex >= 0 && bookIndex < hebList.length) {
        final bookMap = hebList[bookIndex] as Map<String, dynamic>;
        final hebChapters = bookMap['chapters'] as List<dynamic>;
        final cIndex = chapter - 1;
        if (cIndex >= 0 && cIndex < hebChapters.length) {
          final versesList = hebChapters[cIndex] as List<dynamic>;
          final vIndex = verseNum - 1;
          if (vIndex >= 0 && vIndex < versesList.length) {
            hebText = Verse.cleanHtml(versesList[vIndex] as String);
          }
        }
      }
    } catch (_) {}

    return VerseTranslations(
      tb: tbText,
      kjv: kjvText,
      hebrew: hebText,
    );
  }
}