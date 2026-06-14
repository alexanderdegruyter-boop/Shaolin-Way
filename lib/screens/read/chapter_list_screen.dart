import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'reader_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final Book book;
  const ChapterListScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final text = Theme.of(context).textTheme;
    final bookmark = state.bookmarkOf(book.id);

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(book.author, style: text.bodyMedium),
          const SizedBox(height: 8),
          Text(book.description, style: text.bodyLarge),
          const SizedBox(height: 8),
          const Divider(height: 24),
          for (var i = 0; i < book.chapters.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppTheme.accent.withOpacity(0.16),
                child: Text('${i + 1}',
                    style: const TextStyle(color: AppTheme.accent)),
              ),
              title: Text(book.chapters[i].title, style: text.titleMedium),
              trailing: bookmark == i
                  ? const Icon(Icons.bookmark, color: AppTheme.accent)
                  : const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReaderScreen(book: book, chapterIndex: i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
