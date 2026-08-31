import 'package:flutter/material.dart';

class CapabilityTile extends StatelessWidget {
  const CapabilityTile({
    required this.label,
    required this.value,
    required this.supported,
    super.key,
  });

  final String label;
  final String value;
  final bool supported;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          supported ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: supported ? const Color(0xFF0F9D76) : const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
