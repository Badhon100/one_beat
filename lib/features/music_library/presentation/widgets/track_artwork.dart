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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.square(
        dimension: size,
        child: _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: Icon(
        Icons.graphic_eq_rounded,
        color: Colors.white,
        size: size * .44,
      ),
    );
  }
}
