import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';
import 'rating_badge.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Movie: ${movie.title}, Rating: ${movie.ratingFormatted}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster Image
              Hero(
                tag: 'movie-poster-${movie.id}',
                child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: isDark ? const Color(0xFF242C38) : const Color(0xFFE2E8F0),
                          highlightColor: isDark ? const Color(0xFF323B4A) : const Color(0xFFF8FAFC),
                          child: Container(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholderImage(isDark),
                      )
                    : _buildPlaceholderImage(isDark),
              ),

              // Gradient Overlay for Readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(30),
                        Colors.transparent,
                        Colors.black.withAlpha(160),
                        Colors.black.withAlpha(230),
                      ],
                      stops: const [0.0, 0.4, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // Rating Badge at Top-Right
              Positioned(
                top: 8,
                right: 8,
                child: RatingBadge(rating: movie.voteAverage),
              ),

              // Movie Title and Release Year at Bottom
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Colors.white.withAlpha(180),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                            color: Colors.white.withAlpha(190),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1B2028) : const Color(0xFFE2E8F0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 40,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              'No Poster',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
