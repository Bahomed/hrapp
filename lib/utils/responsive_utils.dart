import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double _mobileMaxWidth = 480;
  static const double _tabletMaxWidth = 768;
  static const double _desktopMaxWidth = 1024;

  // Screen size breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileMaxWidth;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileMaxWidth &&
      MediaQuery.of(context).size.width < _tabletMaxWidth;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletMaxWidth;

  // Screen dimensions
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.all(mobile);
    } else if (isTablet(context)) {
      return EdgeInsets.all(tablet);
    } else {
      return EdgeInsets.all(desktop);
    }
  }

  // Responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: mobile);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: tablet);
    } else {
      return EdgeInsets.symmetric(horizontal: desktop);
    }
  }

  // Responsive vertical padding
  static EdgeInsets responsiveVerticalPadding(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(vertical: mobile);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(vertical: tablet);
    } else {
      return EdgeInsets.symmetric(vertical: desktop);
    }
  }

  // Responsive font size
  static double responsiveFontSize(BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Responsive font size based on screen width percentage
  static double responsiveFontSizeByWidth(BuildContext context, double percentage) {
    return screenWidth(context) * percentage / 100;
  }

  // Responsive width
  static double responsiveWidth(BuildContext context, double percentage) {
    return screenWidth(context) * percentage / 100;
  }

  // Responsive height
  static double responsiveHeight(BuildContext context, double percentage) {
    return screenHeight(context) * percentage / 100;
  }

  // Responsive margin
  static EdgeInsets responsiveMargin(BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.all(mobile);
    } else if (isTablet(context)) {
      return EdgeInsets.all(tablet);
    } else {
      return EdgeInsets.all(desktop);
    }
  }

  // Responsive border radius
  static BorderRadius responsiveBorderRadius(BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (isMobile(context)) {
      return BorderRadius.circular(mobile);
    } else if (isTablet(context)) {
      return BorderRadius.circular(tablet);
    } else {
      return BorderRadius.circular(desktop);
    }
  }

  // Responsive icon size
  static double responsiveIconSize(BuildContext context, {
    double mobile = 20.0,
    double tablet = 24.0,
    double desktop = 28.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Responsive button height
  static double responsiveButtonHeight(BuildContext context, {
    double mobile = 48.0,
    double tablet = 52.0,
    double desktop = 56.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Responsive app bar height
  static double responsiveAppBarHeight(BuildContext context, {
    double mobile = 56.0,
    double tablet = 60.0,
    double desktop = 64.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Responsive card elevation
  static double responsiveElevation(BuildContext context, {
    double mobile = 2.0,
    double tablet = 4.0,
    double desktop = 6.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Get responsive value based on screen size
  static T getResponsiveValue<T>(BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Safe area padding considerations
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // Get available screen height excluding keyboard
  static double availableHeight(BuildContext context) {
    return screenHeight(context) - MediaQuery.of(context).viewInsets.bottom;
  }

  // Text scaling factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  // Responsive cross axis count for grids
  static int responsiveCrossAxisCount(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}