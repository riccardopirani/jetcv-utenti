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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive sizing
    final appBarHeight = isMobile
        ? 56.0
        : isTablet
            ? 60.0
            : 64.0;
    final horizontalPadding = isMobile
        ? 12.0
        : isTablet
            ? 16.0
            : 24.0;
    final titleFontSize = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final sidebarWidth = isMobile
        ? 280.0
        : isTablet
            ? 300.0
            : 320.0;

    // Desktop: sidebar always visible, mobile/tablet: overlay
    final showSidebarOverlay = isMobile || isTablet;
    final sidebarAlwaysVisible = isDesktop;

    return Scaffold(
      body: Row(
        children: [
          // Desktop: Always visible sidebar
          if (isDesktop) ...[
            Container(
              width: sidebarWidth,
              color: Colors.white,
              child: SidebarMenu(
                onClose: _closeSidebar,
                currentRoute: widget.currentRoute,
              ),
            ),
          ],

          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Main content
                Container(
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      // App bar
                      Container(
                        height: appBarHeight,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Row(
                              children: [
                                // Hamburger button (only on mobile/tablet)
                                if (!isDesktop) ...[
                                  HamburgerButton(
                                    onPressed: _toggleSidebar,
                                    isOpen: _isSidebarOpen,
                                  ),
                                  SizedBox(width: isMobile ? 12 : 16),
                                ],
                                // Title
                                if (widget.title != null) ...[
                                  Expanded(
                                    child: Text(
                                      widget.title!,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
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

                // Mobile/Tablet: Sidebar overlay
                if (showSidebarOverlay && _isSidebarOpen)
                  GestureDetector(
                    onTap: _closeSidebar,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const SizedBox.expand(),
                    ),
                  ),

                // Mobile/Tablet: Animated sidebar
                if (showSidebarOverlay)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: -sidebarWidth + (sidebarWidth * _animation.value),
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
          ),
        ],
      ),
    );
  }
}
