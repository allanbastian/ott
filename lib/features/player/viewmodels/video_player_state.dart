part of 'video_player_cubit.dart';

class VideoPlayerState extends Equatable {
  final List<Video> videoQueue;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final bool isBuffering;

  const VideoPlayerState({
    this.videoQueue = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.isBuffering = false,
  });

  Video? get currentVideo => videoQueue.isNotEmpty && currentIndex < videoQueue.length ? videoQueue[currentIndex] : null;

  bool get hasNext => currentIndex < videoQueue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  VideoPlayerState copyWith({
    List<Video>? videoQueue,
    int? currentIndex,
    bool? isLoading,
    String? error,
    bool? isBuffering,
  }) {
    return VideoPlayerState(
      videoQueue: videoQueue ?? this.videoQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }

  @override
  List<Object?> get props => [
        videoQueue,
        currentIndex,
        isLoading,
        error,
        isBuffering,
      ];
}