import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Required for Future.delayed

// If AddEditContainerDialog is in a separate file, you'd import it like this:
// import 'add_edit_container_dialog.dart';

/// The main entry point of the application.
void main() {
  runApp(const MyApp());
}

// --- DATA_MODEL ---

/// Represents a shipping container with its number, ISO code, and creation date.
class ShippingContainer {
  final String number;
  final String isoCode;
  final DateTime createdAt;

  /// Creates a [ShippingContainer] instance.
  ///
  /// All parameters are required.
  const ShippingContainer({
    required this.number,
    required this.isoCode,
    required this.createdAt,
  });

  /// Creates a copy of this [ShippingContainer] with optional new values.
  ShippingContainer copyWith({
    String? number,
    String? isoCode,
    DateTime? createdAt,
  }) {
    return ShippingContainer(
      number: number ?? this.number,
      isoCode: isoCode ?? this.isoCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts this [ShippingContainer] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'isoCode': isoCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a [ShippingContainer] from a JSON map.
  factory ShippingContainer.fromJson(Map<String, dynamic> json) {
    if (json['number'] == null || json['isoCode'] == null || json['createdAt'] == null) {
      throw const FormatException("Invalid JSON for ShippingContainer: missing required fields.");
    }
    return ShippingContainer(
      number: json['number'] as String,
      isoCode: json['isoCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// --- STATE_MANAGEMENT ---

/// Manages the list of shipping containers and provides methods to interact with them.
class ShippingContainerProvider with ChangeNotifier {
  final List<ShippingContainer> _containers = [];
  bool _isLoading = false;

  /// A read-only view of the shipping containers.
  List<ShippingContainer> get containers => List.unmodifiable(_containers);

  /// Whether the provider is currently loading data.
  bool get isLoading => _isLoading;

  /// Adds a new container to the list and notifies listeners.
  void addContainer(ShippingContainer container) {
    _containers.add(container);
    notifyListeners();
  }

  /// Removes a container from the list and notifies listeners.
  void removeContainer(ShippingContainer container) {
    _containers.removeWhere((c) => c.createdAt == container.createdAt); // Use a reliable unique ID
    notifyListeners();
  }

  /// Updates an existing container in the list and notifies listeners.
  ///
  /// Throws an [Exception] if the container to update is not found.
  void updateContainer(ShippingContainer updatedContainer) {
    final index = _containers.indexWhere((c) => c.createdAt == updatedContainer.createdAt); // Use a reliable unique ID

    if (index != -1) {
      _containers[index] = updatedContainer;
      notifyListeners();
    } else {
      // In a real app, consider logging this or a more user-friendly error.
      throw Exception('Container with createdAt ${updatedContainer.createdAt} not found for update.');
    }
  }

  /// Simulates loading containers from a data source.
  Future<void> loadContainers() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate loading some data
    _containers.addAll([
      ShippingContainer(
          number: 'TCNU1234567', isoCode: '22G1', createdAt: DateTime.now().subtract(const Duration(days: 10))),
      ShippingContainer(
          number: 'GESU9876543', isoCode: '45G1', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}

// --- UI_COMPONENTS ---

/// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShippingContainerProvider()..loadContainers(),
      child: MaterialApp(
        title: 'Shipping Container Tracker',
        theme: ThemeData(
          // For Material 3, ThemeData.from is preferred over primarySwatch
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            secondary: Colors.tealAccent, // You can still suggest a secondary
            error: Colors.redAccent,
            brightness: Brightness.light,
            // onPrimary, onSecondary etc., are often derived well by fromSeed
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true, // Enable Material 3 features
        ),
        home: const ContainerListScreen(),
        debugShowCheckedModeBanner: false, // Optional: hide debug banner
      ),
    );
  }
} // MyApp class definition ENDS HERE

/// A screen that displays a list of shipping containers.
class ContainerListScreen extends StatelessWidget {
  const ContainerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // It's good practice to access Theme and Provider once if used multiple times.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Containers'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Consumer<ShippingContainerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.containers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No containers found.\nTap the "+" button to add your first one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.containers.length,
            itemBuilder: (context, index) {
              final container = provider.containers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    child: Text((index + 1).toString()),
                  ),
                  title: Text(container.number, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "ISO: ${container.isoCode}\nAdded: ${container.createdAt.toLocal().toString().substring(0, 16)}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit, color: colorScheme.primary),
                        tooltip: 'Edit Container',
                        onPressed: () {
                          showDialog<void>( // Specify void for showDialog if no value is expected
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AddEditContainerDialog(containerToEdit: container);
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error),
                        tooltip: 'Delete Container',
                        onPressed: () {
                          showDialog<void>( // Specify void
                            context: context,
                            builder: (BuildContext alertContext) { // Changed variable name for clarity
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete container ${container.number}?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(alertContext).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                                    onPressed: () {
                                      // Access provider from the Consumer's context or a new context.
                                      // Here, using the 'context' from the builder is fine.
                                      Provider.of<ShippingContainerProvider>(context, listen: false)
                                          .removeContainer(container);
                                      Navigator.of(alertContext).pop(); // Close confirmation dialog
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Container ${container.number} deleted!'),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating, // Optional: modern look
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog<void>( // Specify void
            context: context,
            builder: (BuildContext dialogContext) {
              return const AddEditContainerDialog();
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Container"),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    );
  }
} // ContainerListScreen class definition ENDS HERE

/// A dialog for adding a new shipping container or editing an existing one.
class AddEditContainerDialog extends StatefulWidget {
  final ShippingContainer? containerToEdit;

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
    _numberController = TextEditingController(text: widget.containerToEdit?.number ?? '');
    _isoCodeController = TextEditingController(text: widget.containerToEdit?.isoCode ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _isoCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Ensure widget is still mounted before proceeding, especially for async operations.
    if (!mounted) return;

    if (_formKey.currentState?.validate() ?? false) {
      final number = _numberController.text.trim();
      final isoCode = _isoCodeController.text.trim();
      final provider = Provider.of<ShippingContainerProvider>(context, listen: false);

      try {
        if (_isEditing) {
          // Ensure containerToEdit is not null when editing
          if (widget.containerToEdit == null) {
            throw Exception("Attempting to edit a null container.");
          }
          final updatedContainer = widget.containerToEdit!.copyWith(
            number: number,
            isoCode: isoCode,
            // createdAt is kept from the original for identification
          );
          provider.updateContainer(updatedContainer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Container ${updatedContainer.number} updated!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating),
          );
        } else {
          final newContainer = ShippingContainer(
            number: number,
            isoCode: isoCode,
            createdAt: DateTime.now(),
          );
          provider.addContainer(newContainer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Container ${newContainer.number} added!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating),
          );
        }
        if (mounted) {
          Navigator.of(context).pop(); // Close the dialog
        }
      } catch (e) {
        // Handle potential errors from provider (e.g., container not found for update)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Container' : 'Add New Container'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for AlertDialog content
          children: <Widget>[
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Container Number',
                hintText: 'e.g. TCNU1234567',
                border: OutlineInputBorder(), // Consistent styling
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a container number.';
                }
                // Check for duplicates, ensuring not to compare against itself when editing
                final existingContainer = Provider.of<ShippingContainerProvider>(context, listen: false)
                    .containers
                    .firstWhere(
                        (c) => c.number == value.trim() && (_isEditing ? c.createdAt != widget.containerToEdit!.createdAt : true),
                    orElse: () => ShippingContainer(number: '', isoCode: '', createdAt: DateTime(0)) // Sentinel if not found
                );

                if (existingContainer.createdAt != DateTime(0) ) { // If a different container with the same number was found
                  return 'This container number already exists.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16), // Increased spacing
            TextFormField(
              controller: _isoCodeController,
              decoration: const InputDecoration(
                labelText: 'ISO Code',
                hintText: 'e.g. 22G1',
                border: OutlineInputBorder(), // Consistent styling
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an ISO code.';
                }
                // Basic ISO code format check (example, can be more complex)
                if (!RegExp(r"^[A-Z]{3}U[0-9]{6}[0-9]$").hasMatch(value.trim()) && !RegExp(r"^[0-9]{2}[A-Z0-9]{2}$").hasMatch(value.trim()) && !RegExp(r"^[A-Z]{1}[0-9]{1}[A-Z0-9]{2}$").hasMatch(value.trim()) ) {
                  // This is a very basic check. A real app might need more robust ISO validation.
                  // For now, let's allow common patterns like 22G1, 45G1, 42R1 (ISO 6346 for containers often end like this after the number part)
                  // or simple ISO codes like T1, U1 etc. if that's what you mean by ISO code here.
                  // The provided examples '22G1' and '45G1' fit a pattern like two digits followed by a letter and a digit.
                  // Let's assume a flexible format for now, or you can make this stricter.
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
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? colorScheme.primary : colorScheme.secondary,
            foregroundColor: _isEditing ? colorScheme.onPrimary : colorScheme.onSecondary,
          ),
          onPressed: _submitForm,
          child: Text(_isEditing ? 'Save Changes' : 'Add Container'),
        ),
      ],
    );
  }
}
