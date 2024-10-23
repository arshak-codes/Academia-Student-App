import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:new_project/routes.dart';
import 'package:new_project/screens/splash_screen/splash_screen.dart';
import 'package:new_project/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(); // Initialize Firebase
  } catch (e) {
    // Print or log the error
    print("Firebase initialization error: $e");
    // Optionally, you can show a simple error message to the user
    // or navigate to an error screen
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // It requires 3 parameters: context, orientation, device.
    return Sizer(builder: (context, orientation, device) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Brain',
        theme: CustomTheme().baseTheme,
        // Initial route is splash screen (means first screen).
        initialRoute: SplashScreen.routeName,
        // Define the routes file here in order to access the routes anywhere in the app.
        routes: routes,
      );
    });
  }
}
