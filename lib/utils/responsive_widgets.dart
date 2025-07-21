import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// A collection of responsive widgets to ensure consistent responsive design across all screens
class ResponsiveWidgets {
  
  /// Responsive AppBar with proper height and title sizing
  static PreferredSizeWidget responsiveAppBar(
    BuildContext context, {
    required String title,
    Widget? leading,
    List<Widget>? actions,
    Color? backgroundColor,
    bool automaticallyImplyLeading = true,
    double? elevation,
  }) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      toolbarHeight: ResponsiveUtils.responsiveAppBarHeight(context),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Responsive Card with proper padding and border radius
  static Widget responsiveCard(
    BuildContext context, {
    required Widget child,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
  }) {
    return Card(
      margin: margin ?? ResponsiveUtils.responsiveMargin(context),
      color: color,
      elevation: elevation ?? ResponsiveUtils.responsiveElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
      ),
      child: Padding(
        padding: ResponsiveUtils.responsivePadding(context),
        child: child,
      ),
    );
  }

  /// Responsive Container with proper padding and border radius
  static Widget responsiveContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    Decoration? decoration,
    double? width,
    double? height,
  }) {
    return Container(
      padding: padding ?? ResponsiveUtils.responsivePadding(context),
      margin: margin ?? ResponsiveUtils.responsiveMargin(context),
      width: width,
      height: height,
      decoration: decoration ?? BoxDecoration(
        color: color,
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
      ),
      child: child,
    );
  }

  /// Responsive Button with proper height and text size
  static Widget responsiveButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    bool isOutlined = false,
    double? width,
  }) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: backgroundColor ?? Theme.of(context).primaryColor),
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.responsiveHeight(context, 1.5),
              horizontal: ResponsiveUtils.responsiveWidth(context, 6),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.responsiveHeight(context, 1.5),
              horizontal: ResponsiveUtils.responsiveWidth(context, 6),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
            ),
          );

    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 2)),
              Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
              fontWeight: FontWeight.w600,
            ),
          );

    return SizedBox(
      width: width,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: buttonChild,
            ),
    );
  }

  /// Responsive Text with proper font sizing
  static Widget responsiveText(
    BuildContext context, {
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Text(
      text,
      style: style ?? TextStyle(
        fontSize: ResponsiveUtils.responsiveFontSize(
          context,
          mobile: mobileFontSize ?? 14,
          tablet: tabletFontSize ?? 16,
          desktop: desktopFontSize ?? 18,
        ),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Responsive SizedBox with proper spacing
  static Widget responsiveSpacing(
    BuildContext context, {
    double? height,
    double? width,
    double? mobileHeight,
    double? tabletHeight,
    double? desktopHeight,
    double? mobileWidth,
    double? tabletWidth,
    double? desktopWidth,
  }) {
    return SizedBox(
      height: height ?? ResponsiveUtils.responsiveHeight(
        context,
        ResponsiveUtils.getResponsiveValue(
          context,
          mobile: mobileHeight ?? 2,
          tablet: tabletHeight ?? 2.5,
          desktop: desktopHeight ?? 3,
        ),
      ),
      width: width ?? ResponsiveUtils.responsiveWidth(
        context,
        ResponsiveUtils.getResponsiveValue(
          context,
          mobile: mobileWidth ?? 2,
          tablet: tabletWidth ?? 2.5,
          desktop: desktopWidth ?? 3,
        ),
      ),
    );
  }

  /// Responsive Icon with proper sizing
  static Widget responsiveIcon(
    BuildContext context, {
    required IconData icon,
    Color? color,
    double? mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    return Icon(
      icon,
      color: color,
      size: ResponsiveUtils.responsiveIconSize(
        context,
        mobile: mobileSize ?? 20,
        tablet: tabletSize ?? 24,
        desktop: desktopSize ?? 28,
      ),
    );
  }

  /// Responsive ListTile with proper padding
  static Widget responsiveListTile(
    BuildContext context, {
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? tileColor,
    EdgeInsets? contentPadding,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      tileColor: tileColor,
      contentPadding: contentPadding ?? ResponsiveUtils.responsiveHorizontalPadding(context),
    );
  }

  /// Responsive Form Field with proper sizing
  static Widget responsiveFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        contentPadding: ResponsiveUtils.responsivePadding(context),
        border: OutlineInputBorder(
          borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
        ),
      ),
    );
  }

  /// Responsive Grid with proper cross axis count
  static Widget responsiveGrid(
    BuildContext context, {
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? childAspectRatio,
  }) {
    return GridView.count(
      crossAxisCount: ResponsiveUtils.responsiveCrossAxisCount(
        context,
        mobile: mobileColumns ?? 1,
        tablet: tabletColumns ?? 2,
        desktop: desktopColumns ?? 3,
      ),
      crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.responsiveWidth(context, 2),
      mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.responsiveHeight(context, 2),
      childAspectRatio: childAspectRatio ?? 1.0,
      children: children,
    );
  }

  /// Responsive SafeArea with proper padding
  static Widget responsiveSafeArea(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
  }) {
    return SafeArea(
      child: Padding(
        padding: padding ?? ResponsiveUtils.responsivePadding(context),
        child: child,
      ),
    );
  }

  /// Responsive Scaffold with proper padding
  static Widget responsiveScaffold(
    BuildContext context, {
    PreferredSizeWidget? appBar,
    required Widget body,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Color? backgroundColor,
    bool extendBody = false,
    EdgeInsets? bodyPadding,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      extendBody: extendBody,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: bodyPadding != null
          ? Padding(
              padding: bodyPadding,
              child: body,
            )
          : body,
    );
  }

  /// Get responsive screen breakpoint info
  static String getScreenInfo(BuildContext context) {
    final width = ResponsiveUtils.screenWidth(context);
    final height = ResponsiveUtils.screenHeight(context);
    final screenType = ResponsiveUtils.isMobile(context) 
        ? 'Mobile' 
        : ResponsiveUtils.isTablet(context) 
            ? 'Tablet' 
            : 'Desktop';
    
    return '$screenType: ${width.toInt()}x${height.toInt()}px';
  }
}