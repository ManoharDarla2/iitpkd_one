import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';
import 'package:iitpkd_one/features/search/view_models/providers.dart';
import 'package:iitpkd_one/features/search/view_models/recent_searches_view_model.dart';
import 'package:iitpkd_one/features/search/view_models/search_view_model.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_bar_field.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_category_chips.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_empty_state.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_result_detail_sheet.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_result_tile.dart';
import 'package:iitpkd_one/features/search/views/widgets/search_suggestion_chip.dart';

/// The main Search screen — the second tab of the bottom navigation.
///
/// Features:
/// - Search bar with debounce (500ms) using flutter_hooks
/// - Category filter chips (All, Facilities, People, Labs, Schedules)
/// - Recent searches persisted to Hive
/// - Autocomplete suggestions as the user types
/// - Results list with category-aware tiles
/// - People results navigate to FacultyDetailScreen
/// - Other results open a detail bottom sheet
class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchAsync = ref.watch(searchViewModelProvider);
    final searchVM = ref.read(searchViewModelProvider.notifier);
    final recentSearches = ref.watch(recentSearchesViewModelProvider);
    final recentSearchesVM = ref.read(recentSearchesViewModelProvider.notifier);

    // -- Hooks --
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    final isTyping = useState(false);

    // Cleanup debounce timer on dispose.
    useEffect(() {
      return () => debounceTimer.value?.cancel();
    }, const []);

    // Listen for errors.
    ref.listen(searchViewModelProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorSnackbar(context, 'Search failed. Please try again.');
      }
    });

    // -- Callbacks --
    void onTextChanged(String value) {
      isTyping.value = value.isNotEmpty;
      debounceTimer.value?.cancel();

      if (value.trim().isEmpty) {
        searchVM.clearSearch();
        return;
      }

      debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
        searchVM.updateQuery(value);
      });
    }

    void onClear() {
      textController.clear();
      isTyping.value = false;
      searchVM.clearSearch();
      focusNode.requestFocus();
    }

    void onSuggestionTap(String suggestion) {
      textController.text = suggestion;
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.length),
      );
      isTyping.value = true;
      debounceTimer.value?.cancel();
      searchVM.updateQuery(suggestion);
    }

    void onSearchSubmitted(String value) {
      if (value.trim().isNotEmpty) {
        debounceTimer.value?.cancel();
        searchVM.updateQuery(value);
        recentSearchesVM.addSearch(value);
      }
    }

    void onResultTap(item) {
      // Save query to recent searches when user interacts with a result.
      final query = searchVM.currentQuery;
      if (query.isNotEmpty) {
        recentSearchesVM.addSearch(query);
      }

      if (item.category == SearchCategory.faculty ||
          item.category == SearchCategory.people) {
        final slug = item.metadata['slug'];
        if (slug != null) {
          context.push('/faculty/$slug');
        }
      } else {
        SearchResultDetailSheet.show(context, item);
      }
    }

    // -- Build --
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IITPKD One',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open filter/settings panel
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filters',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // TODO: Navigate to profile/login screen
              },
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Search bar
          SearchBarField(
            controller: textController,
            focusNode: focusNode,
            onChanged: onTextChanged,
            onClear: onClear,
            onSubmitted: onSearchSubmitted,
          ),
          const SizedBox(height: 12),

          // Category filter chips
          SearchCategoryChips(
            selected: searchVM.currentCategory,
            onSelected: (category) => searchVM.updateCategory(category),
          ),
          const SizedBox(height: 8),

          // Content area
          Expanded(
            child: _buildContent(
              context: context,
              ref: ref,
              theme: theme,
              searchAsync: searchAsync,
              searchVM: searchVM,
              isTyping: isTyping.value,
              textController: textController,
              recentSearches: recentSearches,
              recentSearchesVM: recentSearchesVM,
              onSuggestionTap: onSuggestionTap,
              onResultTap: onResultTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required AsyncValue searchAsync,
    required SearchViewModel searchVM,
    required bool isTyping,
    required TextEditingController textController,
    required List<String> recentSearches,
    required RecentSearchesViewModel recentSearchesVM,
    required ValueChanged<String> onSuggestionTap,
    required Function onResultTap,
  }) {
    // Show suggestions/recent searches when there's no active search
    return searchAsync.when(
      data: (result) {
        // No search performed yet — show suggestions + recent searches
        if (result == null) {
          return _SuggestionsAndRecentsView(
            query: isTyping ? textController.text : '',
            recentSearches: recentSearches,
            recentSearchesVM: recentSearchesVM,
            onSuggestionTap: onSuggestionTap,
          );
        }

        // Search returned empty results
        if (result.results.isEmpty) {
          return SearchEmptyState(query: result.query);
        }

        // Search results
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          itemCount: result.results.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Results count header
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  '${result.totalCount} result${result.totalCount == 1 ? '' : 's'} found',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              );
            }
            final item = result.results[index - 1];
            return SearchResultTile(item: item, onTap: () => onResultTap(item));
          },
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Search failed',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => searchVM.updateQuery(searchVM.currentQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Shows suggestions (autocomplete) and recent searches when no query
/// has been submitted yet.
class _SuggestionsAndRecentsView extends ConsumerWidget {
  const _SuggestionsAndRecentsView({
    required this.query,
    required this.recentSearches,
    required this.recentSearchesVM,
    required this.onSuggestionTap,
  });

  final String query;
  final List<String> recentSearches;
  final RecentSearchesViewModel recentSearchesVM;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // If user is typing, show autocomplete suggestions
    if (query.isNotEmpty) {
      final suggestionsAsync = ref.watch(searchSuggestionsProvider(query));
      return suggestionsAsync.when(
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const SearchEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 4),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return SearchSuggestionChip(
                label: suggestions[index],
                onTap: () => onSuggestionTap(suggestions[index]),
              );
            },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      );
    }

    // No query — show recent searches + popular suggestions
    final hasRecent = recentSearches.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (hasRecent) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Searches',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => recentSearchesVM.clearAll(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'Clear all',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...recentSearches.map(
              (query) => SearchSuggestionChip(
                label: query,
                isRecent: true,
                onTap: () => onSuggestionTap(query),
                onDelete: () => recentSearchesVM.removeSearch(query),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
          ],

          // Popular suggestions header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Popular Searches',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Popular suggestion chips — fetched from the suggestions endpoint
          // with empty query (returns popular/trending terms).
          _PopularSuggestionsList(onSuggestionTap: onSuggestionTap),
        ],
      ),
    );
  }
}

/// Fetches and displays popular suggestions from the API.
class _PopularSuggestionsList extends ConsumerWidget {
  const _PopularSuggestionsList({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(searchSuggestionsProvider(''));

    return suggestionsAsync.when(
      data: (suggestions) => Column(
        children: suggestions
            .map(
              (s) => SearchSuggestionChip(
                label: s,
                onTap: () => onSuggestionTap(s),
              ),
            )
            .toList(),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
