/// Constants for responsive design across the application
class ResponsiveConstants {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  // Max widths for different components
  static const double maxFormWidth = 480;
  static const double maxButtonWidth = 400;
  static const double maxCardWidth = 600;
  static const double maxContentWidth = 800;
  static const double maxDialogWidth = 500;

  // Padding and margins
  static const double defaultPadding = 24;
  static const double mobilePadding = 16;
  static const double desktopPadding = 32;

  // Helper methods
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isTablet(double width) =>
      width >= mobileBreakpoint && width < desktopBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;

  static double getResponsivePadding(double screenWidth) {
    if (isMobile(screenWidth)) return mobilePadding;
    if (isTablet(screenWidth)) return defaultPadding;
    return desktopPadding;
  }

  static double getFormWidth(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth - (mobilePadding * 2);
    return maxFormWidth;
  }

  static double getButtonWidth(double screenWidth) {
    if (isMobile(screenWidth)) return double.infinity;
    return maxButtonWidth;
  }

  static double getCardWidth(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth - (mobilePadding * 2);
    return maxCardWidth;
  }

  static double getContentWidth(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth - (mobilePadding * 2);
    return maxContentWidth;
  }
}
