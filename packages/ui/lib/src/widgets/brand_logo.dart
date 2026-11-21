import 'package:flutter/material.dart';

import 'champion_hex.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bar = size * 0.12;
    return Semantics(
      label: 'TFT Insights',
      image: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          EmptyHex(size: size, color: scheme.primaryContainer),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, height) in [0.19, 0.3, 0.42].indexed) ...[
                if (index > 0) SizedBox(width: bar * 0.55),
                Container(
                  width: bar,
                  height: size * height,
                  decoration: BoxDecoration(
                    color: scheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(bar * 0.25),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
