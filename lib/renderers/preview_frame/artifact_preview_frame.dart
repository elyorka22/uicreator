import 'package:flutter/material.dart';

/// Claude-style artifact stage: component sits inside a soft rounded container,
/// not stretched as a full-screen page.
class ArtifactPreviewFrame extends StatelessWidget {
  const ArtifactPreviewFrame({
    super.key,
    required this.child,
    this.caption,
    this.minHeight = 220,
    this.maxContentWidth = 420,
  });

  final Widget child;
  final String? caption;
  final double minHeight;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: const Color(0xFFE8EAED),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 520;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 28 : 16,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth,
                  minHeight: minHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Preview',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: const Color(0xFF5F6368),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                              child: Center(
                                child: child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (caption != null && caption!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        caption!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5F6368),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
