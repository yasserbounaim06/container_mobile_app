// add_edit_container_dialog.dart (or in main.dart)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // If you need provider inside the dialog for some advanced reason
import 'main.dart'; // To access ShippingContainer and ShippingContainerProvider

class AddEditContainerDialog extends StatefulWidget {
  final ShippingContainer? containerToEdit; // Pass this if editing

  const AddEditContainerDialog({super.key, this.containerToEdit});

  @override
  State<AddEditContainerDialog> createState() => _AddEditContainerDialogState();
}

class _AddEditContainerDialogState extends State<AddEditContainerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _isoCodeController;

  bool get _isEditing => widget.containerToEdit != null;

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.containerToEdit?.number ?? '');
    _isoCodeController =
        TextEditingController(text: widget.containerToEdit?.isoCode ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _isoCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final number = _numberController.text;
      final isoCode = _isoCodeController.text;
      final provider = Provider.of<ShippingContainerProvider>(
          context, listen: false);

      if (_isEditing) {
        // --- EDIT LOGIC (We'll implement this method in ShippingContainerProvider later) ---
        final updatedContainer = widget.containerToEdit!.copyWith(
          number: number,
          isoCode: isoCode,
          // createdAt is not usually edited, but kept from original
        );
        provider.updateContainer(updatedContainer); // New method needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Container ${updatedContainer.number} updated!')),
        );
      } else {
        // --- ADD LOGIC ---
        final newContainer = ShippingContainer(
          number: number,
          isoCode: isoCode,
          createdAt: DateTime.now(),
        );
        provider.addContainer(newContainer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Container ${newContainer.number} added!')),
        );
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Container' : 'Add New Container'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for AlertDialog content
          children: <Widget>[
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Container Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a container number';
                }
                // Optional: Check if container number already exists (if adding)
                // This would require access to the provider here, or passing the list
                if (!_isEditing) {
                  final provider = Provider.of<ShippingContainerProvider>(
                      context, listen: false);
                  if (provider.containers.any((c) => c.number == value)) {
                    return 'This container number already exists.';
                  }
                }
                return null;
              },
            ),
            TextFormField(
              controller: _isoCodeController,
              decoration: const InputDecoration(labelText: 'ISO Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an ISO code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text(_isEditing ? 'Save Changes' : 'Add'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}