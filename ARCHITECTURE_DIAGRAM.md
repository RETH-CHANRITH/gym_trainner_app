# 🏗️ Professional API Architecture Diagram

## Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER INTERFACE LAYER                        │
│                    (Widgets / Pages / UI)                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  UserProfileView, TrainersListView, BookingView, etc.     │ │
│  └───────────────────┬────────────────────────────────────────┘ │
└──────────────────────┼───────────────────────────────────────────┘
                       │ Uses Obx() for reactive updates
                       │
┌──────────────────────▼───────────────────────────────────────────┐
│              STATE MANAGEMENT LAYER (GetX)                       │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────┐ │
│  │  UserController │  │TrainerController│  │BookingController │ │
│  │                 │  │                 │  │                  │ │
│  │ - onReady()     │  │ - fetchTrainers()│ │- createBooking() │ │
│  │ - getProfile()  │  │ - applyFilters() │ │- getBookings()   │ │
│  │ - updateUser()  │  │ - loadMore()    │ │- cancelBooking() │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬─────────┘ │
│           │                    │                     │            │
│           └────────────────────┼─────────────────────┘            │
│                                │                                  │
│                    Get.find<Repository>()                         │
└────────────────────────────────┼──────────────────────────────────┘
                                 │
┌────────────────────────────────▼──────────────────────────────────┐
│           REPOSITORY LAYER (Data Access)                          │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │ UserRepository   │  │TrainerRepository │  │BookingRepository│  │
│  │                  │  │                  │  │                │  │
│  │ - getProfile()   │  │ - getTrainers()  │  │- createBooking()│ │
│  │ - updateProfile()│  │ - searchTrainers()│  │- getBookings() │  │
│  │ - searchUsers()  │  │ - getAvailability()│ │- cancelBooking()│ │
│  │ - applyAsTrainer()│ │                  │  │                │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬───────┘  │
│           │                     │                      │           │
│           └─────────────────────┼──────────────────────┘           │
│                                 │                                  │
│               _apiClient.get(), .post(), .put(), .delete()        │
└────────────────────────────────┼──────────────────────────────────┘
                                 │
┌────────────────────────────────▼──────────────────────────────────┐
│                    API CLIENT LAYER (Dio)                         │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    ApiClient (Dio)                          │ │
│  │                                                              │ │
│  │  Methods:                                                    │ │
│  │  📤 get()    - HTTP GET                                      │ │
│  │  📦 post()   - HTTP POST                                     │ │
│  │  ✏️  put()    - HTTP PUT                                      │ │
│  │  🗑️  delete() - HTTP DELETE                                  │ │
│  │                                                              │ │
│  │  Interceptors:                                              │ │
│  │  🔐 _AuthInterceptor()   - Injects Firebase ID token        │ │
│  │  📝 _LoggingInterceptor() - Logs all requests/responses     │ │
│  │  ⚠️  _ErrorInterceptor()  - Handles global errors           │ │
│  └──────────────────────┬───────────────────────────────────────┘ │
│                         │                                          │
│      Response handling, error wrapping, retry logic                │
│      Returns: ApiResponse<T> or throws ApiException                │
└────────────────────────┼──────────────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                   BACKEND LAYER                                   │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │ Cloud Functions/ │  │  Firebase Auth   │  │   Firestore    │  │
│  │ Custom API       │  │                  │  │                │  │
│  └──────────────────┘  └──────────────────┘  └────────────────┘  │
│                                                                    │
│  Handles:                                                          │
│  - Request validation                                              │
│  - Business logic                                                  │
│  - Database operations                                             │
│  - Response formatting                                             │
└────────────────────────────────────────────────────────────────────┘
```

---

## Response Flow Example

```
User clicks "Get Profile" button
        ↓
UserProfileView 
        ↓
controller.getProfile() 
        ↓
Get.find<UserRepository>()
        ↓
userRepo.getProfile()
        ↓
_apiClient.get(ApiConstants.usersProfile)
        ↓
[ApiClient adds Firebase token via interceptor]
        ↓
[Logs request]
        ↓
HTTP GET → https://backend.com/api/v1/users/profile
        ↓
Backend validates auth → fetches user → sends JSON
        ↓
[Logs response]
        ↓
ApiResponse<Map>.fromJson() → UserProfileDto
        ↓
repository.getProfile() returns ApiResponse<UserProfileDto>
        ↓
controller.profile.value = response.data
        ↓
Obx() rebuilds view with new profile data
        ↓
