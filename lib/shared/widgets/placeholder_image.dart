import 'package:flutter/material.dart';
import 'package:ott/core/config/app_colors.dart';

class PlaceholderImage extends StatelessWidget {
  final double? width;
  final double? height;

  const PlaceholderImage({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 48,
            color: AppColors.primaryRed.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No Preview',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryRed.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}
