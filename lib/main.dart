import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_live_score_app/screens/add_new_match.dart';
import 'package:firebase_live_score_app/screens/home_screen.dart';
import 'package:firebase_live_score_app/screens/sign_in_screen.dart';
import 'package:firebase_live_score_app/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // Ensure the initialization of application engine
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LiveScoreApp());
}

class LiveScoreApp extends StatelessWidget {
  const LiveScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, asyncSnapshot) {
        return MaterialApp(
          home: AuthGate(),
          debugShowCheckedModeBanner: false,

          routes: {
            '/sign-in': (_) => SignInScreen(),
            '/sign-up': (_) => SignUpScreen(),
            '/home': (_) => HomeScreen(),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen();
        }
        return HomeScreen();
      },
    );
  }
}
