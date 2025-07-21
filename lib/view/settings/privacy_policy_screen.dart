import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/language_service.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../services/theme_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final themeService = ThemeService.instance;
    
    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('privacy_policy'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        languageService.isRTL() ? 'سياسة الخصوصية وحماية البيانات' : 'Privacy Policy & Data Protection',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  languageService.isRTL() 
                      ? 'آخر تحديث: ${DateTime.now().toString().split(' ')[0]}'
                      : 'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Privacy Policy Content
                _buildSection(
                  languageService.isRTL() ? '1. جمع المعلومات' : '1. Information Collection',
                  languageService.isRTL() 
                      ? 'نحن نجمع المعلومات التالية لتوفير خدمة الحضور والانصراف:\n\n• بيانات الوجه للتحقق من الهوية\n• بيانات الموقع الجغرافي (خط الطول والعرض)\n• معلومات شبكة الواي فاي (SSID وBSSID)\n• الطوابع الزمنية للحضور والانصراف\n• معلومات الجهاز الأساسية'
                      : 'We collect the following information to provide attendance tracking services:\n\n• Facial recognition data for identity verification\n• Location data (latitude and longitude)\n• WiFi network information (SSID and BSSID)\n• Attendance timestamps\n• Basic device information'
                ),
                
                _buildSection(
                  languageService.isRTL() ? '2. استخدام البيانات' : '2. Data Usage',
                  languageService.isRTL()
                      ? 'نستخدم بياناتك للأغراض التالية:\n\n• التحقق من هويتك عند الحضور والانصراف\n• تتبع مواقع العمل المعتمدة\n• إنشاء تقارير الحضور والانصراف\n• ضمان أمن مكان العمل\n• الامتثال للوائح العمل المحلية'
                      : 'We use your data for the following purposes:\n\n• Verify your identity during clock-in/out\n• Track authorized work locations\n• Generate attendance reports\n• Ensure workplace security\n• Comply with local labor regulations'
                ),
                
                _buildSection(
                  languageService.isRTL() ? '3. أمان البيانات' : '3. Data Security',
                  languageService.isRTL()
                      ? 'نحن ملتزمون بحماية بياناتك:\n\n• جميع البيانات مشفرة أثناء النقل والتخزين\n• الوصول محدود للموظفين المخولين فقط\n• مراجعات أمنية منتظمة\n• حماية من الوصول غير المصرح به\n• النسخ الاحتياطي الآمن'
                      : 'We are committed to protecting your data:\n\n• All data is encrypted in transit and at rest\n• Access limited to authorized personnel only\n• Regular security audits\n• Protection against unauthorized access\n• Secure backup procedures'
                ),
                
                _buildSection(
                  languageService.isRTL() ? '4. الاحتفاظ بالبيانات' : '4. Data Retention',
                  languageService.isRTL()
                      ? 'نحتفظ ببياناتك وفقاً للمعايير التالية:\n\n• بيانات الحضور: حسب متطلبات قانون العمل\n• بيانات الوجه: طوال فترة التوظيف\n• بيانات الموقع: لأغراض التدقيق فقط\n• يتم حذف البيانات عند انتهاء التوظيف'
                      : 'We retain your data according to the following standards:\n\n• Attendance data: As per labor law requirements\n• Face recognition data: Duration of employment\n• Location data: For audit purposes only\n• Data deletion upon employment termination'
                ),
                
                _buildSection(
                  languageService.isRTL() ? '5. حقوقك' : '5. Your Rights',
                  languageService.isRTL()
                      ? 'لديك الحقوق التالية:\n\n• الوصول إلى بياناتك الشخصية\n• طلب تصحيح المعلومات غير الصحيحة\n• فهم كيفية استخدام بياناتك\n• طلب حذف البيانات (وفقاً للقوانين)\n• تقديم شكوى إلى السلطات المختصة'
                      : 'You have the following rights:\n\n• Access to your personal data\n• Request correction of incorrect information\n• Understand how your data is used\n• Request data deletion (subject to legal requirements)\n• File complaints with relevant authorities'
                ),
                
                _buildSection(
                  languageService.isRTL() ? '6. اتصل بنا' : '6. Contact Us',
                  languageService.isRTL()
                      ? 'إذا كان لديك أسئلة حول سياسة الخصوصية:\n\n• البريد الإلكتروني: privacy@company.com\n• الهاتف: +966 11 123 4567\n• العنوان: الرياض، المملكة العربية السعودية'
                      : 'If you have questions about this privacy policy:\n\n• Email: privacy@company.com\n• Phone: +966 11 123 4567\n• Address: Riyadh, Saudi Arabia'
                ),
                
                const SizedBox(height: 30),
                
                // Agreement Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00BCD4).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color(0xFF00BCD4),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          languageService.isRTL()
                              ? 'باستخدام هذا التطبيق، فإنك توافق على سياسة الخصوصية هذه.'
                              : 'By using this app, you agree to this privacy policy.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF00BCD4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}