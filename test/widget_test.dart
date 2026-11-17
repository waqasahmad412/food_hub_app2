import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/auth/signup_screen.dart';

/// Pumps [home] inside a MaterialApp that has the same named routes as the
/// real app, on a large test surface so nothing is off-screen.
Future<void> _pumpAuthApp(WidgetTester tester, {required Widget home}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: home,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    ),
  );
}

void main() {
  testWidgets('App starts on the login screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FoodDashApp());

    expect(find.text('FoodDash'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login screen shows validation errors when submitted empty',
      (WidgetTester tester) async {
    await _pumpAuthApp(tester, home: const LoginScreen());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Login screen navigates to the sign-up screen',
      (WidgetTester tester) async {
    await _pumpAuthApp(tester, home: const LoginScreen());

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // The sign-up screen shows the Full Name field and a Create Account
    // button ("Create Account" appears twice: heading + button, so we match
    // the button widget itself).
    expect(find.text('Full Name'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Create Account'),
      findsOneWidget,
    );
  });

  testWidgets('Sign-up screen shows an error when passwords do not match',
      (WidgetTester tester) async {
    await _pumpAuthApp(tester, home: const SignupScreen());

    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.enterText(find.byType(TextFormField).at(3), 'secret456');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Sign-up screen navigates back to the login screen',
      (WidgetTester tester) async {
    await _pumpAuthApp(tester, home: const SignupScreen());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome Back'), findsOneWidget);
  });
}
