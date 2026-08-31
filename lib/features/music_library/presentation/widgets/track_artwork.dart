import 'package:flutter/material.dart';

import '../../domain/entities/media_track.dart';

class TrackArtwork extends StatelessWidget {
  const TrackArtwork({
    required this.track,
    this.size = 54,
    this.borderRadius = 14,
    super.key,
  });

  final MediaTrack track;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final youtubeId = track.youtubeVideoId;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.square(
        dimension: size,
        child: youtubeId != null
            ? Image.network(
                'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(context),
              )
            : _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final colors = track.isLocal
        ? const [Color(0xFF8B5CF6), Color(0xFFEC4899)]
        : const [Color(0xFFEF4444), Color(0xFFF97316)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(
        track.isLocal ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: size * .44,
      ),
    );
  }
}
