import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_live_score_app/home_screen.dart';
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
    return const MaterialApp(home: HomeScreen());
  }
}
