import 'package:flutter/material.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import '../services/theme_service.dart';
import '../view/request_leave/widgets/request_widgets.dart';

class ScreenThemes {
  
  /// Login Screen Theme - More creative and welcoming
  static Widget buildLoginScreen({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.loginGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
      ),
    );
  }

  static Widget buildLoginCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: padding ?? const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.loginCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Home Screen Theme - Consistent and clean
  static Widget buildHomeScreenContainer({required Widget child, BuildContext? context}) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final backgroundColor = Theme.of(buildContext).scaffoldBackgroundColor;
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor, // Use solid color for consistency
          ),
          child: child,
        );
      },
    );
  }

  static Widget buildWelcomeCard({required Widget child, BuildContext? context}) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor, // Use solid color instead of gradient for consistency
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Theme.of(buildContext).primaryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// Face ID/Attendance Theme - Secure and modern
  static Widget buildFaceIdCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Settings Screen Theme - Clean and professional
  static Widget buildSettingsSection({
    required Widget child,
    required String title,
    required IconData icon,
    Color? iconColor,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? Theme.of(buildContext).primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Theme.of(buildContext).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(buildContext).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }

  /// Document/Files Theme - Organized and clean
  static Widget buildDocumentCard({
    required Widget child,
    String? category,
    Color? categoryColor,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: categoryColor?.withOpacity(0.2) ?? 
                  (isDark ? Colors.white24 : AppTheme.dividerColor),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : (categoryColor ?? AppTheme.primaryColor).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// Payroll Theme - Financial and trustworthy
  static Widget buildPayrollCard({
    required Widget child, 
    bool isPrimary = false,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF26D0CE), Color(0xFF4ECDC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isPrimary 
                    ? const Color(0xFF26D0CE).withOpacity(0.3)
                    : isDark 
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                blurRadius: isPrimary ? 15 : 8,
                offset: Offset(0, isPrimary ? 8 : 2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// Schedule Theme - Time-focused and organized
  static Widget buildScheduleTimeBlock({
    required Widget child,
    required String timeLabel,
    bool isToday = false,
    bool isActive = false,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        Color backgroundColor;
        Color borderColor;
        
        if (isActive) {
          backgroundColor = AppTheme.successColor.withOpacity(0.1);
          borderColor = AppTheme.successColor;
        } else if (isToday) {
          backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
          borderColor = AppTheme.primaryColor;
        } else {
          backgroundColor = Theme.of(buildContext).cardColor;
          borderColor = isDark ? Colors.white24 : AppTheme.dividerColor;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isActive || isToday ? 2 : 1),
            boxShadow: isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isActive ? Icons.access_time : Icons.schedule,
                  color: borderColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  /// Request Theme - Action-oriented
  static Widget buildRequestCard({
    required Widget child,
    required String status,
    String? priority,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final themeService = ThemeService.instance;
        final cardColor = themeService.getCardColor();
        final isDark = themeService.isDarkMode;
        final statusColor = themeService.getStatusColor(status);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : statusColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RequestStatusChip(statusString: status.toUpperCase()),


                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        );
      },
    );
  }

  /// Profile Theme - Personal and warm
  static Widget buildProfileHeader({
    required Widget child,
    String? backgroundImage,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F7AEA), Color(0xFFB794F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: child,
    );
  }

  /// Notification Theme - Alert-focused
  static Widget buildNotificationCard({
    required Widget child,
    bool isUnread = false,
    String? type,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        Color accentColor;
        switch (type) {
          case 'urgent':
            accentColor = AppTheme.errorColor;
            break;
          case 'info':
            accentColor = AppTheme.primaryColor;
            break;
          case 'success':
            accentColor = AppTheme.successColor;
            break;
          default:
            accentColor = AppTheme.textSecondary;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? accentColor.withOpacity(0.05) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: accentColor,
                width: isUnread ? 4 : 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// Floating elements for modern feel
  static Widget buildFloatingElement({
    required Widget child,
    Color? color,
    double? elevation,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final buildContext = context ?? ctx;
        final cardColor = Theme.of(buildContext).cardColor;
        final isDark = Theme.of(buildContext).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: elevation ?? 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}