import 'package:flutter/material.dart';

void main() {
  runApp(const InstaGoalsApp());
}

class InstaGoalsApp extends StatelessWidget {
  const InstaGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Goals',
      debugShowCheckedModeBanner: false,
      home: const GoalsScreen(),
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Light gradient colors
    const Color gradientStart = Color(0xFFEDE7F6); // lavender
    const Color gradientEnd = Color(0xFFB3E5FC); // light blue

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Optional: Instagram logo at the top
                // Image.asset('assets/instagram_logo.png', height: 74),
                // const SizedBox(height: 24),
                Text(
                  'BC phir instagram per a gya.\n'
                      'Goals Achive krliye.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    shadows: [
                      Shadow(
                        color: Colors.white54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      GoalText(number: 1, text: "Build a Startup"),
                      GoalText(number: 2, text: "CGPA Above 3.5"),
                      GoalText(number: 3, text: "Earning Above 100k"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoalText extends StatelessWidget {
  final int number;
  final String text;

  const GoalText({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Text(
        '$number- $text',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFF444444),
        ),
      ),
    );
  }
}