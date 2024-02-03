// implement Stateless widget

import 'package:flutter/material.dart';

class GroceryItem extends StatelessWidget {
  const GroceryItem({
    super.key,
    required this.color,
    required this.food,
    required this.number,
  });

  final Color color;
  final String food;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.all(16),
              width: 50.0, // Width of the square
              height: 50.0, // Height of the square
              color: color // Color of the square
              ),
          Text(food),
          const Spacer(),
          Text(number),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
