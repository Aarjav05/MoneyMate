import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int iconCodePoint;

  @HiveField(3)
  late int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  // Get IconData from code point
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Get Color from value
  Color get color => Color(colorValue);

  // Create a copy with modifications
  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
