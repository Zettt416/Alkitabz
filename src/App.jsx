import React, { useState, useEffect, useRef } from 'react';

// Lightweight SVG Icons (Zero dependencies - ponytail)
const Icons = {
  Book: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
    </svg>
  ),
  Search: () => (
    <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="8"/>
      <line x1="21" y1="21" x2="16.65" y2="16.65"/>
    </svg>
  ),
  TextSettings: () => (
    <span style={{ fontWeight: 800, fontSize: '1.05rem', letterSpacing: '-0.05em' }}>Aa</span>
  ),
  BookmarkList: () => (
    <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
    </svg>
  ),
  ChevronLeft: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="15 18 9 12 15 6"/>
    </svg>
  ),
  ChevronRight: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="9 18 15 12 9 6"/>
    </svg>
  ),
  Close: () => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <line x1="18" y1="6" x2="6" y2="18"/>
      <line x1="6" y1="6" x2="18" y2="18"/>
    </svg>
  ),
  Copy: () => (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
      <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
    </svg>
  ),
  ImageCard: () => (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
      <circle cx="8.5" cy="8.5" r="1.5"/>
      <polyline points="21 15 16 10 5 21"/>
    </svg>
  ),
  Download: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <polyline points="7 10 12 15 17 10"/>
      <line x1="12" y1="15" x2="12" y2="3"/>
    </svg>
  ),
  Bookmark: ({ filled }) => (
    <svg width="15" height="15" viewBox="0 0 24 24" fill={filled ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
    </svg>
  ),
  Share: () => (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="18" cy="5" r="3"/>
      <circle cx="6" cy="12" r="3"/>
      <circle cx="18" cy="19" r="3"/>
      <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
      <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
    </svg>
  ),
  CloudCheck: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 16.2A4.5 4.5 0 0 0 17.5 8h-1.8A7 7 0 1 0 4 14.9"/>
      <polyline points="9 15 12 18 17 13"/>
    </svg>
  )
};

