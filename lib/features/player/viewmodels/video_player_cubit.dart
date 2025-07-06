import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ott/core/services/video_service.dart';
import 'package:ott/features/home/models/video_model.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  final VideoService _videoService;
  final Video initialVideo;
  final String? categoryId;

  VideoPlayerCubit({
    required this.initialVideo,
    this.categoryId,
    VideoService? videoService,
  })  : _videoService = videoService ?? VideoService(),
        super(const VideoPlayerState()) {
    _initializeQueue();
  }

  Future<void> _initializeQueue() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      List<Video> videos;
      if (categoryId != null) {
        videos = await _videoService.loadVideosByCategory(categoryId!);
      } else {
        videos = await _videoService.loadAllVideos();
      }

      final initialIndex = videos.indexWhere((v) => v.id == initialVideo.id);
      if (initialIndex == -1) {
        videos = [initialVideo, ...videos];
        emit(
          state.copyWith(
            videoQueue: videos,
            currentIndex: 0,
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            videoQueue: videos,
            currentIndex: initialIndex,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load video queue: $e',
        ),
      );
    }
  }

  void nextVideo() {
    if (state.hasNext) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previousVideo() {
    if (state.hasPrevious) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void setBuffering(bool isBuffering) {
    emit(state.copyWith(isBuffering: isBuffering));
  }
}
