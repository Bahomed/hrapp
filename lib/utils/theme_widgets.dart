import 'package:flutter/material.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../services/theme_service.dart';

class ThemeWidgets {
  
  /// Standard App Bar with consistent styling
  static AppBar buildAppBar({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading && onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            )
          : null,
      title: Text(title),
      actions: actions,
    );
  }

  /// Standard Screen Container with consistent styling
  static Widget buildScreenContainer({
    required Widget child,
    EdgeInsets? padding,
    bool addSafeArea = true,
  }) {
    Widget content = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: double.infinity),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLarge),
      child: child,
    );

    if (addSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }

  /// Section Header with consistent styling
  static Widget buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? trailing,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD

=======
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
                Text(title, style: AppTheme.bodyLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// Standard Card Section
  static Widget buildCardSection({
    required Widget child,
    String? title,
    IconData? icon,
    Color? iconColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppTheme.buildCard(
      padding: padding,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                ],
                Text(title, style: AppTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
          child,
        ],
      ),
    );
  }

  /// Standard List Tile
  static Widget buildListTile({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingXSmall,
      ),
      leading: leadingIcon != null
          ? Icon(
              leadingIcon,
              color: iconColor ?? AppTheme.textSecondary,
            )
          : null,
      title: Text(
        title,
        style: AppTheme.bodyMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTheme.bodySmall,
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textSecondary,
          ),
      onTap: onTap,
    );
  }

  /// Empty State Widget
  static Widget buildEmptyState({
    required String message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
          Text(
            message,
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            action,
          ],
        ],
      ),
    );
  }

  /// Loading Widget
  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ThemeService.instance.getPrimaryColor()),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: ThemeService.instance.getTextSecondaryColor()),
            ),
          ],
        ],
      ),
    );
  }

  /// Status Badge
  static Widget buildStatusBadge({
    required String status,
    EdgeInsets? padding,
  }) {
    final statusColor = AppTheme.getStatusColor(status);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: AppTheme.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Filter Chip
  static Widget buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppTheme.primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Information Row
  static Widget buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingMedium),
        ],
        Text(
          label,
          style: AppTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// Gradient Card
  static Widget buildGradientCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Gradient? gradient,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: child,
    );
  }

  /// Floating Action Button with theme styling
  static Widget buildFloatingActionButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        elevation: 0,
        icon: icon != null ? Icon(icon, color: Colors.white, size: 24) : null,
        label: Text(
          label,
          style: AppTheme.buttonText,
        ),
      ),
    );
  }

  /// Standard Screen Scaffold
  static Widget buildScreenScaffold({
    required String title,
    required Widget body,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Widget? floatingActionButton,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: buildAppBar(
        title: title,
        onBackPressed: onBackPressed,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}