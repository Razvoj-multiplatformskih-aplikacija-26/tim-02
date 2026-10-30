import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

const _costColors = {
  1: Color(0xFF8A8F98),
  2: Color(0xFF1DB37E),
  3: Color(0xFF2E86DE),
  4: Color(0xFFB548E8),
  5: Color(0xFFF5B400),
};

class ChampionHex extends StatelessWidget {
  const ChampionHex({super.key, required this.champion, this.size = 64});

  final Champion champion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: champion.name,
      image: true,
      child: ClipPath(
        clipper: const _Hexagon(),
        child: Container(
          width: size * 0.87,
          height: size,
          padding: EdgeInsets.all(size * 0.05),
          color: _costColors[champion.cost] ?? theme.colorScheme.outline,
          child: ClipPath(
            clipper: const _Hexagon(),
            child: Image.asset(
              'assets/tft/champions/${champion.id.value}.webp',
              package: 'ui',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(champion.name, textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyHex extends StatelessWidget {
  const EmptyHex({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _Hexagon(),
      child: Container(width: size * 0.87, height: size, color: Theme.of(context).colorScheme.surfaceContainerHighest),
    );
  }
}

class _Hexagon extends CustomClipper<Path> {
  const _Hexagon();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height / 4)
    ..lineTo(size.width, size.height * 3 / 4)
    ..lineTo(size.width / 2, size.height)
    ..lineTo(0, size.height * 3 / 4)
    ..lineTo(0, size.height / 4)
    ..close();

  @override
  bool shouldReclip(_Hexagon oldClipper) => false;
}
