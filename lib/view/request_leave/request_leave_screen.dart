import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({super.key});

  @override
  State<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeaveScreen> {
  DateTime selectedDate = DateTime.now();
  Set<int> selectedDates = {};
  int? startDate;
  int? endDate;
  String selectedLeaveType = 'Annual leave';
  List<String> leaveTypes = ['Annual leave', 'Sick leave', 'Vacation', 'Personal leave', 'Emergency leave'];
  TextEditingController notesController = TextEditingController();
  List<Map<String, dynamic>> attachedFiles = [];

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    
    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeService.getMainGradient(),
        ),
        child: Column(
          children: [
            // Top Header
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request Leave',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: themeService.getSilver(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: themeService.getSilver(),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calendar Section
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Month Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month - 1,
                                  1,
                                );
                              });
                            },
                            icon: Icon(
                              Icons.chevron_left,
                              color: themeService.getSilver(),
                              size: 28,
                            ),
                          ),
                          Text(
                            _getMonthYearString(selectedDate),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: themeService.getSilver(),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month + 1,
                                  1,
                                );
                              });
                            },
                            icon: Icon(
                              Icons.chevron_right,
                              color: themeService.getSilver(),
                              size: 28,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Days of Week Header
                      const Row(
                        children: [
                          Expanded(child: _DayHeader('SUN')),
                          Expanded(child: _DayHeader('MON')),
                          Expanded(child: _DayHeader('TUE')),
                          Expanded(child: _DayHeader('WED')),
                          Expanded(child: _DayHeader('THU')),
                          Expanded(child: _DayHeader('FRI')),
                          Expanded(child: _DayHeader('SAT')),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Divider
                      Container(
                        height: 1,
                        color: themeService.getSilver().withValues(alpha: 0.3),
                      ),

                      const SizedBox(height: 20),

                      // Calendar Grid
                      _buildCalendarGrid(),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Form Section
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Leave Type Section
                            Text(
                              'Leave type',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeService.getTextSecondaryColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Leave Type Dropdown
                            GestureDetector(
                              onTap: () {
                                _showLeaveTypeDialog();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedLeaveType,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: themeService.getTextPrimaryColor(),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: themeService.getTextSecondaryColor(),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Divider
                            Container(
                              height: 1,
                              color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                            ),

                            const SizedBox(height: 30),

                            // Notes Section
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeService.getTextSecondaryColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Notes Input
                            TextField(
                              controller: notesController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Add notes...',
                                hintStyle: TextStyle(color: themeService.getTextPrimaryColor()),
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: themeService.getTextPrimaryColor(),
                              ),
                              maxLines: null,
                            ),

                            // Divider
                            Container(
                              height: 1,
                              color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                            ),

                            const SizedBox(height: 30),

                            // Attach Document/Image Section
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _showAttachmentOptions();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: themeService.getActionColor('requests'), width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            color: themeService.getActionColor('requests'),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Attach Document',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: themeService.getActionColor('requests'),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: themeService.getActionColor('requests'), width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: themeService.getActionColor('requests'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Show attached files
                            if (attachedFiles.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                'Attached Files',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeService.getTextSecondaryColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...attachedFiles.map((file) => _buildAttachedFile(file)).toList(),
                            ],

                            const SizedBox(height: 40),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle submit
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeService.getActionColor('requests'),
                                  foregroundColor: themeService.getSilver(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: themeService.getSilver(),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveTypeDialog() {
    final themeService = ThemeService.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.getCardColor(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select Leave Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
              ),

              // Leave type options
              ...leaveTypes.map((type) => ListTile(
                title: Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedLeaveType == type ? themeService.getActionColor('requests') : themeService.getTextPrimaryColor(),
                    fontWeight: selectedLeaveType == type ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: selectedLeaveType == type
                    ? Icon(
                  Icons.check,
                  color: themeService.getActionColor('requests'),
                )
                    : null,
                onTap: () {
                  setState(() {
                    selectedLeaveType = type;
                  });
                  Navigator.pop(context);
                },
              )).toList(),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentOptions() {
    final themeService = ThemeService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.getCardColor(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Attach File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
              ),

              // Options
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: themeService.getActionColor('requests')),
                title: const Text('Document'),
                subtitle: const Text('PDF, DOC, XLS, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: themeService.getActionColor('requests')),
                title: const Text('Photo from Gallery'),
                subtitle: const Text('JPG, PNG, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: themeService.getActionColor('requests')),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _pickDocument() {
    // Simulate document picker
    // In real app, use file_picker package
    setState(() {
      attachedFiles.add({
        'name': 'medical_certificate.pdf',
        'type': 'document',
        'size': '2.5 MB',
        'icon': Icons.picture_as_pdf,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Document attached successfully'),
        backgroundColor: ThemeService.instance.getActionColor('requests'),
      ),
    );
  }

  void _pickImage() {
    _showImagePickerOptions();
  }

  void _pickImageFromGallery() {
    // Simulate image picker from gallery
    // In real app, use image_picker package
    setState(() {
      attachedFiles.add({
        'name': 'leave_photo.jpg',
        'type': 'image',
        'size': '1.2 MB',
        'icon': Icons.image,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image attached successfully'),
        backgroundColor: ThemeService.instance.getActionColor('requests'),
      ),
    );
  }

  void _pickImageFromCamera() {
    // Simulate camera capture
    // In real app, use image_picker package
    setState(() {
      attachedFiles.add({
        'name': 'camera_photo.jpg',
        'type': 'image',
        'size': '1.8 MB',
        'icon': Icons.camera_alt,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Photo captured successfully'),
        backgroundColor: ThemeService.instance.getActionColor('requests'),
      ),
    );
  }

  void _showImagePickerOptions() {
    final themeService = ThemeService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.getCardColor(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
              ),

              // Options
              ListTile(
                leading: Icon(Icons.photo, color: themeService.getActionColor('requests')),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: themeService.getActionColor('requests')),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachedFile(Map<String, dynamic> file) {
    final themeService = ThemeService.instance;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeService.getTextSecondaryColor().withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            file['icon'],
            color: themeService.getActionColor('requests'),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
                Text(
                  file['size'],
                  style: TextStyle(
                    fontSize: 12,
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                attachedFiles.remove(file);
              });
            },
            child: Icon(
              Icons.close,
              color: themeService.getTextSecondaryColor(),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Previous month days to show
    final prevMonthDays = <int>[];
    final prevMonth = DateTime(selectedDate.year, selectedDate.month - 1, 0);
    for (int i = firstDayWeekday - 1; i >= 0; i--) {
      prevMonthDays.add(prevMonth.day - i);
    }

    // Current month days
    final currentMonthDays = List.generate(daysInMonth, (index) => index + 1);

    // Next month days to fill the grid
    final nextMonthDays = <int>[];
    final totalCells = 42; // 6 rows × 7 days
    final remainingCells = totalCells - prevMonthDays.length - currentMonthDays.length;
    for (int i = 1; i <= remainingCells && nextMonthDays.length < 7; i++) {
      nextMonthDays.add(i);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: prevMonthDays.length + currentMonthDays.length + nextMonthDays.length,
      itemBuilder: (context, index) {
        if (index < prevMonthDays.length) {
          // Previous month days
          return _buildCalendarDay(
            prevMonthDays[index].toString(),
            dayNumber: prevMonthDays[index],
            isCurrentMonth: false,
            isSelected: false,
          );
        } else if (index < prevMonthDays.length + currentMonthDays.length) {
          // Current month days
          final day = currentMonthDays[index - prevMonthDays.length];
          final isSelected = selectedDates.contains(day);

          return _buildCalendarDay(
            day.toString(),
            dayNumber: day,
            isCurrentMonth: true,
            isSelected: isSelected,
          );
        } else {
          // Next month days
          final dayIndex = index - prevMonthDays.length - currentMonthDays.length;
          return _buildCalendarDay(
            nextMonthDays[dayIndex].toString(),
            dayNumber: nextMonthDays[dayIndex],
            isCurrentMonth: false,
            isSelected: false,
          );
        }
      },
    );
  }

  Widget _buildCalendarDay(
      String dayText, {
        required int dayNumber,
        required bool isCurrentMonth,
        required bool isSelected,
      }) {
    return GestureDetector(
      onTap: isCurrentMonth ? () {
        setState(() {
          if (startDate == null) {
            // First click - select start date
            startDate = dayNumber;
            selectedDates = {dayNumber};
          } else if (endDate == null && dayNumber != startDate) {
            // Second click - select end date and range
            endDate = dayNumber;
            int start = startDate! < dayNumber ? startDate! : dayNumber;
            int end = startDate! > dayNumber ? startDate! : dayNumber;

            // Create range between start and end
            selectedDates.clear();
            for (int i = start; i <= end; i++) {
              selectedDates.add(i);
            }
          } else {
            // Reset selection
            selectedDates.clear();
            startDate = dayNumber;
            endDate = null;
            selectedDates = {dayNumber};
          }
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? ThemeService.instance.getSilver() : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            dayText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isCurrentMonth
                  ? (isSelected ? ThemeService.instance.getActionColor('requests') : ThemeService.instance.getSilver())
                  : ThemeService.instance.getSilver().withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DayHeader extends StatelessWidget {
  final String day;

  const _DayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        day,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ThemeService.instance.getSilver(),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}