import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import '../../../../services/theme_service.dart';
import 'subordinates_data_controller.dart';
import 'employee_detail_screen.dart';

class SubordinatesDataScreen extends StatelessWidget {
  const SubordinatesDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubordinatesDataController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          tr('subordinates_data'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.employees.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: themeService.getErrorColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: themeService.getErrorColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchEmployees(),
                  child: Text(tr('retry')),
                ),
              ],
            ),
          );
        }

        if (controller.employees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(height: 16),
                Text(
                  tr('no_employees_found'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshEmployees(),
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.onSearchChanged(value),
                  decoration: InputDecoration(
                    hintText: tr('search_employees'),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.isSearching.value) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      } else if (controller.searchQuery.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.clearSearch(),
                        );
                      }
                      return const SizedBox();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Employee Table
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Builder(
                        builder: (context) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isTablet = screenWidth > 600;
                          final headerFontSize = isTablet ? 14.0 : (screenWidth < 400 ? 10.0 : 12.0);
                          final dataFontSize = isTablet ? 12.0 : (screenWidth < 400 ? 9.0 : 10.0);
                          
                          return DataTable(
                            columnSpacing: 16,
                            showCheckboxColumn: false,
                            headingRowColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                            headingTextStyle: TextStyle(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                            ),
                            dataTextStyle: TextStyle(
                              fontSize: dataFontSize,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                        columns: [
                          DataColumn(label: Text(tr('emp#'))),
                          DataColumn(label: Text(tr('name'))),
                          DataColumn(label: Text(tr('position'))),
                          DataColumn(label: Text(tr('nationality'))),
                          DataColumn(label: Text(tr('department'))),
                          DataColumn(label: Text(tr('section'))),
                        ],
                        rows: controller.employees.map((employee) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              Get.to(() => EmployeeDetailScreen(employee: employee));
                            },
                            cells: [
                              DataCell(Text(employee.employeeNo)),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 140),
                                  child: Text(
                                    employee.employeeName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 120),
                                  child: Text(
                                    employee.positionName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 100),
                                  child: Text(
                                    employee.nationalityName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 110),
                                  child: Text(
                                    employee.departmentName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 110),
                                  child: Text(
                                    employee.sectionName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination Controls
              if (controller.employees.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                        '${tr('showing')} ${controller.fromRecord.value} ${tr('to')} ${controller.toRecord.value} ${tr('of')} ${controller.totalEmployees.value}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                      Row(
                        children: [
                          IconButton(
                            onPressed: controller.currentPage.value > 1
                                ? () => controller.goToPage(controller.currentPage.value - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${controller.currentPage.value}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.hasMorePages.value
                                ? () => controller.goToPage(controller.currentPage.value + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

}