User sees updated profile on screen
```

---

## Error Handling Flow

```
API Request
        ↓
   Success? ─── YES ─→ Return ApiResponse(success: true, data: T)
        │
       NO
        │
   Error Type?
        │
        ├─→ Network Error (no internet)
        │   └─→ ApiException("Network error. Please check your connection")
        │
        ├─→ Timeout
        │   └─→ ApiException("Request timeout. Please try again")
        │
        ├─→ 401 Unauthorized
        │   ├─→ [Trigger global logout]
        │   └─→ ApiException("Unauthorized access")
        │
        ├─→ 400 Bad Request
        │   └─→ Parse error message from response
        │       └─→ ApiException(error.message)
        │
        └─→ 500 Server Error
            └─→ ApiException("HTTP 500: Internal Server Error")
                    ↓
            Controller catches error
                    ↓
            Show Get.snackbar('Error', message)
```

---

## Type Safety Example

```dart
// WITHOUT type safety (❌ Bad)
final response = await apiClient.get('/users/profile');
final name = response['users'][0]['name']; // Could be null, wrong type

// WITH type safety (✅ Good)
final response = await userRepo.getProfile();

if (response.success && response.data != null) {
  final profile = response.data; // Guaranteed UserProfileDto
  final name = profile.name;      // String - always safe
}
```

---

## Dependency Injection Tree

```
main.dart
  │
  └─→ ApiServiceProvider.initialize()
      │
      ├─→ Get.put<ApiClient>(ApiClient(...))
      │   │
      │   └─→ Dio + Interceptors
      │
      ├─→ Get.put<UserRepository>(UserRepository(apiClient))
      ├─→ Get.put<TrainerRepository>(TrainerRepository(apiClient))
      └─→ Get.put<BookingRepository>(BookingRepository(apiClient))

Controllers
  │
  └─→ Get.find<UserRepository>()  // Retrieve from DI container
      │
      └─→ Access ApiClient through repository
```

---

## File Organization

```
lib/
├── infrastructure/          # Technical layer
│   └── api/                # API integration
│       ├── api_client.dart         # HTTP client + interceptors
│       ├── api_models.dart         # DTOs + response envelopes
│       ├── api_provider.dart       # GetX service provider
│       └── repositories.dart       # Data access layer
│
├── app/                    # Application layer
│   └── modules/            # Feature modules
│       ├── home/
│       │   └── controllers/home_controller.dart
│       ├── trainers/
│       │   └── controllers/trainers_controller.dart
│       └── bookings/
│           └── controllers/bookings_controller.dart
│
└── main.dart              # Entry point

Documentation/
├── API_IMPLEMENTATION_GUIDE.md    # Full guide (detailed)
└── QUICK_START_API.md             # Quick start (simple)
```

---

## Key Principles

🎯 **Single Responsibility**
- ApiClient: Only HTTP communication
- Repository: Only data access
- Controller: Only business logic
- View: Only UI display

🔒 **Type Safety**
- Use DTOs for all responses
- Strong typing with generics: `ApiResponse<T>`
- Null coalescing with `.value ??`

🛡️ **Error Handling**
- All errors wrapped in ApiException
- Controllers catch and display errors
- Users always see error messages

🔄 **Reactive Programming**
- GetX for state management
- Obx() for automatic rebuilds
- RxValues for reactive variables

📝 **Logging**
- All requests logged in debug
- Response codes and timing
- Easy to debug in DevTools

---

## Performance Tips

✅ **DO:**
- Paginate list endpoints (use `limit` + cursors)
- Cache frequently accessed data
- Use `lazy` loading for heavy widgets
- Dispose controllers properly
- Implement network retry logic

❌ **DON'T:**
- Make API calls in `build()` method
- Fetch all data at once (paginate instead)
- Make requests without loading indicators
- Ignore errors silently
- Make multiple duplicate requests

---

## Next Steps

1. ✅ **API Architecture** - DONE
2. ⏳ **Backend Implementation** - Create REST APIs
3. ⏳ **Endpoint Integration** - Wire controllers to repositories
4. ⏳ **Offline Support** - Add local database caching
5. ⏳ **API Testing** - Unit & integration tests
6. ⏳ **Monitoring** - Error tracking & analytics

---

## Resources

- 📖 Dio Documentation: https://pub.dev/packages/dio
- 📖 GetX Documentation: https://pub.dev/packages/get
- 🎯 REST API Best Practices: https://restfulapi.net/
- 🔐 Firebase Auth: https://firebase.google.com/docs/auth

---

**You now have a production-ready API architecture! 🚀**
