import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import 'genre_model.dart';

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final int? runtime;
  final List<Genre> genres;
  final String? tagline;
  final String? status;
  final int? budget;
  final int? revenue;
  final String? homepage;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.tagline,
    this.status,
    this.budget,
    this.revenue,
    this.homepage,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      homepage: json['homepage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'runtime': runtime,
      'genres': genres.map((g) => g.toJson()).toList(),
      'tagline': tagline,
      'status': status,
      'budget': budget,
      'revenue': revenue,
      'homepage': homepage,
    };
  }

  String get posterUrl => ApiConstants.getPosterUrl(posterPath, size: ApiConstants.posterLarge);
  String get backdropUrl => ApiConstants.getBackdropUrl(backdropPath, size: ApiConstants.backdropLarge);
  String get formattedReleaseDate => DateFormatter.formatReleaseDate(releaseDate);
  String get formattedRuntime => DateFormatter.formatRuntime(runtime);
  String get ratingFormatted => voteAverage.toStringAsFixed(1);
  String get formattedBudget => DateFormatter.formatCurrency(budget);
  String get formattedRevenue => DateFormatter.formatCurrency(revenue);
}
