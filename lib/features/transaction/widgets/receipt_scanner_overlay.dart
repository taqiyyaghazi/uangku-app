import 'package:flutter/material.dart';
import 'package:uangku/core/theme/app_theme.dart';

class ReceiptScannerOverlay extends StatefulWidget {
  const ReceiptScannerOverlay({super.key});

  @override
  State<ReceiptScannerOverlay> createState() => _ReceiptScannerOverlayState();
}

class _ReceiptScannerOverlayState extends State<ReceiptScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0.0, _animation.value),
                        child: Container(
                          height: 4,
                          width: 120,
                          decoration: BoxDecoration(
                            color: OceanFlowColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: OceanFlowColors.primary.withValues(
                                  alpha: 0.8,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reading your receipt...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
