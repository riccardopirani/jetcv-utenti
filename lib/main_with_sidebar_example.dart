import 'package:flutter/material.dart';
import 'package:jetcv__utenti/screens/home/home_page.dart';
import 'package:jetcv__utenti/screens/cv/cv_view_page.dart';
import 'package:jetcv__utenti/screens/otp/otp_page.dart';

void main() {
  runApp(const MyAppWithSidebar());
}

class MyAppWithSidebar extends StatelessWidget {
  const MyAppWithSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jet CV with Sidebar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/cv': (context) => const CVViewPage(),
        '/otp': (context) => const OTPPage(),
        // Add more routes as needed
      },
    );
  }
}
