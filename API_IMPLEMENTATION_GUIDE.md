# Professional API Integration Guide

## Architecture Overview

Your app uses a **layered architecture** for clean, maintainable API integration:

```
┌─────────────────────────────────────┐
│     UI Layer (Widgets/Pages)        │  Displays data to user
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Controller/State Management       │  Business logic with GetX
│    (GetX Controllers)                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Repository Pattern                │  Data access abstraction
│    (UserRepository, etc)             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    API Client                        │  HTTP requests + interceptors
│    (Dio with auth, logging)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    REST APIs / Firebase              │  Backend services
└─────────────────────────────────────┘
```

## Setup Instructions

### Step 1: Add Dependencies to `pubspec.yaml`

```yaml
dependencies:
  dio: ^5.0.0  # HTTP client
  get: ^4.7.3  # State management
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

### Step 2: Initialize in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase initialization ...

  // Initialize API services
  await ApiServiceProvider.initialize();

  runApp(/*...*/);
}
```

### Step 3: Use in Controllers

```dart
import 'package:get/get.dart';
import 'package:gym_trainer/infrastructure/api/repositories.dart';

class UserProfileController extends GetxController {
  final _userRepo = Get.find<UserRepository>();
  
  final isLoading = false.obs;
  final profile = Rxn<UserProfileDto>();
  final error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading(true);
    error('');
    
    try {
      final response = await _userRepo.getProfile();
      
      if (response.success && response.data != null) {
        profile.value = response.data;
      } else {
        error.value = response.error ?? 'Failed to load profile';
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('Error fetching profile: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfile({
    required String name,
    String? bio,
  }) async {
    isLoading(true);
    
    try {
      final request = UpdateProfileRequest(
        name: name,
        bio: bio,
      );
      
      final response = await _userRepo.updateProfile(request);
      
      if (response.success) {
        profile.value = response.data;
        Get.snackbar('Success', 'Profile updated');
      } else {
        Get.snackbar('Error', response.error ?? 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
```

### Step 4: Use in Views

```dart
class ProfileView extends GetView<UserProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text('Error: ${controller.error.value}'),
          );
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(child: Text('No profile found'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(profile.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(profile.email),
            if (profile.photoUrl != null)
              Image.network(profile.photoUrl!),
            ElevatedButton(
              onPressed: () {
                controller.updateProfile(name: 'New Name');
              },
              child: const Text('Update Profile'),
            ),
          ],
        );
      }),
    );
  }
}
```

## API Endpoints to Implement

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout
- `POST /auth/refresh-token` - Refresh auth token

### Users
- `GET /users/profile` - Get current user profile
- `PUT /users/profile` - Update user profile
- `GET /users/search` - Search users (with pagination)

### Trainers
- `GET /trainers` - Get all trainers (with filters)
- `GET /trainers/search` - Search trainers
- `POST /trainers/applications` - Apply to be trainer
- `GET /trainers/availability/{id}` - Get trainer availability

### Bookings
- `POST /bookings` - Create new booking
- `GET /bookings` - Get user's bookings
- `DELETE /bookings/{id}/cancel` - Cancel booking
- `GET /bookings/{id}` - Get booking details

### Admin
- `GET /admin/users` - List/search users (admin only)
- `GET /admin/applications` - List trainer applications
- `POST /admin/applications/{id}/approve` - Approve trainer
- `GET /admin/analytics` - Get analytics data

## Error Handling

The API client includes automatic error handling:

```dart
// Errors are caught and wrapped in ApiResponse
final response = await userRepo.getProfile();

if (!response.success) {
  print('Error: ${response.error}');
  // Handle error
}
```

**Error types automatically handled:**
- `ApiException` - Custom API errors (4xx, 5xx)
- `DioException` - Network errors, timeouts
- Authentication errors (401) - Automatically triggers logout
- Connection timeouts
- Server errors (5xx)

## Logging

API requests/responses are logged in debug mode:

```
📤 [API] GET /users/profile
📥 [API] 200 /users/profile
```

Disable logging by removing `_LoggingInterceptor` from `ApiClient`.

## Best Practices

✅ **DO:**
- Use repositories for all API calls
- Return `ApiResponse<T>` from repositories
- Handle errors gracefully in UI
- Use strong typing with DTOs
- Cache responses when appropriate
- Implement pagination for list endpoints

❌ **DON'T:**
- Call `ApiClient` directly from UI
- Ignore errors without user feedback
- Make async calls without proper state management
- Mix API and business logic
- Hard-code URLs (use `ApiConstants`)

## Testing API Endpoints

```dart
void main() {
  test('Get user profile', () async {
    final repo = UserRepository(mockApiClient);
    final response = await repo.getProfile();
    
    expect(response.success, true);
    expect(response.data?.name, isNotEmpty);
  });
}
```

## Next Steps

1. **Create backend API** (Node.js, Django, Go, etc.)
2. **Update BaseUrl** in `api_client.dart`
3. **Add more repositories** as needed
4. **Implement RTK Query or similar** for caching (optional)
5. **Add offline support** with local database
6. **Set up API versioning** for future updates

