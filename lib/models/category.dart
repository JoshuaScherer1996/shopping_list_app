import 'package:flutter/material.dart';

// Enum defining different categories of items.
enum Categories {
  vegetables,
  dairy,
  fruit,
  meat,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

// Defines a Category object with a name and color.
class Category {
  // Constructor for creating a Category with a name and color.
  const Category(this.name, this.color);

  // Class variables.
  final String name;
  final Color color;
}
