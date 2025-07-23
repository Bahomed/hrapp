import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';
import '../utils/app_theme.dart';
import 'theme_switch_getx_widget.dart';

class ThemeDemoWidget extends StatelessWidget {
  const ThemeDemoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        actions: [
          ThemeSwitchGetXWidget(compact: true),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Theme: ${themeService.isDarkMode ? 'Dark' : 'Light'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeService.getPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ThemeSwitchGetXWidget(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Color Palette Demo
            Text(
              'Color Palette',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary Colors
            _buildColorRow(
              'Primary Colors',
              [
                _buildColorBox('Primary', themeService.getPrimaryColor()),
                _buildColorBox('Secondary', themeService.getSecondaryColor()),
                if (themeService.isDarkMode) ...[
                  _buildColorBox('Violet Start', themeService.getVioletStart()),
                  _buildColorBox('Violet End', themeService.getVioletEnd()),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status Colors
            _buildColorRow(
              'Status Colors',
              [
                _buildColorBox('Success', themeService.getSuccessColor()),
                _buildColorBox('Warning', themeService.getWarningColor()),
                _buildColorBox('Error', themeService.getErrorColor()),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Background Colors
            _buildColorRow(
              'Background Colors',
              [
                _buildColorBox('Background', themeService.getBackgroundColor()),
                _buildColorBox('Surface', themeService.getSurfaceColor()),
                _buildColorBox('Card', themeService.getCardColor()),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Text Colors
            _buildColorRow(
              'Text Colors',
              [
                _buildColorBox('Primary Text', themeService.getTextPrimaryColor()),
                _buildColorBox('Secondary Text', themeService.getTextSecondaryColor()),
                _buildColorBox('Divider', themeService.getDividerColor()),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Gradient Demo
            Text(
              'Gradient Demo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: themeService.isDarkMode 
                    ? themeService.getVioletGradient() 
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Gradient Background',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Colors Demo
            Text(
              'Action Colors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'requests',
                'payroll',
                'documents',
                'attendance',
                'schedule',
                'profile',
              ].map((action) => _buildActionChip(action, themeService)).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Calendar Colors Demo
            Text(
              'Calendar Status Colors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusDemo('Present', themeService.getSuccessColor()),
                _buildStatusDemo('Half Day', themeService.getWarningColor()),
                _buildStatusDemo('Absent', themeService.getErrorColor()),
              ],
            ),
          ],
        ),
      )),
    );
  }
  
  Widget _buildColorRow(String title, List<Widget> colorBoxes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Get.find<ThemeService>().getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: colorBoxes,
        ),
      ],
    );
  }
  
  Widget _buildColorBox(String name, Color color) {
    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionChip(String action, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themeService.getActionColor(action),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        action.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildStatusDemo(String status, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '15',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: Get.find<ThemeService>().getTextSecondaryColor(),
          ),
        ),
      ],
    );
  }
}