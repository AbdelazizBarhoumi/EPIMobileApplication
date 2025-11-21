# EPI Student App - Frontend Architecture

## 🏗️ Architecture Overview

This Flutter application follows a **Clean Architecture** pattern with **Feature-Driven Development** approach, ensuring scalability, maintainability, and testability.

## 📁 Project Structure

```
lib/
├── core/                          # Shared code across features
│   ├── api_client.dart           # HTTP client with interceptors
│   ├── constants/                # App-wide constants
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── controllers/              # Legacy controllers (being migrated)
│   ├── models/                   # Data models with serialization
│   │   ├── student.dart
│   │   ├── course.dart
│   │   ├── grade.dart
│   │   ├── attendance.dart
│   │   └── bill.dart
│   ├── providers/                # Dependency injection
│   │   └── api_provider.dart
│   ├── repositories/             # Data access layer
│   │   ├── base_repository.dart
│   │   └── student_repository.dart
│   ├── services/                 # Business logic services
│   ├── storage.dart              # Secure storage utilities
│   └── utils/                    # Helper utilities
│       ├── date_formatter.dart
│       └── number_formatter.dart
├── features/                     # Feature-based modules
│   ├── auth/                     # Authentication feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       └── controllers/
│   └── profile/                  # Profile management feature
│       ├── data/
│       └── presentation/
├── routes/                       # Navigation configuration
│   └── app_routes.dart
├── shared/                       # Shared UI components
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── error_view.dart
│       └── loading_indicator.dart
├── pages/                        # UI pages (being migrated to features)
├── widgets/                      # Shared widgets (being migrated to shared/)
└── main.dart                     # App entry point
```

## 🏛️ Architecture Principles

### 1. **Separation of Concerns**
- **Presentation Layer**: UI components, state management
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Repositories, API clients, data sources

### 2. **Dependency Inversion**
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Dependency injection via Provider

### 3. **Single Responsibility**
- Each class has one reason to change
- Models handle data serialization
- Repositories handle data access
- Controllers handle UI state

## 🔧 Core Components

### API Client (`core/api_client.dart`)
```dart
class ApiClient {
  Future<Map<String, dynamic>> get(String path);
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>> delete(String path);
}
```
- Handles HTTP requests with automatic token management
- Auto-logout on 401 responses
- Timeout and error handling

### Models (`core/models/`)
- Data classes with `fromJson()` and `toJson()` methods
- Immutable with required parameters
- Business logic methods (e.g., GPA calculation)

### Repositories (`core/repositories/`)
- Abstract data access from business logic
- Handle API calls and data transformation
- Can be easily mocked for testing

### Controllers (`features/*/presentation/controllers/`)
- Manage UI state using ChangeNotifier
- Handle loading, error, and success states
- Communicate with repositories

### Services (`core/services/`)
- Business logic operations
- Transform data between layers
- Can combine multiple repository calls

## 🎯 Feature Structure

Each feature follows this structure:
```
features/
└── feature_name/
    ├── data/
    │   ├── models/           # Feature-specific models
    │   └── repositories/     # Data access
    └── presentation/
        ├── controllers/      # State management
        ├── pages/           # UI screens
        └── widgets/         # Feature-specific widgets
```

## 🚀 Best Practices Implemented

### 1. **State Management**
- Provider for dependency injection
- ChangeNotifier for reactive UI updates
- Separate business state from UI state

### 2. **Error Handling**
- Centralized error parsing
- User-friendly error messages
- Retry mechanisms

### 3. **Security**
- JWT token management
- Secure storage for sensitive data
- Input validation

### 4. **Performance**
- Efficient list rendering
- Image caching
- Lazy loading where applicable

### 5. **Testing**
- Dependency injection enables easy mocking
- Separated business logic for unit testing
- Widget testing support

### 6. **Code Quality**
- Consistent naming conventions
- Documentation comments
- Type safety with Dart

## 🔄 Migration Strategy

The app is gradually migrating from a monolithic structure to feature-based:

1. ✅ **Completed**: Core infrastructure (API client, models, repositories)
2. 🔄 **In Progress**: Feature extraction (auth, profile)
3. 📋 **Planned**: Migrate remaining pages to features
4. 🎯 **Future**: Add unit tests, integration tests

## 📱 Usage Examples

### Using a Repository
```dart
final repository = context.read<StudentRepository>();
final student = await repository.getProfile();
```

### Using a Controller
```dart
final controller = context.watch<ProfileController>();
if (controller.state == ProfileState.loading) {
  return LoadingIndicator();
}
```

### Navigation
```dart
AppRoutes.navigateTo(context, AppRoutes.profile);
```

## 🛠️ Development Guidelines

1. **New Features**: Create under `features/` with data/presentation separation
2. **Models**: Always add `fromJson()` and `toJson()` methods
3. **Error Handling**: Use try-catch with user-friendly messages
4. **State Management**: Prefer controllers over setState for complex state
5. **Testing**: Write tests for repositories and controllers first

## 📋 TODO

- [ ] Add unit tests for all repositories
- [ ] Implement caching layer
- [ ] Add offline support
- [ ] Migrate all pages to features
- [ ] Add integration tests
- [ ] Implement push notifications
- [ ] Add analytics tracking

---

This architecture ensures the app remains maintainable and scalable as it grows in complexity and user base.
