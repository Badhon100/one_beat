import 'package:flutter/material.dart';

class OneBeatMark extends StatelessWidget {
  const OneBeatMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.multitrack_audio_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text('onebeat', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
