import 'package:injazat_hr_app/view/holidayscreen/holidayscreencontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HolidayScreenController model = Get.put(HolidayScreenController());
    return Padding(
      padding: const EdgeInsets.all(15),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(
              width: 200,
              child: TabBar(
                dividerColor: Colors.transparent,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.white12,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10)),
                    color: Colors.white12),
                labelPadding: EdgeInsets.zero,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: "google_sans"),
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
            Obx(
              () => Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await model.getAllholiday();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListView.builder(
                            itemCount: model.upcomingholidaylist.length,
                            itemBuilder: (BuildContext context, index) {
                              final upcommingholiday =
                                  model.upcomingholidaylist[index];
                              return Container(
                                margin: const EdgeInsets.only(top: 15),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(10)),
                                  color: Colors.white12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.blueAccent,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('dd').format(
                                                  upcommingholiday.dateTime),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24),
                                            ),
                                            Text(
                                              DateFormat(' MMM ').format(
                                                  upcommingholiday.dateTime),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Text(
                                          upcommingholiday.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () async {
                        model.getAllholiday();
                      },
                      child: ListView.builder(
                          itemCount: model.pastholidaylist.length,
                          itemBuilder: (BuildContext context, index) {
                            final pastholiday = model.pastholidaylist[index];
                            return Container(
                              margin: const EdgeInsets.only(top: 15),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(10)),
                                color: Colors.white12,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.blueAccent,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('dd')
                                                .format(pastholiday.dateTime),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24),
                                          ),
                                          Text(
                                            DateFormat(' MMM ')
                                                .format(pastholiday.dateTime),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Text(
                                        pastholiday.title,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
}
