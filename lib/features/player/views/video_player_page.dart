import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ott/core/config/app_colors.dart';
import 'package:ott/features/home/models/video_model.dart';
import 'package:ott/features/player/viewmodels/video_player_cubit.dart';

class VideoPlayerPage extends StatelessWidget {
  final Video video;
  final String? categoryId;

  const VideoPlayerPage({
    super.key,
    required this.video,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPlayerCubit(
        initialVideo: video,
        categoryId: categoryId,
      ),
      child: const VideoPlayerView(),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late PageController _pageController;
  final Map<String, BetterPlayerController> _videoControllers = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllerForCurrentPage();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  void _initializeControllerForCurrentPage() {
    final state = context.read<VideoPlayerCubit>().state;
    if (state.videoQueue.isNotEmpty) {
      final currentVideo = state.videoQueue[_currentPage];
      _getOrCreateController(currentVideo);

      if (_currentPage < state.videoQueue.length - 1) {
        final nextVideo = state.videoQueue[_currentPage + 1];
        _getOrCreateController(nextVideo);
      }
    }
  }

  void _cleanupControllers(int currentPage) {
    final state = context.read<VideoPlayerCubit>().state;
    final validVideoIds = <String>{
      if (currentPage > 0) state.videoQueue[currentPage - 1].id,
      state.videoQueue[currentPage].id,
      if (currentPage < state.videoQueue.length - 1) state.videoQueue[currentPage + 1].id,
    };

    _videoControllers.removeWhere((videoId, controller) {
      if (!validVideoIds.contains(videoId)) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  BetterPlayerController _getOrCreateController(Video video) {
    if (!_videoControllers.containsKey(video.id)) {
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        video.videoUrl,
      );
      final controller = BetterPlayerController(
        const BetterPlayerConfiguration(
          aspectRatio: null,
          fit: BoxFit.cover,
          autoPlay: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableFullscreen: false,
            enablePlayPause: true,
            enableSkips: false,
            showControlsOnInitialize: false,
            loadingColor: AppColors.primaryRed,
            progressBarPlayedColor: AppColors.primaryRed,
            controlBarHeight: 40,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      _videoControllers[video.id] = controller;
    }
    return _videoControllers[video.id]!;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    final cubit = context.read<VideoPlayerCubit>();
    if (page > cubit.state.currentIndex) {
      cubit.nextVideo();
    } else if (page < cubit.state.currentIndex) {
      cubit.previousVideo();
    }

    _initializeControllerForCurrentPage();

    _cleanupControllers(page);

    for (var entry in _videoControllers.entries) {
      if (entry.key != cubit.state.videoQueue[page].id) {
        entry.value.pause();
      }
    }
  }

  Widget _buildVideoPage(Video video) {
    return Stack(
      children: [
        // Video player taking full screen
        SizedBox.expand(
          child: BetterPlayer(
            controller: _getOrCreateController(video),
          ),
        ),
        // Overlay with video information
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${video.duration.inMinutes} minutes',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final currentVideo = state.currentVideo;
          if (currentVideo == null) {
            return const Center(
              child: Text(
                'No video available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: state.videoQueue.length,
            itemBuilder: (context, index) {
              return _buildVideoPage(state.videoQueue[index]);
            },
          );
        },
      ),
    );
  }
}
