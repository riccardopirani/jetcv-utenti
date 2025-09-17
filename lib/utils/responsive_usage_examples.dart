import 'package:flutter/material.dart';
import 'package:jetcv__utenti/widgets/responsive_widgets.dart';

/// Examples of how to use the responsive system
///
/// This file contains usage examples for the responsive design system.
/// It's not meant to be used in production, but as a reference guide.
class ResponsiveUsageExamples extends StatelessWidget {
  const ResponsiveUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Design Examples'),
      ),
      body: ResponsivePageWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Form with responsive container
            const Text(
              'Example 1: Responsive Form',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResponsiveFormContainer(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Example 2: Responsive buttons
            const Text(
              'Example 2: Responsive Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResponsiveButton.elevated(
              onPressed: () {},
              child: const Text('Primary Action'),
            ),
            const SizedBox(height: 8),
            ResponsiveButton.outlined(
              onPressed: () {},
              child: const Text('Secondary Action'),
            ),

            const SizedBox(height: 32),

            // Example 3: Responsive card
            const Text(
              'Example 3: Responsive Card',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This card automatically adjusts its width based on screen size. '
                    'On mobile it takes full width minus padding, on desktop it has a maximum width.',
                  ),
                  const SizedBox(height: 16),
                  ResponsiveButton.elevated(
                    onPressed: () {},
                    child: const Text('Action'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Example 4: Custom responsive container
            const Text(
              'Example 4: Custom Responsive Container',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResponsiveContainer(
              maxWidth: 300, // Custom max width
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'This container has a custom maximum width of 300px '
                  'and is centered on larger screens.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Usage Notes:
///
/// 1. ResponsivePageWrapper: Use as the main body wrapper for pages
///    - Automatically handles SafeArea and ScrollView
///    - Applies responsive padding
///
/// 2. ResponsiveFormContainer: Use for forms and input sections
///    - Max width of 480px on desktop
///    - Full width on mobile with appropriate padding
///
/// 3. ResponsiveButton: Use for all buttons
///    - .elevated() for primary buttons
///    - .outlined() for secondary buttons
///    - Full width on mobile, max 400px centered on desktop
///
/// 4. ResponsiveCard: Use for card-like content
///    - Max width of 600px on desktop
///    - Full width on mobile
///
/// 5. ResponsiveContainer: Use for custom responsive containers
///    - Configurable max width
///    - Automatic centering on larger screens
///
/// 6. ResponsiveSpacing: Use for responsive spacing between elements
///    - Different spacing values for mobile vs desktop
///
/// Breakpoints:
/// - Mobile: < 768px
/// - Tablet: 768px - 1199px
/// - Desktop: >= 1200px
///
/// The system automatically detects screen size and applies appropriate
/// constraints and styling.
