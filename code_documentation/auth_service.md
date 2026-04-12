# AuthService Detailed Documentation

`AuthService` provides authentication and user management using Firebase Authentication and Firestore.

## Features
- Register new users with email, password, and optional username
- Sign in users with email and password
- Send password reset emails
- Sign out users
- Listen to authentication state changes
- Create user profile documents in Firestore

## API

### Methods

#### `Future<User?> signIn(String email, String password)`
Signs in a user using Firebase Authentication.
- **Parameters:**
  - `email`: User's email address
  - `password`: User's password
- **Returns:**
  - The signed-in `User` object, or `null` if sign-in fails

#### `Future<User?> register(String email, String password, {String? username})`
Registers a new user and creates a profile document in Firestore.
- **Parameters:**
  - `email`: User's email address
  - `password`: User's password
  - `username`: Optional display name
- **Returns:**
  - The created `User` object, or `null` if registration fails
- **Firestore:**
  - Creates a document in the `users` collection with the user's UID
  - Document fields:
    - `profile`: `{ displayName, age }`
    - `stats`: `{ totalGamesPlayed, totalPoints, currentStreak, lastPlayedAt }`
    - `settings`: `{}`

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
- Firestore document is created in the `users` collection with the user's UID as the document ID.
- Make sure your Firestore security rules allow authenticated users to write to the `users` collection.
- All methods are asynchronous and should be awaited.
