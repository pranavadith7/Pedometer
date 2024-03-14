import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
// import 'home.dart';

Future<void> main() async {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const Home(username: "admin",), // Set the initial home page
      home: const Login(),
      theme: ThemeData(
        textTheme: const TextTheme(
                bodyLarge: TextStyle(),
                bodyMedium: TextStyle(),
                bodySmall: TextStyle())
            .apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      routes: {
        '/login': (context) =>
            const Login(), // Define routes, including the home page
      },
    );
  }
}
