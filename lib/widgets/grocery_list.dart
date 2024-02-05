import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart'; // Access to predefined categories data.
import 'package:shopping_list_app/models/grocery_item.dart'; // Model for grocery items.
import 'package:shopping_list_app/widgets/new_item.dart'; // Widget to add a new grocery item.
import 'package:http/http.dart' as http; // HTTP package for network requests.
import 'dart:convert'; // Dart JSON codec for encoding and decoding requests.

// StatefulWidget to display a dynamic list of grocery items fetched from a remote database.
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = []; // Local list to store grocery items.
  late Future<List<GroceryItem>>
      _loadedItems; // Future for async loading of items.

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems(); // Load items from the remote database on init.
  }

  // Asynchronously loads grocery items from a Firebase database.
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https('flutter-prep-711b4-default-rtdb.firebaseio.com',
        'shopping-list.json'); // Database URL.

    final response = await http.get(url); // Perform GET request.
    // Check for error status code.
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please retry later!');
    }

    // Check for empty database response.
    if (response.body == 'null') {
      return [];
    }

    // Decode JSON response.
    final Map<String, dynamic> listData = json.decode(response.body);
    // Temporary list to store loaded items.
    final List<GroceryItem> loadedItems = [];

    // Iterate over the decoded list and convert each item to a GroceryItem.
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.name == item.value['category'])
          .value; // Find matching category for each item.
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return loadedItems; // Return the list of loaded items.
  }

  // Function to navigate to NewItem widget and add a returned GroceryItem to the list.
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(), // Navigates to the NewItem widget.
      ),
    );

    // Check if a new item was actually added.
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem); // Add the new item to the local list.
    });
  }

  // Function to remove a GroceryItem from the list and the remote database.
  void _removeItem(GroceryItem item) async {
    final index =
        _groceryItems.indexOf(item); // Finds the item's index in the list.

    setState(() {
      _groceryItems.remove(item); // Remove the item from the local list.
    });

    // URL for the specific item in the database.
    final url = Uri.https('flutter-prep-711b4-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url); // Perform DELETE request.

    // Check for error response.
    if (response.statusCode >= 400) {
      // Best practise to show an error message here.
      setState(() {
        _groceryItems.insert(index, item); // Re-insert the item on error.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: _loadedItems, // Future for loading items asynchronously.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading spinner.
          }

          // Error handling.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(), // Display error message.
              ),
            );
          }

          // Check for empty data.
          if (snapshot.data!.isEmpty) {
            // Placeholder text for empty list.
            return const Center(
              child: Text('No items added yet.'),
            );
          }

          // Display the list of items if there are any.
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]); // Remove item on swipe.
              },
              key: ValueKey(snapshot
                  .data![index].id), // Unique key for Dismissible widget.
              child: ListTile(
                title: Text(snapshot.data![index].name), // Item name.
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category
                      .color, // Apply color from the item's category.
                ),
                trailing: Text(snapshot.data![index].quantity
                    .toString()), // Display the item's quantity as trailing text.
              ),
            ),
          );
        },
      ),
    );
  }
}
