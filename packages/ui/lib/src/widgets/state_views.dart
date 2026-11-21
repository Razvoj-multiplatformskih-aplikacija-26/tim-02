import 'package:flutter/material.dart';

import '../text/failures.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(semanticsLabel: 'Učitavanje'));
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 20),
                  Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.onRetry, this.cause});

  final VoidCallback onRetry;
  final Object? cause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 20),
                  Semantics(
                    liveRegion: true,
                    child: Text(failureMessage(cause), style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
