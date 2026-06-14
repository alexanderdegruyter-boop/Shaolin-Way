import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../services/app_state.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import 'chapter_list_screen.dart';
import 'reader_screen.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.read<ContentService>();
    final state = context.watch<AppState>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Read')),
      body: FutureBuilder<List<Book>>(
        future: content.loadBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;

          // "Continue reading" — last opened book, if any.
          Book? continueBook;
          final lastId = state.continueReadingBookId;
          if (lastId != null) {
            for (final b in books) {
              if (b.id == lastId) continueBook = b;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (continueBook != null) ...[
                _ContinueCard(book: continueBook, state: state),
                const SizedBox(height: 20),
              ],
              Text('Library', style: text.titleMedium),
              const SizedBox(height: 12),
              for (final b in books) _BookCard(book: b),
            ],
          );
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Book book;
  final AppState state;
  const _ContinueCard({required this.book, required this.state});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chapterIndex = state.readingChapter(book.id);
    final chapter = book.chapters[chapterIndex.clamp(0, book.chapters.length - 1)];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderScreen(book: book, chapterIndex: chapterIndex),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withOpacity(0.20),
              AppTheme.accent.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_stories, color: AppTheme.accent, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continue reading', style: text.bodyMedium),
                  const SizedBox(height: 2),
                  Text(book.title, style: text.titleMedium),
                  Text(chapter.title, style: text.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChapterListScreen(book: book),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book, color: AppTheme.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: text.titleMedium),
                    Text(book.author, style: text.bodyMedium),
                    const SizedBox(height: 6),
                    Text(book.description,
                        style: text.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('${book.chapters.length} chapters',
                        style: text.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
