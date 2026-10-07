import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Auth_provider.dart';
import 'Forget_screen.dart';
import 'HomeScreen.dart';
import 'Login_Screen.dart';
import 'Register_Screen.dart';
import 'Spalsh_Screen.dart';
import 'add_edit_note_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'My Notes App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        // Route Helper Setup
        routes: {
          AppRoutes.login: (context) => const login_screen(),
          AppRoutes.register: (context) => const Register_screen(),
          AppRoutes.forgetPassword: (context) => const ForgetScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.addEditNote: (context) => const AddEditNoteScreen(),
        },
        home: const AuthGate(),
      ),
    );
  }
}

/// Helper class for central named routes
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';
  static const String home = '/home';
  static const String addEditNote = '/add-edit-note';
}

/// AuthGate routes user automatically depending on authentication state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return StreamBuilder(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        // Show Splash/Loading screen while checking Firebase Auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const splash_screen();
        }

        // User is logged in -> route to HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // User is not logged in -> route to LoginScreen
        return const login_screen();
      },
    );
  }
}
