import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart'; // Access to predefined categories.
import 'package:shopping_list_app/models/grocery_item.dart'; // Model for grocery items.
import 'package:shopping_list_app/widgets/new_item.dart'; // Widget to add new grocery items.
import 'package:http/http.dart' as http; // HTTP package for network requests.
import 'dart:convert'; // Dart's built-in JSON codec.

// StatefulWidget to display and manage a grocery list.
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = []; // Local list to store grocery items.
  var _isLoading = true; // Flag to indicate loading state.
  String? _error; // String to store error messages, if any.

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load items from the remote database when the widget is initialized.
  }

  // Asynchronously loads items from a Firebase database.
  void _loadItems() async {
    // URL to the Firebase database endpoint.
    final url = Uri.https(
        'flutter-prep-711b4-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url); // Sends a GET request.
      // Checks for error status code.
      if (response.statusCode >= 400) {
        // Error message for failed fetch.
        setState(() {
          _error = 'Failed to fetch data. Plese try again later!';
        });
      }

      // Handles the case where the database is empty.
      if (response.body == 'null') {
        setState(() {
          _isLoading = false; // Update loading state.
        });
        return;
      }

      // Decodes the JSON response.
      final Map<String, dynamic> listData = json.decode(response.body);
      // Temporary list to store fetched items.
      final List<GroceryItem> loadedItems = [];

      // Iterates over the decoded data, creating GroceryItem objects for each entry.
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((categoryItem) =>
                categoryItem.value.name == item.value['category'])
            .value; // Finds the matching category for each item.
        loadedItems.add(
          GroceryItem(
            id: item.key, // Unique ID from the database.
            name: item.value['name'], // Item name.
            quantity: item.value['quantity'], // Item quantity.
            category: category, // Item category.
          ),
        );
      }
      setState(() {
        // Updates the local list with the fetched items.
        _groceryItems = loadedItems;
        _isLoading = false; // Update loading state.
      });
    } catch (error) {
      setState(() {
        // Error message for exceptions.
        _error = 'Something went wrong! Plese try again later!';
      });
    }
  }

  // Function to add a new item to the list.
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) =>
            const NewItem(), // Navigation to NewItem widget for adding a new item.
      ),
    );

    // Checks if a new item was actually added.
    if (newItem == null) {
      return;
    }

    // Adds the new item to the local list.
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // Function to remove an item from the list and the remote database.
  void _removeItem(GroceryItem item) async {
    // Finds the index of the item to be removed.
    final index = _groceryItems.indexOf(item);

    // Removes the item from the local list.
    setState(() {
      _groceryItems.remove(item);
    });

    // URL for the specific item in the database.
    final url = Uri.https('flutter-prep-711b4-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    // Sends a DELETE request.
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Best practise to show an error message here.
      setState(() {
        _groceryItems.insert(index, item); // Re-inserts the item on error.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget to dynamically change the displayed content.
    Widget content = const Center(
      // Message shown when the list is empty.
      child: Text('No items added yet.'),
    );

    // Displays a loading spinner while data is being fetched.
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    // Displays the list of grocery items if available.
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    // Displays an error message if something went wrong.
    if (_error != null) {
      content = Center(child: Text(_error!));
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
      body: content, // Displays the dynamic content based on the state.
    );
  }
}
