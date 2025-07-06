import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'video_model.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category extends Equatable {
  final String id;
  final String name;
  final List<Video> videos;

  const Category({
    required this.id,
    required this.name,
    required this.videos,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, name, videos];
}
