import 'package:flutter/material.dart';

import '../../domain/entities/media_track.dart';
import 'track_artwork.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    required this.track,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
    this.isActive = false,
    super.key,
  });

  final MediaTrack track;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMore;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          children: [
            TrackArtwork(track: track),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isActive ? scheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        track.isLocal
                            ? Icons.phone_android_rounded
                            : Icons.smart_display_rounded,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${track.artist} · ${track.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: track.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: onFavorite,
              icon: Icon(
                track.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: track.isFavorite ? const Color(0xFFFF5C8A) : null,
              ),
            ),
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
