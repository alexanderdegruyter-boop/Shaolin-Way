import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../services/app_state.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';

/// Reading themes for the reader (independent of the app theme).
class _ReaderPalette {
  final Color bg;
  final Color text;
  const _ReaderPalette(this.bg, this.text);

  static _ReaderPalette of(String name) {
    switch (name) {
      case 'light':
        return const _ReaderPalette(Color(0xFFFFFFFF), Color(0xFF2B2A28));
      case 'dark':
        return const _ReaderPalette(Color(0xFF161514), Color(0xFFD8D4CA));
      case 'sepia':
      default:
        return const _ReaderPalette(Color(0xFFF4ECD8), Color(0xFF5B4636));
    }
  }
}

/// The ebook-style reader: formatted markdown, adjustable font size,
/// light/sepia/dark themes, bookmark, continue-reading, chapter progress,
/// and prev/next navigation.
class ReaderScreen extends StatefulWidget {
  final Book book;
  final int chapterIndex;
  const ReaderScreen({
    super.key,
    required this.book,
    required this.chapterIndex,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scroll = ScrollController();
  late int _chapter = widget.chapterIndex;
  late Future<String> _markdown;
  double _progress = 0;
  bool _restoredOnce = false;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _markdown = _load();
    _scroll.addListener(_onScroll);
  }

  Future<String> _load() {
    return context
        .read<ContentService>()
        .loadChapterMarkdown(widget.book.chapters[_chapter].file);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _savePosition();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    setState(() {
      _progress = max <= 0 ? 0 : (_scroll.offset / max).clamp(0.0, 1.0);
    });
    // Debounced position save while reading.
    _saveDebounce?.cancel();
    _saveDebounce =
        Timer(const Duration(milliseconds: 400), _savePosition);
  }

  void _savePosition() {
    if (!mounted || !_scroll.hasClients) return;
    context
        .read<AppState>()
        .saveReadingPosition(widget.book.id, _chapter, _scroll.offset);
  }

  void _changeChapter(int delta) {
    final next = _chapter + delta;
    if (next < 0 || next >= widget.book.chapters.length) return;
    _savePosition();
    setState(() {
      _chapter = next;
      _restoredOnce = false;
      _progress = 0;
      _markdown = _load();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  /// Restore the saved scroll offset once the content has been laid out.
  void _maybeRestore() {
    if (_restoredOnce) return;
    _restoredOnce = true;
    final state = context.read<AppState>();
    // Only restore if we're opening the exact chapter that was saved.
    if (state.readingChapter(widget.book.id) != _chapter) return;
    final offset = state.readingOffset(widget.book.id);
    if (offset <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      _scroll.jumpTo(offset.clamp(0.0, max));
    });
  }

  void _changeFont(double delta) {
    context.read<AppState>().readerFontSize =
        context.read<AppState>().readerFontSize + delta;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final palette = _ReaderPalette.of(state.readerTheme);
    final fontSize = state.readerFontSize;
    final isBookmarked = state.isBookmarked(widget.book.id, _chapter);
    final chapter = widget.book.chapters[_chapter];

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        foregroundColor: palette.text,
        title: Text(chapter.title,
            style: TextStyle(color: palette.text, fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'Bookmark this chapter',
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppTheme.accent : palette.text,
            ),
            onPressed: () =>
                state.toggleBookmark(widget.book.id, _chapter),
          ),
          IconButton(
            tooltip: 'Reading options',
            icon: Icon(Icons.text_fields, color: palette.text),
            onPressed: () => _openOptions(context, state),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 3,
            backgroundColor: palette.text.withOpacity(0.08),
            color: AppTheme.accent,
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: _markdown,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                _maybeRestore();
                return Markdown(
                  controller: _scroll,
                  data: snapshot.data!,
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
                  styleSheet: _styleSheet(palette, fontSize),
                );
              },
            ),
          ),
          _navBar(palette),
        ],
      ),
    );
  }

  Widget _navBar(_ReaderPalette palette) {
    final atFirst = _chapter == 0;
    final atLast = _chapter == widget.book.chapters.length - 1;
    return Container(
      color: palette.bg,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: atFirst ? null : () => _changeChapter(-1),
            icon: const Icon(Icons.chevron_left),
            label: const Text('Prev'),
            style: TextButton.styleFrom(foregroundColor: palette.text),
          ),
          Expanded(
            child: Text(
              'Chapter ${_chapter + 1} of ${widget.book.chapters.length}',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.text.withOpacity(0.7)),
            ),
          ),
          TextButton.icon(
            onPressed: atLast ? null : () => _changeChapter(1),
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            style: TextButton.styleFrom(foregroundColor: palette.text),
          ),
        ],
      ),
    );
  }

  void _openOptions(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading options',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  // Font size.
                  Row(
                    children: [
                      const Text('Font size'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          _changeFont(-1);
                          setSheet(() {});
                        },
                      ),
                      Text('${state.readerFontSize.round()}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _changeFont(1);
                          setSheet(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Theme'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _themeChoice('light', 'Light', state, setSheet),
                      const SizedBox(width: 10),
                      _themeChoice('sepia', 'Sepia', state, setSheet),
                      const SizedBox(width: 10),
                      _themeChoice('dark', 'Dark', state, setSheet),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _themeChoice(
      String key, String label, AppState state, void Function(void Function()) setSheet) {
    final palette = _ReaderPalette.of(key);
    final selected = state.readerTheme == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          state.readerTheme = key;
          setSheet(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.accent : Colors.grey.withOpacity(0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: palette.text)),
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _styleSheet(_ReaderPalette p, double fontSize) {
    return MarkdownStyleSheet(
      p: TextStyle(
          color: p.text, fontSize: fontSize, height: 1.6),
      h1: TextStyle(
          color: p.text,
          fontSize: fontSize + 12,
          fontWeight: FontWeight.w600,
          height: 1.3),
      h2: TextStyle(
          color: p.text,
          fontSize: fontSize + 6,
          fontWeight: FontWeight.w600,
          height: 1.4),
      h3: TextStyle(
          color: p.text, fontSize: fontSize + 2, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: p.text, fontSize: fontSize, height: 1.6),
      blockquote: TextStyle(
          color: p.text.withOpacity(0.85),
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          height: 1.5),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppTheme.accent, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.all(12),
      strong: TextStyle(color: p.text, fontWeight: FontWeight.w700),
      em: TextStyle(color: p.text, fontStyle: FontStyle.italic),
      h1Padding: const EdgeInsets.only(bottom: 8),
      pPadding: const EdgeInsets.only(bottom: 12),
    );
  }
}
