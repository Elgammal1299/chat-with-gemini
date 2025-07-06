# HiveService - Reusable Local Storage Service

## Overview

`HiveService` is a generic, type-safe wrapper around Hive database operations designed to be reusable across multiple Flutter projects. It provides a clean API with built-in error handling, logging, and configuration options.

## Features

### 🚀 **Core Features**
- **Type-safe operations** with generic type support
- **Singleton pattern** for efficient resource management
- **Comprehensive error handling** with custom exceptions
- **Configurable logging** for debugging
- **Flexible configuration** options

### 📦 **Storage Operations**
- **CRUD operations**: Create, Read, Update, Delete
- **Batch operations**: Add multiple items at once
- **Query operations**: Find items by conditions
- **Utility operations**: Clear, close, statistics

### 🔧 **Advanced Features**
- **Automatic box management** (open/close)
- **Key-based and index-based access**
- **Conditional queries** with `where` and `firstWhere`
- **Statistics and monitoring**
- **Extension methods** for additional utilities

## Installation

Add Hive to your `pubspec.yaml`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

## Basic Usage

### 1. Initialize Hive

In your `main.dart`:

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  runApp(MyApp());
}
```

### 2. Create a Hive Model

```dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### 3. Use HiveService

```dart
import 'package:your_app/core/service/hive_service.dart';

class UserRepository {
  late final HiveService<UserModel> _userService;

  Future<void> initialize() async {
    _userService = HiveService.instanceFor<UserModel>(
      boxName: 'users',
      enableLogging: true, // Enable debug logging
    );
    await _userService.init();
  }

  // Add a user
  Future<void> addUser(UserModel user) async {
    await _userService.put(user.id, user);
  }

  // Get a user by ID
  UserModel? getUser(String id) {
    return _userService.get(id);
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    return await _userService.getAll();
  }

  // Find users by condition
  List<UserModel> getActiveUsers() {
    return _userService.where((user) => user.isActive);
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    await _userService.delete(id);
  }
}
```

## API Reference

### Constructor

```dart
static HiveService<T> instanceFor<T>({
  required String boxName,
  bool enableLogging = false,
  Duration? operationTimeout,
})
```

**Parameters:**
- `boxName`: The name of the Hive box
- `enableLogging`: Enable debug logging (default: false)
- `operationTimeout`: Optional timeout for operations

### Core Methods

#### Initialization
```dart
Future<void> init() // Initialize the box
Future<void> close() // Close the box
Future<void> dispose() // Dispose the service
```

#### CRUD Operations
```dart
// Create/Update
Future<void> put(String key, T item) // Add/update by key
Future<int> add(T item) // Add to end, returns index
Future<List<int>> addAll(List<T> items) // Add multiple items

// Read
T? get(String key) // Get by key
T? getAt(int index) // Get by index
Future<List<T>> getAll() // Get all items

// Update
Future<void> putAt(int index, T item) // Update by index

// Delete
Future<void> delete(String key) // Delete by key
Future<void> deleteAt(int index) // Delete by index
Future<void> clear() // Clear all items
```

#### Query Operations
```dart
List<T> where(bool Function(T) test) // Filter items
T? firstWhere(bool Function(T) test, {T? orElse}) // Find first match
```

#### Utility Methods
```dart
bool get isOpen // Check if box is open
int get length // Get item count
bool get isEmpty // Check if empty
bool get isNotEmpty // Check if not empty
List<dynamic> get keys // Get all keys
bool containsKey(String key) // Check if key exists
Map<String, dynamic> get statistics // Get box statistics
```

### Extension Methods

```dart
Map<String, T> toMap() // Convert to key-value map
List<MapEntry<String, T>> toEntries() // Convert to entries
List<T> toList() // Convert to list
```

## Error Handling

The service uses custom exceptions for better error handling:

```dart
class HiveServiceException implements Exception {
  final String message;
  
  HiveServiceException(this.message);
  
  @override
  String toString() => 'HiveServiceException: $message';
}
```

**Example error handling:**

```dart
try {
  await userService.put('user1', user);
} on HiveServiceException catch (e) {
  print('Hive operation failed: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Configuration Options

### Logging

Enable debug logging to see detailed operation information:

```dart
final service = HiveService.instanceFor<UserModel>(
  boxName: 'users',
  enableLogging: true, // Shows: 📦 HiveService[users]: Operation details
);
```

### Timeout

Set operation timeouts for long-running operations:

```dart
final service = HiveService.instanceFor<UserModel>(
  boxName: 'users',
  operationTimeout: Duration(seconds: 30),
);
```

## Best Practices

### 1. **Initialize Once**
```dart
class AppRepository {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  late final HiveService<UserModel> _userService;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    _userService = HiveService.instanceFor<UserModel>(
      boxName: 'users',
      enableLogging: true,
    );
    await _userService.init();
    _initialized = true;
  }
}
```

### 2. **Use Meaningful Keys**
```dart
// Good
await userService.put('user_123', user);
await userService.put('settings_global', settings);

// Avoid
await userService.put('1', user);
await userService.put('data', settings);
```

### 3. **Handle Errors Gracefully**
```dart
Future<UserModel?> getUserSafely(String id) async {
  try {
    return userService.get(id);
  } on HiveServiceException catch (e) {
    // Log error and return null
    print('Failed to get user: ${e.message}');
    return null;
  }
}
```

### 4. **Use Query Methods Efficiently**
```dart
// Efficient: Use where() for filtering
List<UserModel> activeUsers = userService.where((user) => user.isActive);

// Efficient: Use firstWhere() for single results
UserModel? admin = userService.firstWhere((user) => user.role == 'admin');
```

## Migration from Old API

If you're migrating from the old HiveService API:

| Old Method | New Method |
|------------|------------|
| `addItem(key, item)` | `put(key, item)` |
| `deleteItem(key)` | `delete(key)` |
| `clearBox()` | `clear()` |
| `closeBox()` | `close()` |
| `isBoxOpen()` | `isOpen` |
| `getBoxSize()` | `length` |

## Performance Tips

1. **Batch Operations**: Use `addAll()` for multiple items
2. **Efficient Queries**: Use `where()` instead of filtering after `getAll()`
3. **Key Design**: Use meaningful, unique keys
4. **Memory Management**: Call `dispose()` when done with the service

## Example Projects

This service is designed to work across different project types:

- **E-commerce**: Product catalog, user preferences
- **Social Media**: User profiles, posts, messages
- **Task Management**: Tasks, projects, settings
- **Chat Applications**: Messages, conversations, user data

## Contributing

When extending this service for your projects:

1. Keep the core API consistent
2. Add new methods as extensions when possible
3. Maintain backward compatibility
4. Add comprehensive error handling
5. Include proper documentation

## License

This service is designed to be reusable across multiple projects. Feel free to adapt it to your specific needs while maintaining the core functionality and API design. 