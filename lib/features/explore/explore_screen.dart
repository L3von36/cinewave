import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/movie.dart';
import '../../data/movie_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/movie_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final movies = ref.watch(moviesProvider).value ?? const <Movie>[];
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final genre = ref.watch(selectedGenreProvider);

    final genres = <String>{
      for (final m in movies) ...m.genres,
    }.toList()..sort();

    final results = movies.where((m) {
      final genreOk = genre == null || m.hasGenre(genre);
      if (query.isEmpty) return genreOk;
      final titleHit = m.title.toLowerCase().contains(query);
      final genreHit = m.genres
          .any((g) => g.toLowerCase().contains(query));
      final castHit =
          m.cast.any((c) => c.toLowerCase().contains(query));
      return genreOk && (titleHit || genreHit || castHit);
    }).toList(growable: false);

    final crossAxis = MediaQuery.sizeOf(context).width < 600
        ? 2
        : MediaQuery.sizeOf(context).width < 900
            ? 3
            : MediaQuery.sizeOf(context).width < 1200
                ? 4
                : 6;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _controller,
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search titles, genres, cast…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      ),
                filled: true,
                fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final g in ['All', ...genres])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: (genre ?? 'All') == g,
                      showCheckmark: false,
                      onSelected: (_) => ref
                          .read(selectedGenreProvider.notifier)
                          .state = g == 'All' ? null : g,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.movie_filter_outlined,
                    title: 'Nothing found',
                    message:
                        'No titles match your search. Try different keywords or clear the filters.',
                    action: FilledButton.tonal(
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(selectedGenreProvider.notifier).state = null;
                      },
                      child: const Text('Clear filters'),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) =>
                        MovieCard(movie: results[i], width: double.infinity),
                  ),
          ),
        ],
      ),
    );
  }
}
