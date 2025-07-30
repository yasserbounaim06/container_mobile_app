import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Required for Future.delayed

/// The main entry point of the application.
void main() {
  runApp(const MyApp());
}

/// DATA_MODEL
/// Represents a shipping container with its number, ISO code, and creation date.
class ShippingContainer {
  final String number;
  final String isoCode;
  final DateTime createdAt;

  /// Creates a [ShippingContainer] instance.
  ShippingContainer({
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
    return ShippingContainer(
      number: json['number'] as String,
      isoCode: json['isoCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// STATE_MANAGEMENT
/// Manages the list of shipping containers and provides methods to interact with them.
class ShippingContainerProvider with ChangeNotifier {
  final List<ShippingContainer> _containers = [];

  List<ShippingContainer> get containers => _containers;

  /// Adds a new container to the list.
  void addContainer(ShippingContainer container) {
    _containers.add(container);
    notifyListeners();
  }

  /// Removes a container from the list.
  void removeContainer(ShippingContainer container) {
    _containers.remove(container);
    notifyListeners();
  }

  /// Simulates loading containers from a data source (e.g., API).
  Future<void> loadContainers() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // Simulate loading some data
    _containers.addAll([
      ShippingContainer(number: 'TCNU1234567', isoCode: '22G1', createdAt: DateTime.now().subtract(const Duration(days: 10))),
      ShippingContainer(number: 'GESU9876543', isoCode: '45G1', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    ]);
    notifyListeners();
  }
}

/// UI_COMPONENTS
/// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShippingContainerProvider()..loadContainers(), // Load data on app start
      child: MaterialApp(
        title: 'Shipping Container Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ContainerListScreen(),
      ),
    );
  }
}

/// A screen that displays a list of shipping containers.
class ContainerListScreen extends StatelessWidget {
  const ContainerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Containers'),
      ),
      body: Consumer<ShippingContainerProvider>(
        builder: (context, provider, child) {
          if (provider.containers.isEmpty) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else {
            return ListView.builder(
              itemCount: provider.containers.length,
              itemBuilder: (context, index) {
                final container = provider.containers[index];
                return ListTile(
                  title: Text(container.number),
                  subtitle: Text(container.isoCode),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeContainer(container),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add container functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