export default function App() {
  // Navigation & Books State
  const [books, setBooks] = useState([]);
  const [currentBookId, setCurrentBookId] = useState(() => {
    return parseInt(localStorage.getItem('alkitab_book_id') || '43', 10); // Yohanes
  });
  const [currentChapter, setCurrentChapter] = useState(() => {
    return parseInt(localStorage.getItem('alkitab_chapter') || '1', 10);
  });
  const [bookCache, setBookCache] = useState({});
  const [loading, setLoading] = useState(true);

  // Appearance
  const [theme, setTheme] = useState(() => localStorage.getItem('alkitab_theme') || 'sepia');
  const [fontSize, setFontSize] = useState(() => parseInt(localStorage.getItem('alkitab_font_size') || '19', 10));
  const [fontFamily, setFontFamily] = useState(() => localStorage.getItem('alkitab_font_family') || 'serif');
  const [lineHeight, setLineHeight] = useState(() => localStorage.getItem('alkitab_line_height') || '1.85');

  // Reading progress scroll state
  const [scrollProgress, setScrollProgress] = useState(0);

  // Interactivity
  const [selectedVerse, setSelectedVerse] = useState(null);
  
  // Highlights: { [passageKey]: 'yellow' | 'green' | 'blue' | 'pink' }
  const [highlights, setHighlights] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('alkitab_highlights') || '{}');
    } catch {
      return {};
    }
  });

  // Bookmarks: Array of passage keys
  const [bookmarks, setBookmarks] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('alkitab_bookmarks') || '[]');
    } catch {
      return [];
    }
  });

  // Modals & Panels
  const [showPicker, setShowPicker] = useState(false);
  const [pickerTestament, setPickerTestament] = useState('ALL');
  const [pickerCategory, setPickerCategory] = useState('Semua');
  const [pickerBook, setPickerBook] = useState(null);

  const [showAppearance, setShowAppearance] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [searching, setSearching] = useState(false);

  const [showSavedModal, setShowSavedModal] = useState(false);
  const [showCardMaker, setShowCardMaker] = useState(false);
  const [cardTheme, setCardTheme] = useState('amber'); // amber, midnight, parchment, emerald
  const canvasRef = useRef(null);

  // Offline Sync & Toast
  const [offlineStatus, setOfflineStatus] = useState(() => localStorage.getItem('alkitab_offline_synced') === 'true');
  const [syncingOffline, setSyncingOffline] = useState(false);
  const [toast, setToast] = useState(null);

  // Track scroll progress for reading bar
  useEffect(() => {
    const handleScroll = () => {
      const totalScroll = document.documentElement.scrollHeight - window.innerHeight;
      if (totalScroll <= 0) {
        setScrollProgress(0);
        return;
      }
      const currentScroll = window.scrollY;
      const progress = Math.min(100, Math.max(0, (currentScroll / totalScroll) * 100));
      setScrollProgress(progress);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Theme application
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('alkitab_theme', theme);
    const metaThemeColor = document.getElementById('theme-color-meta');
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', theme === 'dark' ? '#0A0C10' : theme === 'sepia' ? '#FAF6ED' : '#FFFFFF');
    }
  }, [theme]);

  // Typography application
  useEffect(() => {
    document.documentElement.style.setProperty('--reader-font-size', `${fontSize}px`);
    document.documentElement.style.setProperty('--reader-line-height', lineHeight);
    document.documentElement.style.setProperty(
      '--font-reader',
      fontFamily === 'serif' ? 'var(--font-serif)' : 'var(--font-sans)'
    );
    localStorage.setItem('alkitab_font_size', fontSize);
    localStorage.setItem('alkitab_font_family', fontFamily);
    localStorage.setItem('alkitab_line_height', lineHeight);
  }, [fontSize, fontFamily, lineHeight]);

  // Save location
  useEffect(() => {
    localStorage.setItem('alkitab_book_id', currentBookId);
    localStorage.setItem('alkitab_chapter', currentChapter);
  }, [currentBookId, currentChapter]);

  // Load books metadata
  useEffect(() => {
    fetch('/data/books.json')
      .then((res) => res.json())
      .then((data) => setBooks(data))
      .catch((err) => console.error(err));
  }, []);

  // Load current book data
  useEffect(() => {
    if (bookCache[currentBookId]) {
      setLoading(false);
      return;
    }
    setLoading(true);
    fetch(`/data/books/${currentBookId}.json`)
      .then((res) => res.json())
      .then((bookData) => {
        setBookCache((prev) => ({ ...prev, [currentBookId]: bookData }));
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, [currentBookId, bookCache]);

  const currentBookMeta = books.find((b) => b.id === currentBookId);
  const currentBookData = bookCache[currentBookId];
  const chapterVerses = currentBookData?.chapters?.[currentChapter.toString()] || [];

  const showToast = (message) => {
    setToast(message);
    setTimeout(() => setToast(null), 2500);
  };

  const handlePrevChapter = () => {
    setSelectedVerse(null);
    if (currentChapter > 1) {
      setCurrentChapter((prev) => prev - 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else if (currentBookId > 1) {
      const prevMeta = books.find((b) => b.id === currentBookId - 1);
      if (prevMeta) {
        setCurrentBookId(prevMeta.id);
        setCurrentChapter(prevMeta.chaptersCount);
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    }
  };

  const handleNextChapter = () => {
    setSelectedVerse(null);
    if (currentBookMeta && currentChapter < currentBookMeta.chaptersCount) {
      setCurrentChapter((prev) => prev + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else if (currentBookId < 66) {
      setCurrentBookId((prev) => prev + 1);
      setCurrentChapter(1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const jumpToPassage = (bookId, chapter, verse = null) => {
    setCurrentBookId(bookId);
    setCurrentChapter(chapter);
    setShowPicker(false);
    setShowSearch(false);
    setShowSavedModal(false);
    setSelectedVerse(null);
    window.scrollTo({ top: 0, behavior: 'smooth' });

    if (verse) {
      setTimeout(() => {
        const el = document.getElementById(`verse-${verse}`);
        if (el) {
          el.scrollIntoView({ behavior: 'smooth', block: 'center' });
          setSelectedVerse({ verse });
        }
      }, 300);
    }
  };

  // Verse Highlight Toggle
  const handleSetHighlight = (verseObj, color) => {
    const key = `${currentBookId}:${currentChapter}:${verseObj.verse}`;
    const updated = { ...highlights };
    if (updated[key] === color) {
      delete updated[key];
      showToast('Sorotan warna dihapus');
    } else {
      updated[key] = color;
      showToast('Ayat berhasil disorot');
    }
    setHighlights(updated);
    localStorage.setItem('alkitab_highlights', JSON.stringify(updated));
  };

  const handleToggleBookmark = (verseObj) => {
    const key = `${currentBookId}:${currentChapter}:${verseObj.verse}`;
    let updated;
    if (bookmarks.includes(key)) {
      updated = bookmarks.filter((k) => k !== key);
      showToast('Tanda ayat dihapus');
    } else {
      updated = [...bookmarks, key];
      showToast('Ayat ditambahkan ke daftar simpan');
    }
    setBookmarks(updated);
    localStorage.setItem('alkitab_bookmarks', JSON.stringify(updated));
  };

  const handleCopyVerse = (verseObj) => {
    if (!currentBookMeta) return;
    const citation = `"${verseObj.text}"\n— ${currentBookMeta.name} ${currentChapter}:${verseObj.verse} (AYT)`;
    navigator.clipboard.writeText(citation).then(() => {
      showToast('Ayat berhasil disalin');
    });
  };

  const handleShareVerse = (verseObj) => {
    if (!currentBookMeta) return;
    const textToShare = `"${verseObj.text}" — ${currentBookMeta.name} ${currentChapter}:${verseObj.verse} (AYT)`;
    if (navigator.share) {
      navigator.share({
        title: `${currentBookMeta.name} ${currentChapter}:${verseObj.verse}`,
        text: textToShare
      }).catch(() => {});
    } else {
      handleCopyVerse(verseObj);
    }
  };

  // DRAW VERSE CARD TO CANVAS (React Bits / Planes aesthetic)
  const drawVerseCard = () => {
    if (!canvasRef.current || !selectedVerse || !currentBookMeta) return;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const width = 1080;
    const height = 1080;
    canvas.width = width;
    canvas.height = height;

    // Background Gradient based on Card Theme
    let bgGrad = ctx.createLinearGradient(0, 0, width, height);
    let textColor = '#FFFFFF';
    let quoteColor = 'rgba(255, 255, 255, 0.2)';
    let refColor = '#FBBF24';

    if (cardTheme === 'amber') {
      bgGrad.addColorStop(0, '#78350F');
      bgGrad.addColorStop(0.5, '#451A03');
      bgGrad.addColorStop(1, '#1C1917');
      refColor = '#FDE68A';
    } else if (cardTheme === 'midnight') {
      bgGrad.addColorStop(0, '#0F172A');
      bgGrad.addColorStop(0.5, '#020617');
      bgGrad.addColorStop(1, '#000000');
      refColor = '#38BDF8';
    } else if (cardTheme === 'emerald') {
      bgGrad.addColorStop(0, '#064E3B');
      bgGrad.addColorStop(0.6, '#022C22');
      bgGrad.addColorStop(1, '#0A0C10');
      refColor = '#6EE7B7';
    } else if (cardTheme === 'parchment') {
      bgGrad.addColorStop(0, '#FAF6ED');
      bgGrad.addColorStop(1, '#EFE6D1');
      textColor = '#2C241D';
      quoteColor = 'rgba(180, 83, 9, 0.15)';
      refColor = '#B45309';
    }

    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, width, height);

    // Decorative Borders
    ctx.strokeStyle = cardTheme === 'parchment' ? 'rgba(180, 83, 9, 0.25)' : 'rgba(255, 255, 255, 0.15)';
    ctx.lineWidth = 4;
    ctx.strokeRect(50, 50, width - 100, height - 100);

    // Watermark / Giant Quote Mark
    ctx.font = 'bold 220px Georgia, serif';
    ctx.fillStyle = quoteColor;
    ctx.fillText('“', 100, 240);

    // Verse Text Word Wrap
    ctx.font = '500 48px "Literata", Georgia, serif';
    ctx.fillStyle = textColor;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const words = selectedVerse.text.split(' ');
    const lines = [];
    let currentLine = '';
    const maxWidth = 860;

    for (let n = 0; n < words.length; n++) {
      const testLine = currentLine + words[n] + ' ';
      const metrics = ctx.measureText(testLine);
      if (metrics.width > maxWidth && n > 0) {
        lines.push(currentLine.trim());
        currentLine = words[n] + ' ';
      } else {
        currentLine = testLine;
      }
    }
    lines.push(currentLine.trim());

    const lineHeightPx = 72;
    const startY = (height / 2) - ((lines.length * lineHeightPx) / 2) + 20;

    lines.forEach((line, index) => {
      ctx.fillText(line, width / 2, startY + (index * lineHeightPx));
    });

    // Reference & Badge
    ctx.font = 'bold 36px "Plus Jakarta Sans", sans-serif';
    ctx.fillStyle = refColor;
    ctx.fillText(`— ${currentBookMeta.name} ${currentChapter}:${selectedVerse.verse} (AYT) —`, width / 2, startY + (lines.length * lineHeightPx) + 80);

    // Footer Watermark
    ctx.font = '600 24px "Plus Jakarta Sans", sans-serif';
    ctx.fillStyle = cardTheme === 'parchment' ? 'rgba(44, 36, 29, 0.4)' : 'rgba(255, 255, 255, 0.4)';
    ctx.fillText('Alkitab Digital Indonesia • alkitab-pi.vercel.app', width / 2, height - 90);
  };

  useEffect(() => {
    if (showCardMaker) {
      setTimeout(drawVerseCard, 50);
    }
  }, [showCardMaker, cardTheme, selectedVerse]);

  // Download Card as PNG
  const handleDownloadCard = () => {
    if (!canvasRef.current) return;
    const link = document.createElement('a');
    link.download = `Alkitab-${currentBookMeta?.name}-${currentChapter}-${selectedVerse?.verse}.png`;
    link.href = canvasRef.current.toDataURL('image/png');
    link.click();
    showToast('Gambar berhasil diunduh!');
  };

  // Full Offline Precache
  const handleSyncAllOffline = async () => {
    setSyncingOffline(true);
    showToast('Sedang mengunduh 66 Kitab ke memori HP...');
    try {
      if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
        navigator.serviceWorker.controller.postMessage({ type: 'CACHE_ALL_BOOKS' });
      }
      for (let i = 1; i <= 66; i++) {
        await fetch(`/data/books/${i}.json`);
      }
      setOfflineStatus(true);
      localStorage.setItem('alkitab_offline_synced', 'true');
      setSyncingOffline(false);
      showToast('100% Seluruh Kitab berhasil disimpan offline!');
    } catch {
      setSyncingOffline(false);
      showToast('Gagal mengunduh.');
    }
  };

  // Search Verses
  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchQuery.trim()) return;
    setSearching(true);
    const query = searchQuery.trim().toLowerCase();
    const results = [];

    for (const bId of Object.keys(bookCache)) {
      const book = bookCache[bId];
      const meta = books.find((b) => b.id === parseInt(bId, 10));
      for (const ch of Object.keys(book.chapters)) {
        for (const v of book.chapters[ch]) {
          if (v.text.toLowerCase().includes(query)) {
            results.push({
              bookId: book.id,
              bookName: meta ? meta.name : book.name,
              chapter: parseInt(ch, 10),
              verse: v.verse,
              text: v.text
            });
            if (results.length >= 40) break;
          }
        }
        if (results.length >= 40) break;
      }
    }
    setSearchResults(results);
    setSearching(false);
  };

  const filteredBooks = books.filter((b) => {
    if (pickerTestament === 'PL' && b.testament !== 'PL') return false;
    if (pickerTestament === 'PB' && b.testament !== 'PB') return false;
    if (pickerCategory !== 'Semua' && b.category !== pickerCategory) return false;
    return true;
  });

  const availableCategories = ['Semua', ...new Set(
    books
      .filter((b) => pickerTestament === 'ALL' || b.testament === pickerTestament)
      .map((b) => b.category)
  )];

  return (
    <div className="app-layout">
      {/* Scroll Progress Bar (Top) */}
      <div className="reading-progress-bar" style={{ width: `${scrollProgress}%` }} />

      {/* Toast Notification */}
      {toast && (
        <div className="toast-box">
          <Icons.CloudCheck />
          <span>{toast}</span>
        </div>
      )}

      {/* TOP HEADER */}
      <header className="app-header">
        <div className="header-container">
          <div className="header-brand" onClick={() => jumpToPassage(43, 1)}>
            <div className="brand-icon">
              <img src="/icon.svg" alt="Alkitab" width="28" height="28" />
            </div>
            <div className="brand-title">
              Alkitab
              <span className="shiny-badge">AYT</span>
            </div>
          </div>

          <div className="header-center">
            <button 
              className="passage-picker-btn"
              onClick={() => {
                setPickerBook(currentBookMeta);
                setShowPicker(true);
              }}
              title="Pilih Kitab & Pasal"
            >
              <span>{currentBookMeta ? `${currentBookMeta.name} ${currentChapter}` : 'Memuat...'}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <polyline points="6 9 12 15 18 9"/>
              </svg>
            </button>
          </div>

          <div className="header-actions">
            <button 
              className={`icon-btn ${showSearch ? 'active' : ''}`}
              onClick={() => setShowSearch(true)} 
              title="Cari Ayat"
            >
              <Icons.Search />
            </button>
            <button 
              className={`icon-btn ${showSavedModal ? 'active' : ''}`}
              onClick={() => setShowSavedModal(true)} 
              title="Ayat Tersimpan & Sorotan"
            >
              <Icons.BookmarkList />
            </button>
            <button 
              className={`icon-btn ${showAppearance ? 'active' : ''}`}
              onClick={() => setShowAppearance(true)} 
              title="Tampilan & Huruf"
            >
              <Icons.TextSettings />
            </button>
          </div>
        </div>
      </header>

      {/* MAIN READER */}
      <main className="reader-main">
        <div className="reader-content">
          {loading ? (
            <div className="loading-spinner">
              <div className="spinner"></div>
              <p>Membuka Kitab Suci...</p>
            </div>
          ) : (
            <>
              <div className="chapter-header">
                <h1 className="chapter-book-title">{currentBookMeta?.name}</h1>
                <div className="chapter-subtitle">Pasal {currentChapter} • {currentBookMeta?.category}</div>
              </div>

              <div className="verses-list">
                {chapterVerses.map((verseObj) => {
                  const key = `${currentBookId}:${currentChapter}:${verseObj.verse}`;
                  const isSelected = selectedVerse?.verse === verseObj.verse;
                  const isBookmarked = bookmarks.includes(key);
                  const hlColor = highlights[key]; // yellow, green, blue, pink

                  return (
                    <React.Fragment key={verseObj.verse}>
                      {verseObj.title && (
                        <h2 className="pericope-title">{verseObj.title}</h2>
                      )}
                      <span 
                        id={`verse-${verseObj.verse}`}
                        className={`verse-item ${isSelected ? 'selected' : ''} ${isBookmarked ? 'bookmarked' : ''} ${hlColor ? `hl-${hlColor}` : ''}`}
                        onClick={() => setSelectedVerse(isSelected ? null : verseObj)}
                      >
                        <sup className="verse-num">{verseObj.verse}</sup>
                        <span className="verse-text">{verseObj.text} </span>
                      </span>
                    </React.Fragment>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </main>

      {/* POP-UP ACTION BAR (Animos Spring Animation) */}
      {selectedVerse && (
        <div className="verse-actions-bar">
          {/* Pastel Highlight Dots */}
          <div className="hl-palette">
            <button 
              className="hl-dot" 
              style={{ backgroundColor: '#FEF08A' }} 
              onClick={() => handleSetHighlight(selectedVerse, 'yellow')}
              title="Sorot Emas"
            />
            <button 
              className="hl-dot" 
              style={{ backgroundColor: '#BBF7D0' }} 
              onClick={() => handleSetHighlight(selectedVerse, 'green')}
              title="Sorot Hijau"
            />
            <button 
              className="hl-dot" 
              style={{ backgroundColor: '#BAE6FD' }} 
              onClick={() => handleSetHighlight(selectedVerse, 'blue')}
              title="Sorot Biru"
            />
            <button 
              className="hl-dot" 
              style={{ backgroundColor: '#FBCFE8' }} 
              onClick={() => handleSetHighlight(selectedVerse, 'pink')}
              title="Sorot Merah Muda"
            />
          </div>

          <div style={{ width: 1, height: 20, backgroundColor: 'var(--border-subtle)' }} />

          <button className="verse-action-btn" onClick={() => handleCopyVerse(selectedVerse)}>
            <Icons.Copy />
            <span>Salin</span>
          </button>
          <button className="verse-action-btn" onClick={() => handleToggleBookmark(selectedVerse)}>
            <Icons.Bookmark filled={bookmarks.includes(`${currentBookId}:${currentChapter}:${selectedVerse.verse}`)} />
            <span>Tandai</span>
          </button>
          <button 
            className="verse-action-btn" 
            style={{ backgroundColor: 'var(--accent)', color: 'var(--text-inverse)' }}
            onClick={() => setShowCardMaker(true)}
          >
            <Icons.ImageCard />
            <span>Gambar</span>
          </button>
          <button className="icon-btn" onClick={() => setSelectedVerse(null)}>
            <Icons.Close />
          </button>
        </div>
      )}

      {/* FLOATING DOCK (Arc UI / React Bits Dock Style) */}
      <nav className="floating-dock">
        <button 
          className="dock-btn" 
          onClick={handlePrevChapter} 
          disabled={currentBookId === 1 && currentChapter === 1}
          title="Pasal Sebelumnya"
        >
          <Icons.ChevronLeft />
          <span>Sebelumnya</span>
        </button>

        <div className="dock-divider" />

        <div 
          className="dock-indicator" 
          style={{ cursor: 'pointer' }}
          onClick={() => {
            setPickerBook(currentBookMeta);
            setShowPicker(true);
          }}
        >
          {currentBookMeta?.abbr} {currentChapter}
        </div>

        <div className="dock-divider" />

        <button 
          className="dock-btn" 
          onClick={handleNextChapter} 
          disabled={currentBookId === 66 && currentBookMeta && currentChapter === currentBookMeta.chaptersCount}
          title="Pasal Berikutnya"
        >
          <span>Berikutnya</span>
          <Icons.ChevronRight />
        </button>
      </nav>

      {/* MODAL: VERSE CARD GENERATOR */}
      {showCardMaker && selectedVerse && (
        <div className="modal-backdrop" onClick={() => setShowCardMaker(false)}>
          <div className="modal-card card-maker-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title">Kartu Kutipan Ayat</div>
              <button className="modal-close-btn" onClick={() => setShowCardMaker(false)}>
                <Icons.Close />
              </button>
            </div>

            <div className="modal-body">
              {/* Canvas Preview */}
              <div className="quote-canvas-preview">
                <canvas ref={canvasRef} />
              </div>

              {/* Theme Selector */}
              <div style={{ fontSize: '0.82rem', fontWeight: 700, color: 'var(--text-secondary)', marginBottom: '0.5rem', textTransform: 'uppercase' }}>
                Pilih Gaya Kartu
              </div>
              <div className="card-themes-row">
                <button 
                  className={`card-theme-btn ${cardTheme === 'amber' ? 'active' : ''}`}
                  style={{ background: 'linear-gradient(135deg, #78350F, #1C1917)' }}
                  onClick={() => setCardTheme('amber')}
                >
                  Amber Gold
                </button>
                <button 
                  className={`card-theme-btn ${cardTheme === 'midnight' ? 'active' : ''}`}
                  style={{ background: 'linear-gradient(135deg, #0F172A, #000000)' }}
                  onClick={() => setCardTheme('midnight')}
                >
                  Midnight
                </button>
                <button 
                  className={`card-theme-btn ${cardTheme === 'emerald' ? 'active' : ''}`}
                  style={{ background: 'linear-gradient(135deg, #064E3B, #0A0C10)' }}
                  onClick={() => setCardTheme('emerald')}
                >
                  Emerald
                </button>
                <button 
                  className={`card-theme-btn ${cardTheme === 'parchment' ? 'active' : ''}`}
                  style={{ background: '#FAF6ED', color: '#2C241D', border: '1px solid #D6C8A8' }}
                  onClick={() => setCardTheme('parchment')}
                >
                  Parchment
                </button>
              </div>

              {/* Download / Share Actions */}
              <div className="card-maker-actions">
                <button className="primary-action-btn" onClick={handleDownloadCard}>
                  <Icons.Download />
                  <span>Unduh Gambar (PNG)</span>
                </button>
                <button className="verse-action-btn" onClick={() => handleShareVerse(selectedVerse)}>
                  <Icons.Share />
                  <span>Bagikan</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: SAVED VERSES & HIGHLIGHTS */}
      {showSavedModal && (
        <div className="modal-backdrop" onClick={() => setShowSavedModal(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title">Ayat Tersimpan & Sorotan</div>
              <button className="modal-close-btn" onClick={() => setShowSavedModal(false)}>
                <Icons.Close />
              </button>
            </div>

            <div className="modal-body">
              {bookmarks.length === 0 && Object.keys(highlights).length === 0 ? (
                <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--text-muted)' }}>
                  Belum ada ayat yang ditandai atau disorot. Klik ayat saat membaca untuk menandai!
                </div>
              ) : (
                <div>
                  {/* Bookmarked verses */}
                  {bookmarks.map((key) => {
                    const [bId, ch, v] = key.split(':');
                    const bMeta = books.find((b) => b.id === parseInt(bId, 10));
                    return (
                      <div 
                        key={key} 
                        className="saved-item-card"
                        onClick={() => jumpToPassage(parseInt(bId, 10), parseInt(ch, 10), parseInt(v, 10))}
                      >
                        <div className="saved-item-ref">
                          <span>{bMeta?.name} {ch}:{v}</span>
                          <span style={{ fontSize: '0.72rem', color: 'var(--text-muted)' }}>Ditandai</span>
                        </div>
                      </div>
                    );
                  })}

                  {/* Highlighted verses */}
                  {Object.entries(highlights).map(([key, color]) => {
                    const [bId, ch, v] = key.split(':');
                    const bMeta = books.find((b) => b.id === parseInt(bId, 10));
                    return (
                      <div 
                        key={key} 
                        className="saved-item-card"
                        style={{ borderLeft: `4px solid var(--hl-${color})` }}
                        onClick={() => jumpToPassage(parseInt(bId, 10), parseInt(ch, 10), parseInt(v, 10))}
                      >
                        <div className="saved-item-ref">
                          <span>{bMeta?.name} {ch}:{v}</span>
                          <span style={{ fontSize: '0.72rem', textTransform: 'capitalize', color: 'var(--accent)' }}>Sorot {color}</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* MODAL: BOOK & CHAPTER PICKER */}
      {showPicker && (
        <div className="modal-backdrop" onClick={() => setShowPicker(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title">
                {pickerBook ? (
                  <button 
                    style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
                    onClick={() => setPickerBook(null)}
                  >
                    <Icons.ChevronLeft />
                    <span>{pickerBook.name} (Pilih Pasal)</span>
                  </button>
                ) : (
                  'Pilih Kitab & Pasal'
                )}
              </div>
              <button className="modal-close-btn" onClick={() => setShowPicker(false)}>
                <Icons.Close />
              </button>
            </div>

            <div className="modal-body">
              {pickerBook ? (
                <div>
                  <div style={{ marginBottom: '1rem', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                    Tersedia {pickerBook.chaptersCount} pasal di Kitab {pickerBook.name}:
                  </div>
                  <div className="chapters-grid">
                    {Array.from({ length: pickerBook.chaptersCount }, (_, i) => i + 1).map((chNum) => (
                      <button
                        key={chNum}
                        className={`chapter-square-btn ${currentBookId === pickerBook.id && currentChapter === chNum ? 'active' : ''}`}
                        onClick={() => jumpToPassage(pickerBook.id, chNum)}
                      >
                        {chNum}
                      </button>
                    ))}
                  </div>
                </div>
              ) : (
                <div>
                  <div className="testament-tabs">
                    <button 
                      className={`testament-tab ${pickerTestament === 'ALL' ? 'active' : ''}`}
                      onClick={() => { setPickerTestament('ALL'); setPickerCategory('Semua'); }}
                    >
                      Semua (66)
                    </button>
                    <button 
                      className={`testament-tab ${pickerTestament === 'PL' ? 'active' : ''}`}
                      onClick={() => { setPickerTestament('PL'); setPickerCategory('Semua'); }}
                    >
                      Perjanjian Lama (39)
                    </button>
                    <button 
                      className={`testament-tab ${pickerTestament === 'PB' ? 'active' : ''}`}
                      onClick={() => { setPickerTestament('PB'); setPickerCategory('Semua'); }}
                    >
                      Perjanjian Baru (27)
                    </button>
                  </div>

                  <div className="category-chips">
                    {availableCategories.map((cat) => (
                      <button
                        key={cat}
                        className={`category-chip ${pickerCategory === cat ? 'active' : ''}`}
                        onClick={() => setPickerCategory(cat)}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>

                  <div className="books-grid">
                    {filteredBooks.map((book) => (
                      <button
                        key={book.id}
                        className={`book-card-btn ${currentBookId === book.id ? 'active' : ''}`}
                        onClick={() => setPickerBook(book)}
                      >
                        <div className="book-name">{book.name}</div>
                        <div className="book-meta">{book.chaptersCount} Pasal • {book.abbr}</div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* MODAL: APPEARANCE SETTINGS */}
      {showAppearance && (
        <div className="modal-backdrop" onClick={() => setShowAppearance(false)}>
          <div className="modal-card settings-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title">Pengaturan Tampilan</div>
              <button className="modal-close-btn" onClick={() => setShowAppearance(false)}>
                <Icons.Close />
              </button>
            </div>

            <div className="modal-body">
              {/* Theme Switcher */}
              <div className="setting-group">
                <label className="setting-label">Tema Warna Baca</label>
                <div className="theme-options-grid">
                  <button 
                    className={`theme-option-btn ${theme === 'sepia' ? 'active' : ''}`}
                    onClick={() => setTheme('sepia')}
                    style={{ backgroundColor: '#FAF6ED', color: '#2C241D' }}
                  >
                    <div className="theme-preview-box" style={{ backgroundColor: '#FAF6ED' }} />
                    <span>Sepia</span>
                  </button>
                  <button 
                    className={`theme-option-btn ${theme === 'light' ? 'active' : ''}`}
                    onClick={() => setTheme('light')}
                    style={{ backgroundColor: '#FFFFFF', color: '#0F172A' }}
                  >
                    <div className="theme-preview-box" style={{ backgroundColor: '#FFFFFF' }} />
                    <span>Terang</span>
                  </button>
                  <button 
                    className={`theme-option-btn ${theme === 'dark' ? 'active' : ''}`}
                    onClick={() => setTheme('dark')}
                    style={{ backgroundColor: '#0A0C10', color: '#F1F5F9' }}
                  >
                    <div className="theme-preview-box" style={{ backgroundColor: '#0A0C10' }} />
                    <span>Gelap</span>
                  </button>
                </div>
              </div>

              {/* Font Size */}
              <div className="setting-group">
                <label className="setting-label">Ukuran Huruf ({fontSize}px)</label>
                <div className="font-size-control">
                  <button 
                    className="font-size-btn"
                    onClick={() => setFontSize((s) => Math.max(15, s - 1))}
                  >
                    A-
                  </button>
                  <input 
                    type="range" 
                    min="15" 
                    max="26" 
                    value={fontSize} 
                    onChange={(e) => setFontSize(parseInt(e.target.value, 10))}
                    className="font-size-slider"
                  />
                  <button 
                    className="font-size-btn"
                    onClick={() => setFontSize((s) => Math.min(26, s + 1))}
                  >
                    A+
                  </button>
                </div>
              </div>

              {/* Font Family */}
              <div className="setting-group">
                <label className="setting-label">Gaya Huruf</label>
                <div className="font-family-toggle">
                  <button 
                    className={`font-family-btn ${fontFamily === 'serif' ? 'active' : ''}`}
                    style={{ fontFamily: 'var(--font-serif)' }}
                    onClick={() => setFontFamily('serif')}
                  >
                    Serif (Literata)
                  </button>
                  <button 
                    className={`font-family-btn ${fontFamily === 'sans' ? 'active' : ''}`}
                    style={{ fontFamily: 'var(--font-sans)' }}
                    onClick={() => setFontFamily('sans')}
                  >
                    Sans-serif (Modern)
                  </button>
                </div>
              </div>

              {/* Spacing */}
              <div className="setting-group">
                <label className="setting-label">Jarak Baris (Spasi)</label>
                <div className="font-family-toggle">
                  <button 
                    className={`font-family-btn ${lineHeight === '1.6' ? 'active' : ''}`}
                    onClick={() => setLineHeight('1.6')}
                  >
                    Rapat
                  </button>
                  <button 
                    className={`font-family-btn ${lineHeight === '1.85' ? 'active' : ''}`}
                    onClick={() => setLineHeight('1.85')}
                  >
                    Nyaman
                  </button>
                  <button 
                    className={`font-family-btn ${lineHeight === '2.1' ? 'active' : ''}`}
                    onClick={() => setLineHeight('2.1')}
                  >
                    Longgar
                  </button>
                </div>
              </div>

              {/* Offline Full Download Box */}
              <div className="offline-sync-box">
                <div className="sync-info">
                  <div className="sync-title">
                    <Icons.CloudCheck />
                    <span>Mode Offline Penuh</span>
                  </div>
                  <div className="sync-desc">
                    {offlineStatus ? 'Semua 66 Kitab sudah tersimpan di HP' : 'Unduh semua 66 Kitab (~5 MB) agar siap tanpa internet'}
                  </div>
                </div>
                <button 
                  className="sync-btn"
                  onClick={handleSyncAllOffline}
                  disabled={syncingOffline || offlineStatus}
                >
                  {syncingOffline ? 'Mengunduh...' : offlineStatus ? 'Tersimpan' : 'Unduh Semua'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: SEARCH */}
      {showSearch && (
        <div className="modal-backdrop" onClick={() => setShowSearch(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title">Cari Ayat</div>
              <button className="modal-close-btn" onClick={() => setShowSearch(false)}>
                <Icons.Close />
              </button>
            </div>

            <div className="modal-body">
              <form onSubmit={handleSearch} className="search-input-wrap">
                <span className="search-icon-inside"><Icons.Search /></span>
                <input 
                  type="text" 
                  className="search-input"
                  placeholder="Ketik kata (misal: kasih, terang, damai)..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  autoFocus
                />
              </form>

              {searching && (
                <div className="loading-spinner">
                  <div className="spinner"></div>
                  <p>Mencari ayat...</p>
                </div>
              )}

              {searchResults.length > 0 && (
                <div className="search-results-list">
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '0.25rem' }}>
                    Ditemukan {searchResults.length} hasil:
                  </div>
                  {searchResults.map((res, idx) => (
                    <div 
                      key={idx} 
                      className="search-result-item"
                      onClick={() => jumpToPassage(res.bookId, res.chapter, res.verse)}
                    >
                      <div className="search-result-ref">
                        {res.bookName} {res.chapter}:{res.verse}
                      </div>
                      <div className="search-result-text">
                        {res.text}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {!searching && searchResults.length === 0 && searchQuery && (
                <div style={{ textAlign: 'center', padding: '2rem 1rem', color: 'var(--text-muted)' }}>
                  Tidak ada ayat yang cocok di kitab yang sudah dimuat. Coba kata kunci lain.
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
