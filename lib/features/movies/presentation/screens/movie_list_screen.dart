import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../providers/movie_list_provider.dart';
import '../providers/movie_search_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_search_bar.dart';
import '../widgets/movie_shimmer_grid.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial fetch on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieListProvider>().fetchMovies();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      final searchProvider = context.read<MovieSearchProvider>();
      if (searchProvider.isSearching) {
        searchProvider.loadMore();
      } else {
        context.read<MovieListProvider>().loadMoreMovies();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDetail(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listProvider = context.watch<MovieListProvider>();
    final searchProvider = context.watch<MovieSearchProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final isSearching = searchProvider.isSearching;
    final currentList = isSearching ? searchProvider.results : listProvider.movies;
    final isLoading = isSearching ? searchProvider.isLoading : listProvider.isLoading;
    final isLoadingMore = isSearching ? searchProvider.isLoadingMore : listProvider.isLoadingMore;
    final errorMessage = isSearching ? searchProvider.errorMessage : listProvider.errorMessage;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Movie Browser',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Widget
            MovieSearchBar(
              onChanged: (query) => searchProvider.onQueryChanged(query),
              onClear: () => searchProvider.clearSearch(),
            ),

            // Category Filter Bar (Only shown when not actively searching)
            if (!isSearching) _buildCategorySelector(listProvider, isDark),

            // Search Active Header (Shown when searching)
            if (isSearching) _buildSearchHeader(searchProvider, isDark),

            // Main Content Area
            Expanded(
              child: _buildBody(
                isLoading: isLoading,
                isLoadingMore: isLoadingMore,
                errorMessage: errorMessage,
                movies: currentList,
                isSearching: isSearching,
                listProvider: listProvider,
                searchProvider: searchProvider,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(MovieListProvider provider, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: MovieCategory.values.map((category) {
          final isSelected = provider.currentCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (_) => provider.setCategory(category),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: isDark ? AppTheme.darkCard : const Color(0xFFE9EEF5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchHeader(MovieSearchProvider searchProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Search results for "${searchProvider.query}"',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (searchProvider.totalResults > 0)
            Text(
              '${searchProvider.totalResults} found',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool isLoadingMore,
    required String? errorMessage,
    required List<Movie> movies,
    required bool isSearching,
    required MovieListProvider listProvider,
    required MovieSearchProvider searchProvider,
    required bool isDark,
  }) {
    if (isLoading && movies.isEmpty) {
      return const MovieShimmerGrid();
    }

    if (errorMessage != null && movies.isEmpty) {
      return ErrorView(
        message: errorMessage,
        onRetry: () {
          if (isSearching) {
            searchProvider.onQueryChanged(searchProvider.query);
          } else {
            listProvider.fetchMovies();
          }
        },
      );
    }

    if (isSearching && movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              const SizedBox(height: 14),
              Text(
                'No movies found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching for another movie title.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
                ? 4
                : 2;

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          onRefresh: () async {
            if (isSearching) {
              searchProvider.onQueryChanged(searchProvider.query);
            } else {
              await listProvider.fetchMovies(isRefresh: true);
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () => _navigateToDetail(movie),
                      );
                    },
                    childCount: movies.length,
                  ),
                ),
              ),

              // Bottom Loading Indicator during infinite scroll
              if (isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
