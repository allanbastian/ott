import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ott/core/services/video_service.dart';
import 'package:ott/features/home/models/category_model.dart';
import 'package:ott/features/home/models/video_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VideoService _videoService;

  HomeCubit({VideoService? videoService})
      : _videoService = videoService ?? VideoService(),
        super(const HomeState());

  Future<void> loadHomePageData() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Load categories and featured videos
      final categories = await _videoService.loadCategories();
      final allVideos = categories.expand((cat) => cat.videos).toList();

      // Get featured videos (first few videos)
      final featured = allVideos.take(5).toList();

      // Get some videos for continue watching section
      final continueWatching = allVideos.skip(2).take(3).toList();

      emit(state.copyWith(
        featuredVideos: featured,
        categories: categories,
        continueWatching: continueWatching,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load home page data: $e',
      ));
    }
  }

  Future<void> refreshHomePageData() async {
    emit(state.copyWith(error: null));
    await loadHomePageData();
  }
}
