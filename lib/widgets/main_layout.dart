import 'package:flutter/material.dart';
import 'package:jetcv__utenti/widgets/sidebar_menu.dart';
import 'package:jetcv__utenti/widgets/hamburger_button.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;
  final String? title;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    this.currentRoute,
    this.title,
    this.actions,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });

    if (_isSidebarOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeSidebar() {
    if (_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // App bar
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Hamburger button
                          HamburgerButton(
                            onPressed: _toggleSidebar,
                            isOpen: _isSidebarOpen,
                          ),
                          const SizedBox(width: 16),
                          // Title
                          if (widget.title != null) ...[
                            Expanded(
                              child: Text(
                                widget.title!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ] else ...[
                            const Spacer(),
                          ],
                          // Actions
                          if (widget.actions != null) ...[
                            ...widget.actions!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),

          // Sidebar overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const SizedBox.expand(),
              ),
            ),

          // Sidebar
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: -280 + (280 * _animation.value),
                top: 0,
                bottom: 0,
                child: SidebarMenu(
                  onClose: _closeSidebar,
                  currentRoute: widget.currentRoute,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
