# AuthService Detailed Documentation

`AuthService` provides authentication and user management using Firebase Authentication and Firestore.

## Features
- Register new users with email, password, and username
- Sign in users with email and password
- Send password reset emails
- Sign out users
- Listen to authentication state changes
- Validate username uniqueness before registration

## API

### Methods

#### `Future<User?> signIn(String email, String password)`
Signs in a user using Firebase Authentication.
- **Parameters:**
  - `email`: User's email address
  - `password`: User's password
- **Returns:**
  - The signed-in `User` object, or `null` if sign-in fails

#### `Future<User?> register(String email, String password, String username)`
Registers a new user in Firebase Authentication.
- **Parameters:**
  - `email`: User's email address
  - `password`: User's password
  - `username`: Display name for the user
- **Returns:**
  - The created `User` object, or `null` if registration fails
- **Note:**
  - The user profile document in Firestore is automatically created by the `onUserCreate` cloud function when the user is registered
  - The cloud function creates: `users/{uid}` with profile, stats, and settings

#### `Future<void> sendPasswordReset(String email)`
Sends a password reset email to the specified address.
- **Parameters:**
  - `email`: User's email address

#### `Future<void> signOut()`
Signs out the current user.

#### `Stream<User?> get onAuthStateChanged`
Stream that emits the current user or `null` when the authentication state changes.
- Use this to react to login/logout events in your app.

## Usage Example
```dart
final authService = AuthService();

// Register a new user
final user = await authService.register('email@example.com', 'password123', username: 'John');

// Sign in
final user = await authService.signIn('email@example.com', 'password123');

// Listen to auth state changes
authService.onAuthStateChanged.listen((user) {
  if (user != null) {
    print('User is signed in: ${user.email}');
  } else {
    print('User is signed out');
  }
});

// Send password reset
await authService.sendPasswordReset('email@example.com');

// Sign out
await authService.signOut();
```

## Notes
- User profile document is automatically created in the `users` collection by the `onUserCreate` cloud function (see `functions/index.ts`)
- The cloud function is triggered automatically when a user registers via Firebase Authentication
- All methods are asynchronous and should be awaited
