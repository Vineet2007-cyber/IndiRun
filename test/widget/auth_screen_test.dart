import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indirun/core/localization/locale_provider.dart';
import 'package:indirun/core/theme/app_theme.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';
import 'package:indirun/data/repositories/repository_providers.dart';
import 'package:indirun/features/auth/presentation/auth_screen.dart';
import 'package:indirun/features/auth/presentation/choose_username_screen.dart';
import 'package:indirun/features/auth/presentation/forgot_password_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LoginScreen (S02)', () {
    testWidgets('renders branding and disables login button when inputs empty', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Brand text
      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('INDIRUN'), findsOneWidget);

      // Login button exists and is disabled
      final loginBtnFinder = find.widgetWithText(FilledButton, 'Login');
      expect(loginBtnFinder, findsOneWidget);
      final FilledButton loginBtn = tester.widget(loginBtnFinder);
      expect(loginBtn.onPressed, isNull);

      // Other elements
      expect(find.text('Login with Google'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
    });

    testWidgets('enables login button when username and password entered', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter username and password
      await tester.enterText(find.byType(TextField).first, 'runner');
      await tester.enterText(find.byType(TextField).last, 'Password123');
      await tester.pumpAndSettle();

      final loginBtnFinder = find.widgetWithText(FilledButton, 'Login');
      final FilledButton loginBtn = tester.widget(loginBtnFinder);
      expect(loginBtn.onPressed, isNotNull);
    });

    testWidgets('shows error on failed login attempt', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'runner');
      await tester.enterText(find.byType(TextField).last, 'wrong_pass');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password'), findsOneWidget);
    });
  });

  group('SignUpScreen (S03)', () {
    testWidgets('renders Create your account, Google CTA, and Privacy Callout', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Sign up with Google to get started'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(
        find.text('Google is only used to verify you. Your Google name is never shown.'),
        findsOneWidget,
      );
      expect(find.text('Already registered? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('ChooseUsernameScreen (S04)', () {
    testWidgets('validates username rules and calculates password strength', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ChooseUsernameScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('Pick your runner name'), findsOneWidget);

      // Enter invalid username with dot at beginning
      await tester.enterText(find.byType(TextField).at(0), '.invalid');
      await tester.pumpAndSettle();
      expect(find.text('Username cannot start with a dot'), findsOneWidget);

      // Enter valid available username
      await tester.enterText(find.byType(TextField).at(0), 'cool_runner_07');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Available. 3-20 characters: a-z 0-9 _ .'), findsOneWidget);

      // Password input updates strength
      await tester.enterText(find.byType(TextField).at(1), 'runner01');
      await tester.pumpAndSettle();
      expect(find.text('Medium: 8+ characters, 1 number'), findsOneWidget);

      // Mismatched confirm password
      await tester.enterText(find.byType(TextField).at(2), 'DifferentPassword');
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Continue button should still be disabled
      final continueBtnFinder = find.widgetWithText(FilledButton, 'Continue');
      final FilledButton continueBtn = tester.widget(continueBtnFinder);
      expect(continueBtn.onPressed, isNull);

      // Fix confirm password
      await tester.enterText(find.byType(TextField).at(2), 'runner01');
      await tester.pumpAndSettle();

      final FilledButton validBtn = tester.widget(continueBtnFinder);
      expect(validBtn.onPressed, isNotNull);
    });
  });

  group('ForgotPasswordScreen (S05 & S05b)', () {
    testWidgets('sends reset link and enters countdown state with masked email', (tester) async {
      final fakeRepo = InMemoryAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('Enter your username'), findsOneWidget);

      // Send button is disabled when empty
      final sendBtnFinder = find.widgetWithText(FilledButton, 'Send reset link');
      final FilledButton sendBtn = tester.widget(sendBtnFinder);
      expect(sendBtn.onPressed, isNull);

      // Enter username and send
      await tester.enterText(find.byType(TextField), 'runner');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Send reset link'));
      await tester.pumpAndSettle();

      // S05b State: Success banner and masked email
      expect(
        find.text('Check your inbox. Link expires in 30 minutes.'),
        findsOneWidget,
      );
      expect(find.text('Link sent to r***@indirun.app'), findsOneWidget);

      // Resend countdown button is shown
      expect(find.textContaining('Resend in'), findsOneWidget);
    });
  });
}
