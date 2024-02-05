// Import statement for the Category model.
import 'package:shopping_list_app/models/category.dart';

// Defines a GroceryItem object for use in the shopping list.
class GroceryItem {
  // Constructor for creating a GroceryItem with specified properties.
  // Parameters are marked as required to ensure all necessary data is provided upon instantiation.
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  // Properties of the GroceryItem class:
  final String id;
  final String name;
  final int quantity;
  final Category category;
}
