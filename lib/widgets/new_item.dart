import 'package:flutter/material.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  return 'Demo...';
                },
              ), // Instead of TextField()
              Row(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Quantitiy'),
                    ),
                    initialValue: '1',
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonFormField(items: items, onChanged: onChanged)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
