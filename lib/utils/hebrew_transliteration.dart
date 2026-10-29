/// Utility untuk mengubah teks Alkitab Ibrani (dengan tanda vokal Niqqud)
/// menjadi transliterasi fonetik alfabet Latin (cara baca fonetik).
/// Bekerja 100% offline tanpa dependensi eksternal (stdlib pure Dart).
class HebrewTransliterator {
  static String toLatin(String hebrewText) {
    if (hebrewText.trim().isEmpty) return '';

    // Buang aksen kantilasi (Ta'amei Hamikra: U+0591 s/d U+05AF)
    final cleanRunes = <int>[];
    for (final r in hebrewText.runes) {
      if (r >= 0x0591 && r <= 0x05AF) continue;
      cleanRunes.add(r);
    }

    final buffer = StringBuffer();
    final len = cleanRunes.length;
    int i = 0;

    while (i < len) {
      final r = cleanRunes[i];

      // Spasi
      if (r == 0x0020 || r == 0x00A0) {
        buffer.write(' ');
        i++;
        continue;
      }
      // Maqaf (Tanda hubung Ibrani) -> '-'
      if (r == 0x05BE) {
        buffer.write('-');
        i++;
        continue;
      }
      // Sof Pasuq / Titik Dua akhir ayat
      if (r == 0x05C3 || r == 0x003A) {
        buffer.write('.');
        i++;
        continue;
      }

      // Huruf Konsonan Ibrani (0x05D0 s/d 0x05EA)
      if (r >= 0x05D0 && r <= 0x05EA) {
        final letter = r;
        i++;

        bool hasDagesh = false;
        int shinSin = 0; // 1 = Shin, 2 = Sin
        String vowel = '';

        while (i < len &&
            ((cleanRunes[i] >= 0x05B0 && cleanRunes[i] <= 0x05BC) ||
                cleanRunes[i] == 0x05C1 ||
                cleanRunes[i] == 0x05C2)) {
          final mark = cleanRunes[i];
          if (mark == 0x05BC) {
            hasDagesh = true;
          } else if (mark == 0x05C1) {
            shinSin = 1;
          } else if (mark == 0x05C2) {
            shinSin = 2;
          } else if (mark == 0x05B0) {
            final nextIsBoundary = (i + 1 >= len) ||
                cleanRunes[i + 1] == 0x0020 ||
                cleanRunes[i + 1] == 0x05BE ||
                cleanRunes[i + 1] == 0x05C3 ||
                cleanRunes[i + 1] == 0x003A;
            vowel = nextIsBoundary ? '' : "'";
          } else if (mark == 0x05B1) {
            vowel = 'e';
          } else if (mark == 0x05B2) {
            vowel = 'a';
          } else if (mark == 0x05B3) {
            vowel = 'o';
          } else if (mark == 0x05B4) {
            vowel = 'i';
          } else if (mark == 0x05B5) {
            vowel = 'e';
          } else if (mark == 0x05B6) {
            vowel = 'e';
          } else if (mark == 0x05B7) {
            vowel = 'a';
          } else if (mark == 0x05B8) {
            vowel = 'a';
          } else if (mark == 0x05B9 || mark == 0x05BA) {
            vowel = 'o';
          } else if (mark == 0x05BB) {
            vowel = 'u';
          }
          i++;
        }

        // Shuruq (Vav dengan dagesh) -> 'u'
        if (letter == 0x05D5 && hasDagesh && vowel.isEmpty) {
          buffer.write('u');
          continue;
        }

        // Holam Male (Vav dengan holam) -> 'o'
        if (letter == 0x05D5 && (vowel == 'o' || vowel.isEmpty && i < len && cleanRunes[i - 1] == 0x05B9)) {
          buffer.write('o');
          continue;
        }

        // Yod setelah vokal i / e (Mater lectionis)
        if (letter == 0x05D9 && vowel.isEmpty) {
          final str = buffer.toString();
          if (str.endsWith('i') || str.endsWith('e')) {
            continue;
          }
        }

        // Bunyi konsonan
        String cons = '';
        switch (letter) {
          case 0x05D0: // Alef
            cons = (buffer.isEmpty || buffer.toString().endsWith(' ') || buffer.toString().endsWith('-')) ? '' : "'";
            break;
          case 0x05D1: // Bet / Vet
            cons = hasDagesh ? 'b' : 'v';
            break;
          case 0x05D2: // Gimel
            cons = 'g';
            break;
          case 0x05D3: // Dalet
            cons = 'd';
            break;
          case 0x05D4: // He
            if (vowel.isEmpty && (i >= len || cleanRunes[i] == 0x0020 || cleanRunes[i] == 0x05BE || cleanRunes[i] == 0x05C3)) {
              cons = '';
            } else {
              cons = 'h';
            }
            break;
          case 0x05D5: // Vav
            cons = 'v';
            break;
          case 0x05D6: // Zayin
            cons = 'z';
            break;
          case 0x05D7: // Chet
            cons = 'ch';
            break;
          case 0x05D8: // Tet
            cons = 't';
            break;
          case 0x05D9: // Yod
            cons = 'y';
            break;
          case 0x05DA: // Final Khaf
          case 0x05DB: // Kaf / Khaf
            cons = hasDagesh ? 'k' : 'kh';
            break;
          case 0x05DC: // Lamed
            cons = 'l';
            break;
          case 0x05DD: // Final Mem
          case 0x05DE: // Mem
            cons = 'm';
            break;
          case 0x05DF: // Final Nun
          case 0x05E0: // Nun
            cons = 'n';
            break;
          case 0x05E1: // Samekh
            cons = 's';
            break;
          case 0x05E2: // Ayin
            cons = "'";
            break;
          case 0x05E3: // Final Pe
          case 0x05E4: // Pe
            cons = hasDagesh ? 'p' : 'f';
            break;
          case 0x05E5: // Final Tsadi
          case 0x05E6: // Tsadi
            cons = 'ts';
            break;
          case 0x05E7: // Qof
            cons = 'q';
            break;
          case 0x05E8: // Resh
            cons = 'r';
            break;
          case 0x05E9: // Shin / Sin
            cons = (shinSin == 2) ? 's' : 'sh';
            break;
          case 0x05EA: // Tav
            cons = 't';
            break;
          default:
            cons = '';
        }

        buffer.write(cons);
        buffer.write(vowel);
      } else {
        buffer.write(String.fromCharCode(r));
        i++;
      }
    }

    var result = buffer.toString().trim();
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    result = result.replaceAll(" '", " ");
    result = result.replaceAll(" -", "-");
    result = result.replaceAll("- ", "-");
    result = result.replaceAll("''", "'");
    return result;
  }
}

