import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ott/features/home/models/category_model.dart';
import 'package:ott/features/home/models/video_model.dart';

class VideoService {
  static const String _dataPath = 'assets/data/videos.json';

  Future<List<Category>> loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> categoriesJson = jsonData['categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load video data: $e');
    }
  }

  Future<List<Video>> loadAllVideos() async {
    final categories = await loadCategories();
    return categories.expand((category) => category.videos).toList();
  }

  Future<List<Video>> loadVideosByCategory(String categoryId) async {
    final categories = await loadCategories();
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found: $categoryId'),
    );
    return category.videos;
  }

  Future<Video> loadVideoById(String videoId) async {
    final videos = await loadAllVideos();
    return videos.firstWhere(
      (video) => video.id == videoId,
      orElse: () => throw Exception('Video not found: $videoId'),
    );
  }

  Future<List<Video>> loadFeaturedVideos() async {
    final videos = await loadAllVideos();
    return videos.take(5).toList();
  }

  Future<List<Video>> loadTrendingVideos() async {
    final videos = await loadAllVideos();
    return videos.skip(2).take(5).toList();
  }
}
