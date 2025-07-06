part of 'home_cubit.dart';

class HomeState extends Equatable {
  final List<Video> featuredVideos;
  final List<Category> categories;
  final List<Video> continueWatching;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.featuredVideos = const [],
    this.categories = const [],
    this.continueWatching = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<Video>? featuredVideos,
    List<Category>? categories,
    List<Video>? continueWatching,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      featuredVideos: featuredVideos ?? this.featuredVideos,
      categories: categories ?? this.categories,
      continueWatching: continueWatching ?? this.continueWatching,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [featuredVideos, categories, continueWatching, isLoading, error];
}
