import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

// StatefulWidget for displaying and managing the list of grocery items.
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

// State class for GroceryList, handling the dynamic list of grocery items.
class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = []; // List to store grocery items.

  // Function to navigate to the NewItem widget and add a new GroceryItem to the list.
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(), // Navigates to the NewItem widget.
      ),
    );

    // If the result (newItem) is not null, add it to the grocery items list.
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // Function to remove a GroceryItem from the list.
  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default content displays when the list is empty.
    Widget content = const Center(
      child: Text('No items added yet.'), // Placeholder text.
    );

    // If there are items in the list, display them using a ListView.builder.
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length, // Number of items in the list.
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]); // Removes the item when swiped.
          },
          key: ValueKey(
              _groceryItems[index].id), // Unique key for Dismissible widget.
          child: ListTile(
            title: Text(_groceryItems[index].name), // Name of the grocery item.
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index]
                  .category
                  .color, // Color indicator for the category.
            ),
            trailing: Text(_groceryItems[index]
                .quantity
                .toString()), // Quantity of the item.
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content, // Displaying the content based on _groceryItems list.
    );
  }
}
