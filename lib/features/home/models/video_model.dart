import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class Video extends Equatable {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  final String categoryId;

  const Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    required this.duration,
    required this.categoryId,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);

  @override
  List<Object?> get props => [id, title, thumbnailUrl, videoUrl, description, duration, categoryId];

  // Custom JSON converters for Duration
  static Duration _durationFromJson(dynamic value) {
    // Handle both string and int inputs
    final seconds = int.parse(value.toString());
    return Duration(seconds: seconds);
  }

  static String _durationToJson(Duration duration) {
    return duration.inSeconds.toString();
  }
}
