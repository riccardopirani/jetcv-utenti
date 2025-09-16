import 'package:flutter/material.dart';
import 'package:jetcv__utenti/utils/responsive_constants.dart';

/// A container that automatically adjusts its width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool centerHorizontally;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.centerHorizontally = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding =
        ResponsiveConstants.getResponsivePadding(screenWidth);

    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? EdgeInsets.symmetric(horizontal: responsivePadding),
      child: centerHorizontally
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth ?? ResponsiveConstants.maxContentWidth,
                ),
                child: child,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? ResponsiveConstants.maxContentWidth,
              ),
              child: child,
            ),
    );
  }
}

/// A form container with responsive width constraints
class ResponsiveFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveFormContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = ResponsiveConstants.getFormWidth(screenWidth);

    return ResponsiveContainer(
      maxWidth: formWidth,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}

/// A button with responsive width constraints
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isElevated;
  final bool isOutlined;
  final double? maxWidth;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isElevated = true,
    this.isOutlined = false,
    this.maxWidth,
  });

  const ResponsiveButton.elevated({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.maxWidth,
  })  : isElevated = true,
        isOutlined = false;

  const ResponsiveButton.outlined({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.maxWidth,
  })  : isElevated = false,
        isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        maxWidth ?? ResponsiveConstants.getButtonWidth(screenWidth);

    Widget button;

    if (isOutlined) {
      button = OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }

    if (ResponsiveConstants.isMobile(screenWidth)) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return Center(
      child: SizedBox(
        width: buttonWidth,
        child: button,
      ),
    );
  }
}

/// A card with responsive width constraints
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = ResponsiveConstants.getCardWidth(screenWidth);

    return ResponsiveContainer(
      maxWidth: cardWidth,
      padding: EdgeInsets.zero,
      margin: margin,
      child: Card(
        color: color,
        elevation: elevation,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

/// A responsive wrapper for page content
class ResponsivePageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasAppBar;

  const ResponsivePageWrapper({
    super.key,
    required this.child,
    this.padding,
    this.hasAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding =
        ResponsiveConstants.getResponsivePadding(screenWidth);

    return SafeArea(
      child: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: padding ?? EdgeInsets.all(responsivePadding),
          child: child,
        ),
      ),
    );
  }
}

/// Helper widget for responsive spacing
class ResponsiveSpacing extends StatelessWidget {
  final double mobileSpacing;
  final double desktopSpacing;

  const ResponsiveSpacing({
    super.key,
    required this.mobileSpacing,
    required this.desktopSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = ResponsiveConstants.isMobile(screenWidth)
        ? mobileSpacing
        : desktopSpacing;

    return SizedBox(height: spacing);
  }
}
