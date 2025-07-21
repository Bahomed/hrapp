import 'package:injazat_hr_app/utils/backgrounddecoration.dart';
import 'package:injazat_hr_app/view/notifications_screen/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificatiionController model = Get.put(NotificatiionController());
    return Container(
      decoration: backgroundDecoration(context),
      child: Scaffold(
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            await model.getAllNotice();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Visibility(
                      visible: model.birthdaylist.isEmpty ? false : true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Weekly Birthday(s)',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                primary: false,
                                shrinkWrap: true,
                                itemCount: model.birthdaylist.length,
                                itemBuilder: (BuildContext context, index) {
                                  final birthday =
                                      model.birthdaylist[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                      tileColor: Colors.white12,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight:
                                                  Radius.circular(10))),
                                      iconColor: Colors.white,
                                      minLeadingWidth: 0,
                                      leading: const SizedBox(
                                          height: double.infinity,
                                          child: Icon(Icons.cake)),
                                      textColor: Colors.white,
                                      title: Text(birthday.name),
                                      subtitle: Text(
                                        birthday.date,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: model.noticelsit.isEmpty?false:true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Notice(s)',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              primary: false,
                              shrinkWrap: true,
                              itemCount: model.noticelsit.length,
                              itemBuilder: (BuildContext context, index) {
                                final notice = model.noticelsit[index];

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notice.title,
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          notice.description,
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            notice.dateTime,
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
