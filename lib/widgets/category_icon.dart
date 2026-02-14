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
    return Container(
      width: size + 24,
      height: size + 24,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: color, width: 3) : null,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : color,
        size: size * 0.6,
      ),
    );
  }
}
