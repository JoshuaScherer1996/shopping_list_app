import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart'; // Provides access to predefined categories.
import 'package:shopping_list_app/models/category.dart'; // Category model for the dropdown.
import 'package:http/http.dart' as http; // HTTP package for network requests.
import 'package:shopping_list_app/models/grocery_item.dart'; // Model for grocery items.

// StatefulWidget for adding a new item to the grocery list.
class NewItem extends StatefulWidget {
  const NewItem({super.key}); // Constructor with an optional Key parameter.

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // Key for the form to validate and save form data.
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false; // Flag to show loading indicator when sending data.

  // Function to save the new item to the remote database and return it to the previous screen.
  void _saveItem() async {
    // Validates the form fields.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Saves the form field values.
      setState(() {
        _isSending = true; // Shows loading indicator.
      });
      // URL for the POST request.
      final url = Uri.https('flutter-prep-711b4-default-rtdb.firebaseio.com',
          'shopping-list.json');
      // Makes a POST request to save the item.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory
                .name, // Converts the selected category to a string.
          },
        ),
      );

      // Decodes the response body to get the ID of the new item.
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Checks if the context is still active before navigating back.
      if (!context.mounted) {
        return;
      }

      // Navigates back to the previous screen with the new GroceryItem.
      Navigator.of(context).pop(
        GroceryItem(
          // Uses the unique ID returned by the database.
          id: responseData['name'],
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
          key: _formKey, // Associates the form key.
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  // Validates the name field.
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 2 and 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!; // Saves the entered name.
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
                      // Sets the keyboard type for numbers.
                      keyboardType: TextInputType.number,
                      // Sets the initial value.
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        // Validates the entered quantity to ensure it's a positive number.
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a valid positive number.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Saves the entered quantity after validation.
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value:
                          _selectedCategory, // Sets the current selected category.
                      items: [
                        // Creates dropdown items for each category available.
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category
                                .value, // Sets the value of the dropdown item.
                            child: Row(
                              children: [
                                Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color),
                                const SizedBox(width: 6),
                                // Displays the category name.
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        // Updates the selected category when a new option is selected.
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
                mainAxisAlignment: MainAxisAlignment
                    .end, // Aligns the buttons to the end of the row.
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null // Disables the button if the form is currently sending.
                        : () {
                            _formKey.currentState!
                                .reset(); // Resets the form fields to their initial values.
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending
                        ? null
                        : _saveItem, // Calls _saveItem function if not currently sending.
                    child: _isSending
                        ? const SizedBox(
                            // Shows a loading indicator if the item is being saved.
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
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
