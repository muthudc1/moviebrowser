import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/env_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/movies/data/datasources/movie_local_datasource.dart';
import 'features/movies/data/datasources/movie_remote_datasource.dart';
import 'features/movies/data/repositories/movie_repository.dart';
import 'features/movies/presentation/providers/movie_detail_provider.dart';
import 'features/movies/presentation/providers/movie_list_provider.dart';
import 'features/movies/presentation/providers/movie_search_provider.dart';
import 'features/movies/presentation/providers/theme_provider.dart';
import 'features/movies/presentation/screens/movie_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment configuration
  await EnvConfig.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Core Services
  final apiClient = ApiClient();
  final remoteDataSource = MovieRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = MovieLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final movieRepository = MovieRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieListProvider(repository: movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieSearchProvider(repository: movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieDetailProvider(repository: movieRepository),
        ),
      ],
      child: const MovieBrowserApp(),
    ),
  );
}

class MovieBrowserApp extends StatelessWidget {
  const MovieBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Movie Browser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MovieListScreen(),
    );
  }
}
