import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/grocery_item.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _examples = [
    const GroceryItem(color: Colors.blue, food: 'Milk', number: '1'),
    const GroceryItem(color: Colors.yellow, food: 'Bananas', number: '5'),
    const GroceryItem(color: Colors.red, food: 'Beef Steak', number: '1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
        ),
      ),
      body: ListView(children: _examples),
    );
  }
}
