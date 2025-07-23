import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors - HRM-focused color palette
  static const Color primaryColor = Color(0xFF6C63FF); // Modern purple
  static const Color secondaryColor = Color(0xFF4ECDC4); // Teal green
  static const Color accentColor = Color(0xFFFF6B9D); // Soft pink
  static const Color backgroundColor = Color(0xFFF7F8FC); // Light blue-grey
  static const Color surfaceColor = Colors.white;
  static const Color pageBackgroundColor = Color(0xFFFFFFFF); // Pure white
  static const Color errorColor = Color(0xFFFF5A5A); // Softer red
  static const Color successColor = Color(0xFF26D0CE); // Bright teal
  static const Color warningColor = Color(0xFFFFB800); // Warm yellow
  static const Color textPrimary = Color(0xFF2D3748); // Dark blue-grey
  static const Color textSecondary = Color(0xFF718096); // Medium grey
  static const Color dividerColor = Color(0xFFE2E8F0);

  // IMPROVED Dark theme colors - Harmonized with your main color #011754
  static const Color mainDarkBlue = Color(0xFF011754); // Your main color

  // Complementary dark theme palette
  static const Color darkPrimaryColor = Color(0xFF4F7AFF); // Bright blue that works with your main color
  static const Color darkSecondaryColor = Color(0xFF00D4AA); // Complementary teal
  static const Color darkAccentColor = Color(0xFFFF6B9D); // Keep the pink accent
  static const Color darkBackgroundColor = mainDarkBlue; // Use your main color as background
  static const Color darkSurfaceColor = Color(0xFF0A2461); // Lighter version of your main color
  static const Color darkCardColor = Color(0xFF1A3B7D); // Even lighter for cards
  static const Color darkPageBackgroundColor = mainDarkBlue; // Your main color

  // Error, success, warning - adjusted for dark theme
  static const Color darkErrorColor = Color(0xFFFF6B6B);
  static const Color darkSuccessColor = Color(0xFF00E5B8); // Brighter success color
  static const Color darkWarningColor = Color(0xFFFFD93D);

  // Text colors - optimized for your dark blue background
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color darkTextSecondary = Color(0xFFB8D4FF); // Light blue tint
  static const Color darkDividerColor = Color(0xFF2A4A8D); // Blue-tinted divider

  // Action colors for dark theme - harmonized with your main color
  static const Map<String, Color> darkActionColors = {
    'requests': Color(0xFF4F7AFF), // Bright blue
    'payroll': Color(0xFF00D4AA), // Teal
    'documents': Color(0xFF7B68EE), // Medium slate blue
    'attendance': Color(0xFFFF6B9D), // Pink
    'schedule': Color(0xFFFFD93D), // Yellow
    'profile': Color(0xFF9F7AEA), // Purple
  };

  // CSS Root Variables (keeping some for compatibility)
  static const Color violetStart = Color(0xFF7F00FF);
  static const Color violetEnd = Color(0xFFE100FF);
  static const Color jetBlack = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color silver = Color(0xFFE5E5E5);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray600 = Color(0xFF6B7280);

  // Gradients - Updated for better harmony
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF8B7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark theme gradient using your main color
  static const LinearGradient darkMainGradient = LinearGradient(
    colors: [mainDarkBlue, Color(0xFF1A3B7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Bright gradient for accents in dark theme
  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [Color(0xFF4F7AFF), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFF26D0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFFF8FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Login screen specific gradients
  static const LinearGradient loginGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginCardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark login gradient using your main color
  static const LinearGradient darkLoginGradient = LinearGradient(
    colors: [mainDarkBlue, Color(0xFF1A3B7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;

  // Shadows - improved for dark theme
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> darkButtonShadow = [
    BoxShadow(
      color: darkPrimaryColor.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Theme Data - Light Theme (unchanged)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'google_sans',
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      brightness: Brightness.light,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        titleTextStyle: headingSmall,
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
        centerTitle: false,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          textStyle: buttonText,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
    );
  }

  // IMPROVED Dark Theme - Harmonized with your main color
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'google_sans',
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkPageBackgroundColor,
      brightness: Brightness.dark,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        titleTextStyle: headingSmall.copyWith(color: darkTextPrimary),
        iconTheme: IconThemeData(color: darkTextPrimary),
        actionsIconTheme: IconThemeData(color: darkTextPrimary),
        centerTitle: false,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        shadowColor: Colors.black.withOpacity(0.4),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          textStyle: buttonText,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: darkDividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: darkDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: darkErrorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: darkDividerColor,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkTextPrimary,
        size: 24,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimaryColor,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardColor,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: darkPrimaryColor,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: darkPrimaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),

      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        surface: darkCardColor,
        background: darkPageBackgroundColor,
        error: darkErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
      ),
    );
  }

  // Common Decorations - Theme-aware (Updated)
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: isDark ? darkCardShadow : cardShadow,
    );
  }

  static BoxDecoration getGradientCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: isDark ? darkAccentGradient : primaryGradient,
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: [
        BoxShadow(
          color: (isDark ? darkPrimaryColor : primaryColor).withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // HRM Action Button Colors - Light theme
  static const Map<String, Color> actionColors = {
    'requests': primaryColor, // Purple
    'payroll': Color(0xFF26D0CE), // Teal
    'documents': Color(0xFF4ECDC4), // Blue-green
    'attendance': Color(0xFFFF6B9D), // Pink
    'schedule': Color(0xFFFFB800), // Yellow
    'profile': Color(0xFF9F7AEA), // Light purple
  };

  // Status Colors - Updated for better contrast
  static const Map<String, Color> statusColors = {
    'approved': successColor,
    'pending': warningColor,
    'rejected': errorColor,
    'draft': textSecondary,
    'active': successColor,
    'expired': errorColor,
    'failed': errorColor,
    'processed': successColor,
    'all': primaryColor,
  };

  // Dark Status Colors
  static const Map<String, Color> darkStatusColors = {
    'approved': darkSuccessColor,
    'pending': darkWarningColor,
    'rejected': darkErrorColor,
    'draft': darkTextSecondary,
    'active': darkSuccessColor,
    'expired': darkErrorColor,
    'failed': darkErrorColor,
    'processed': darkSuccessColor,
    'all': darkPrimaryColor,
  };

  // Status Background Colors
  static const Map<String, Color> statusBackgroundColors = {
    'approved': Color(0xFFE8F5E8),
    'pending': Color(0xFFFFF8E1),
    'rejected': Color(0xFFFFEBEE),
    'draft': Color(0xFFEEEEEE),
    'active': Color(0xFFE8F5E8),
    'expired': Color(0xFFFFEBEE),
    'failed': Color(0xFFFFEBEE),
    'processed': Color(0xFFE8F5E8),
    'all': Color(0xFFE0F7FA),
  };

  // Dark Status Background Colors - Improved with your main color harmony
  static const Map<String, Color> darkStatusBackgroundColors = {
    'approved': Color(0xFF0F3A2A), // Dark green with blue tint
    'pending': Color(0xFF3A2F0F), // Dark yellow with blue tint
    'rejected': Color(0xFF3A0F1A), // Dark red with blue tint
    'draft': Color(0xFF1A2A3A), // Blue-grey
    'active': Color(0xFF0F3A2A), // Dark green with blue tint
    'expired': Color(0xFF3A0F1A), // Dark red with blue tint
    'failed': Color(0xFF3A0F1A), // Dark red with blue tint
    'processed': Color(0xFF0F3A2A), // Dark green with blue tint
    'all': Color(0xFF0A2461), // Using your dark surface color
  };

  // Common opacity levels
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.3;
  static const double opacityHeavy = 0.5;
  static const double opacityStrong = 0.7;
  static const double opacityVeryStrong = 0.8;

  // Document Type Colors - Updated with better dark theme harmony
  static const List<Color> documentColors = [
    Color(0xFF4F7AFF), // Blue
    Color(0xFF00D4AA), // Teal
    Color(0xFF7B68EE), // Medium slate blue
    Color(0xFFFF6B9D), // Pink
    Color(0xFFFFD93D), // Yellow
    Color(0xFF9F7AEA), // Purple
    Color(0xFFFF8A65), // Orange
    Color(0xFF4DB6AC), // Teal
    Color(0xFFBA68C8), // Light purple
    Color(0xFF9E9E9E), // Grey
  ];

  // Helper methods for dynamic theming - Updated
  static Color getActionColor(String action, {bool isDark = false}) {
    if (isDark) {
      return darkActionColors[action.toLowerCase()] ?? darkPrimaryColor;
    }
    return actionColors[action.toLowerCase()] ?? primaryColor;
  }

  static Color getStatusColor(String status, {bool isDark = false}) {
    if (isDark) {
      return darkStatusColors[status.toLowerCase()] ?? darkTextSecondary;
    }
    return statusColors[status.toLowerCase()] ?? textSecondary;
  }

  static Color getStatusBackgroundColor(String status, {bool isDark = false}) {
    if (isDark) {
      return darkStatusBackgroundColors[status.toLowerCase()] ?? darkSurfaceColor;
    }
    return statusBackgroundColors[status.toLowerCase()] ?? Color(0xFFEEEEEE);
  }

  static Color getDocumentColor(int index) {
    return documentColors[index % documentColors.length];
  }

  // Updated helper methods
  static LinearGradient getMainGradient({bool isDark = false}) {
    return isDark ? darkMainGradient : primaryGradient;
  }

  static LinearGradient getAccentGradient({bool isDark = false}) {
    return isDark ? darkAccentGradient : accentGradient;
  }

  static Color getMainDarkBlue() {
    return mainDarkBlue;
  }

  static Color getFilterColor(String filter, {bool isDark = false}) {
    if (isDark) {
      switch (filter.toLowerCase()) {
        case 'all':
          return darkPrimaryColor;
        case 'approved':
        case 'active':
        case 'processed':
          return darkSuccessColor;
        case 'pending':
          return darkWarningColor;
        case 'rejected':
        case 'expired':
        case 'failed':
          return darkErrorColor;
        default:
          return darkTextSecondary;
      }
    } else {
      switch (filter.toLowerCase()) {
        case 'all':
          return primaryColor;
        case 'approved':
        case 'active':
        case 'processed':
          return successColor;
        case 'pending':
          return warningColor;
        case 'rejected':
        case 'expired':
        case 'failed':
          return errorColor;
        default:
          return textSecondary;
      }
    }
  }

  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool useGradient = false,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        return Container(
          margin: margin ?? const EdgeInsets.all(0),
          padding: padding ?? const EdgeInsets.all(spacingLarge),
          decoration: useGradient
              ? getGradientCardDecoration(buildContext)
              : getCardDecoration(buildContext),
          child: child,
        );
      },
    );
  }

  static Widget buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    bool isSelected = false,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        final buttonColor = color ?? Theme.of(buildContext).primaryColor;
        final surfaceColor = Theme.of(buildContext).cardColor;
        final textColor = Theme.of(buildContext).textTheme.bodyLarge?.color ??
            (isDark ? darkTextPrimary : textPrimary);
        final borderColor = isDark ? darkDividerColor : dividerColor;

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? buttonColor : surfaceColor,
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            border: Border.all(
              color: isSelected ? buttonColor : borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: buttonColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(spacingMedium),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isSelected ? Colors.white : buttonColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(borderRadiusSmall),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : buttonColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : textColor,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
