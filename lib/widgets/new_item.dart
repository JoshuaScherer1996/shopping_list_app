import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart'; // Accesses predefined item categories.
import 'package:shopping_list_app/models/category.dart'; // Category model for dropdown selection.
import 'package:http/http.dart' as http; // Used for making HTTP requests.
import 'package:shopping_list_app/models/grocery_item.dart'; // Model for the grocery item.

// StatefulWidget to add a new grocery item.
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>(); // Form key to manage form state.
  var _enteredName = '';
  var _enteredQuantity = 1;
  // Default category is 'vegetables'.
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false; // Tracks if the app is currently sending a request.

  // Function to save the new item to the backend.
  void _saveItem() async {
    // Validates the form fields before proceeding.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Saves the current state of the form.
      setState(() {
        _isSending =
            true; // Indicates that the app is sending the request, disables buttons.
      });
      // URL for the database endpoint.
      final url = Uri.https('flutter-prep-711b4-default-rtdb.firebaseio.com',
          'shopping-list.json');
      // Performs a POST request to the database with the item details.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            // Uses the name of the selected category for the request.
            'category': _selectedCategory.name,
          },
        ),
      );

      // Decodes the response body to retrieve the database ID of the new item.
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Checks if the widget is still mounted before proceeding.
      if (!context.mounted) {
        return;
      }

      // Pops the current screen and returns the new item details to the calling widget.
      Navigator.of(context).pop(
        GroceryItem(
          id: responseData['name'], // The database ID of the new item.
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey, // Associates the form with a GlobalKey.
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  // Validation logic for the name field.
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 2 and 50 characters."; // Validation message.
                  }
                  return null; // Returns null if the input is valid.
                },
                // Saves the input to the _enteredName variable.
                onSaved: (value) {
                  _enteredName = value!;
                },
              ), // Instead of TextField()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantitiy'),
                      ),
                      keyboardType: TextInputType
                          .number, // Sets the keyboard type to numeric.
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        // Validation logic for the quantity field.
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a valid positive number."; // Validation message.
                        }
                        return null; // Returns null if the input is valid.
                      },
                      // Saves the input to the _enteredQuantity variable.
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        // Dropdown items created from categories.
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color),
                                const SizedBox(width: 6),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      // Updates the selected category based on user selection.
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    // Button is disabled if _isSending is true, otherwise resets the form.
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!
                                .reset(); // Resets the form when the reset button is clicked.
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    // Button is disabled if _isSending is true, otherwise calls _saveItem.
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(), // Shows a loading spinner when the form is being submitted.
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
