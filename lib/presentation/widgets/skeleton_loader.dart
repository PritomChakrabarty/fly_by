import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────
// SHIMMER BOX — pulsing placeholder rectangle
// Each instance owns its own AnimationController (fine for brief loading).
// ─────────────────────────────────────────────────────────────────────
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFFE5E7EB),
            const Color(0xFFF9FAFB),
            _anim.value,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// FLIGHT CARD SKELETON — mirrors _FlightCard layout
// ─────────────────────────────────────────────────────────────────────
class FlightCardSkeleton extends StatelessWidget {
  const FlightCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airline logo + name + stops badge
          Row(
            children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 140, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 10),
                  ],
                ),
              ),
              const SkeletonBox(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 20),
          // Time row
          Row(
            children: const [
              SkeletonBox(width: 60, height: 14),
              Spacer(),
              SkeletonBox(width: 60, height: 14),
            ],
          ),
          const SizedBox(height: 6),
          // Airport codes + duration
          Row(
            children: const [
              SkeletonBox(width: 110, height: 11),
              Spacer(),
              SkeletonBox(width: 45, height: 10),
              Spacer(),
              SkeletonBox(width: 110, height: 11),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 18),
          // Price + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 70, height: 28),
                  SizedBox(height: 4),
                  SkeletonBox(width: 45, height: 10),
                ],
              ),
              const SkeletonBox(width: 110, height: 44, borderRadius: 22),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// POPULAR FLIGHT CARD SKELETON — mirrors _PopularFlightCard layout
// ─────────────────────────────────────────────────────────────────────
class PopularFlightSkeleton extends StatelessWidget {
  const PopularFlightSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airline name (centered)
          Center(child: const SkeletonBox(width: 180, height: 15)),
          const SizedBox(height: 12),
          // Times
          Row(
            children: const [
              SkeletonBox(width: 50, height: 13),
              Spacer(),
              SkeletonBox(width: 50, height: 13),
            ],
          ),
          const SizedBox(height: 6),
          // Codes + duration
          Row(
            children: const [
              SkeletonBox(width: 110, height: 11),
              Spacer(),
              SkeletonBox(width: 40, height: 10),
              Spacer(),
              SkeletonBox(width: 110, height: 11),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          // Price + stops
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 30, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 55, height: 14),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  SkeletonBox(width: 30, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 55, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
