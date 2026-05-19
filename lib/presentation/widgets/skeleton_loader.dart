import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

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
          Row(
            children: const [
              SkeletonBox(width: 60, height: 14),
              Spacer(),
              SkeletonBox(width: 60, height: 14),
            ],
          ),
          const SizedBox(height: 6),
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

class PopularFlightSkeleton extends StatelessWidget {
  const PopularFlightSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          context.w(16), context.h(14), context.w(16), context.h(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: SkeletonBox(width: context.w(180), height: context.h(15))),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              SkeletonBox(width: context.w(50), height: context.h(13)),
              const Spacer(),
              SkeletonBox(width: context.w(50), height: context.h(13)),
            ],
          ),
          SizedBox(height: context.h(6)),
          Row(
            children: [
              SkeletonBox(width: context.w(110), height: context.h(11)),
              const Spacer(),
              SkeletonBox(width: context.w(40), height: context.h(10)),
              const Spacer(),
              SkeletonBox(width: context.w(110), height: context.h(11)),
            ],
          ),
          const Spacer(),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          SizedBox(height: context.h(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: context.w(30), height: context.h(10)),
                  SizedBox(height: context.h(4)),
                  SkeletonBox(width: context.w(55), height: context.h(14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: context.w(30), height: context.h(10)),
                  SizedBox(height: context.h(4)),
                  SkeletonBox(width: context.w(55), height: context.h(12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
