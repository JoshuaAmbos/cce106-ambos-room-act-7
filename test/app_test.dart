import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambos_room7/main.dart';
import 'package:ambos_room7/demo_auth.dart';

void main() {
  setUp(() {
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  Finder navTab(String label) {
    return find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );
  }

  void setLargeScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Test 1: App starts on Login screen', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('Test 2: Submit empty login fields shows validation errors', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('Test 3: Incorrect credentials are rejected', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'wronguser');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('Test 4 & 5: Login with admin / admin123 opens Dashboard with greeting', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, admin!'), findsOneWidget);
  });

  testWidgets('Test 6 & 7: Calculator operations and state preservation across tab switches', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Navigate to Calculator tab via NavigationBar
    await tester.tap(navTab('Calculator'));
    await tester.pumpAndSettle();

    // Enter 10 and 5
    await tester.enterText(find.widgetWithText(TextField, 'First Number'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Second Number'), '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pumpAndSettle();

    expect(find.text('15.0'), findsOneWidget);

    // Switch to Dashboard tab and back to Calculator tab
    await tester.tap(navTab('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(navTab('Calculator'));
    await tester.pumpAndSettle();

    // Verify inputs and result remain
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('Test 8, 9, 10: Social create post, like, comment, and state preservation', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Navigate to Social tab
    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    // Tap floating action button to create post
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter caption and image URL
    await tester.enterText(find.widgetWithText(TextField, 'Caption'), 'Hello world from admin');
    await tester.enterText(find.widgetWithText(TextField, 'Image URL'), 'https://picsum.photos/200');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post created with admin username
    expect(find.text('Hello world from admin'), findsOneWidget);
    expect(find.text('admin'), findsWidgets);

    // Like post
    await tester.tap(find.text('Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    // Add a comment
    await tester.enterText(find.widgetWithText(TextField, 'Add a comment...').first, 'Great post!');
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pumpAndSettle();
    expect(find.text('Great post!'), findsOneWidget);

    // Switch tabs to Profile and back to Social
    await tester.tap(navTab('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Student Profile'), findsOneWidget);

    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    // Verify post, like, and comment are preserved
    expect(find.text('Hello world from admin'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Great post!'), findsOneWidget);
  });

  testWidgets('Test 11 & 12: Profile details and Logout', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Navigate to Profile tab
    await tester.tap(navTab('Profile'));
    await tester.pumpAndSettle();

    // Verify profile info
    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('Joshua Ambos'), findsOneWidget);
    expect(find.text('Logged in as: admin'), findsOneWidget);
    expect(find.text('554298'), findsOneWidget);

    // Tap Logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify back to Login screen
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);
  });

  testWidgets('Test 13 & 14: Register a valid account, login, verify dashboard & social post', (WidgetTester tester) async {
    setLargeScreen(tester);
    await tester.pumpWidget(const StudentApp());

    // Navigate to Register
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an Account'), findsOneWidget);

    // Fill registration form
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'joshua123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Returns to Login
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Registration successful! You can now log in.'), findsOneWidget);

    // Wait for SnackBar timer to dismiss cleanly
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Login with new account
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'joshua123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify Dashboard greeting
    expect(find.text('Welcome, joshua123!'), findsOneWidget);

    // Navigate to Social tab
    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    // Create a post
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Caption'), 'New account post');
    await tester.enterText(find.widgetWithText(TextField, 'Image URL'), 'https://picsum.photos/300');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post created with registered username
    expect(find.text('New account post'), findsOneWidget);
    expect(find.text('joshua123'), findsWidgets);
  });
}
