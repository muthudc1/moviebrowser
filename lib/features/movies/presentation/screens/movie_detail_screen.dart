import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/genre_chip.dart';
import '../widgets/rating_badge.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailProvider>().fetchMovieDetail(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailProvider = context.watch<MovieDetailProvider>();
    final detail = detailProvider.getDetail(widget.movie.id);
    final isLoading = detailProvider.isLoading(widget.movie.id);
    final error = detailProvider.getError(widget.movie.id);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Dynamic Sliver App Bar with Backdrop & Hero Poster
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withAlpha(160),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  if (widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.movie.backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0),
                      ),
                    )
                  else if (widget.movie.posterPath != null && widget.movie.posterPath!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.movie.largePosterUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0)),

                  // Gradient Fades
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(100),
                            Colors.transparent,
                            isDark ? AppTheme.darkBackground.withAlpha(200) : AppTheme.lightBackground.withAlpha(200),
                            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                          ],
                          stops: const [0.0, 0.35, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Floating Poster and Quick Details inside header
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Large Hero Poster Card
                        Hero(
                          tag: 'movie-poster-${widget.movie.id}',
                          child: Container(
                            width: 105,
                            height: 155,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(120),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: widget.movie.posterPath != null && widget.movie.posterPath!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.movie.largePosterUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0),
                                    child: const Icon(Icons.movie_rounded, size: 36),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title, Year, Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RatingBadge(
                                rating: widget.movie.voteAverage,
                                fontSize: 13,
                                iconSize: 16,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 6),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.movie.formattedReleaseDate,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withAlpha(220),
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail Status (Tagline or Runtime chips)
                  if (isLoading)
                    _buildDetailShimmer(isDark)
                  else if (error != null && detail == null)
                    ErrorView(
                      message: error,
                      onRetry: () => context.read<MovieDetailProvider>().fetchMovieDetail(widget.movie.id, forceRefresh: true),
                    )
                  else ...[
                    // Tagline
                    if (detail?.tagline != null && detail!.tagline!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
                        ),
                        child: Text(
                          '"${detail.tagline}"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Meta Information Row (Runtime, Status, Vote Count)
                    Row(
                      children: [
                        if (detail?.runtime != null && detail!.runtime! > 0) ...[
                          _buildMetaPill(
                            Icons.timer_outlined,
                            detail.formattedRuntime,
                            isDark,
                          ),
                          const SizedBox(width: 10),
                        ],
                        _buildMetaPill(
                          Icons.how_to_vote_outlined,
                          '${widget.movie.voteCount} votes',
                          isDark,
                        ),
                        if (detail?.status != null) ...[
                          const SizedBox(width: 10),
                          _buildMetaPill(
                            Icons.info_outline_rounded,
                            detail!.status!,
                            isDark,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Genres
                    if (detail != null && detail.genres.isNotEmpty) ...[
                      const Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detail.genres.map((g) => GenreChip(label: g.name)).toList(),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ],

                  // Overview / Synopsis Section
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'No overview provided for this movie.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: isDark ? AppTheme.darkTextPrimary.withAlpha(220) : AppTheme.lightTextPrimary.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Financial / Production Stats if available
                  if (detail != null && ((detail.budget != null && detail.budget! > 0) || (detail.revenue != null && detail.revenue! > 0))) ...[
                    const Divider(),
                    const SizedBox(height: 14),
                    const Text(
                      'Box Office & Production',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (detail.budget != null && detail.budget! > 0)
                          Expanded(
                            child: _buildStatCard('Budget', detail.formattedBudget, isDark),
                          ),
                        if (detail.budget != null && detail.budget! > 0 && detail.revenue != null && detail.revenue! > 0)
                          const SizedBox(width: 12),
                        if (detail.revenue != null && detail.revenue! > 0)
                          Expanded(
                            child: _buildStatCard('Revenue', detail.formattedRevenue, isDark),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E242E) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF2C3543) : const Color(0xFFF1F5F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
