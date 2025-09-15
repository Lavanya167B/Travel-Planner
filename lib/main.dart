import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/explore.dart';
import 'screens/weather_page.dart'; // ✅ Import WeatherPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(TravelPlannerApp());
}

class TravelPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Planner',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: AuthWrapper(),
      routes: {
        '/home': (context) => HomePage(),
        '/explore': (context) => ExplorePage(),
        '/weather': (context) => WeatherPage(), // ✅ Added route
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If the user is logged in, show HomePage
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }

        // Otherwise, show LoginPage
        return LoginPage();
      },
    );
  }
}
