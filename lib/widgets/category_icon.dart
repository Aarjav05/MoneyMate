import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool isSelected;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: size + 24,
      height: size + 24,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: color.withValues(alpha: 0.3), width: 3)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : color,
          size: size * 0.6,
        ),
      ),
    );
  }
}
