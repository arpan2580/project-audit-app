import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/attendance_controller.dart';
import 'package:jnk_app/controllers/base_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController = Get.find();
    return Obx(
      () => attendanceController.isLoading.value
          ? Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: const Center(child: CircularProgressIndicator.adaptive()),
            )
          : Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: AppBar(
                title: const Text('Attendance Report'),
                centerTitle: true,
              ),
              body: GestureDetector(
                onTap: () {
                  BaseController.showOptions.value = false;
                },
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppConstants.dashboardCardBg),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppConstants.primaryColor.withValues(alpha: 0.5),
                              AppConstants.logoBlueColor.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 70.0,
                              child: Card(
                                margin: EdgeInsets.only(top: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.zero,
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.zero,
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 40.0,
                                      ),
                                      child: Text("DATE"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 40.0,
                                      ),
                                      child: Text("TIME"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 30.0,
                                      ),
                                      child: Text("STATUS"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Card(
                        //   margin: EdgeInsets.all(5.0),
                        //   child: ListTile(
                        //     leading: Text(
                        //       "DATE",
                        //       style: TextStyle(
                        //         fontSize: 18.0,
                        //         fontWeight: FontWeight.normal,
                        //       ),
                        //     ),

                        //     title: Center(
                        //       child: Text("TIME", style: TextStyle(fontSize: 18.0)),
                        //     ),
                        //     trailing: Center(
                        //       child: Text("STATUS", style: TextStyle(fontSize: 18.0)),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),

                    // ListView(
                    //   shrinkWrap: true,
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.all(20.0),
                    //       child: Text(
                    //         'This is the Attendance screen where you can see your previous day attendace.',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           color: AppConstants.primaryColor,
                    //         ),
                    //       ),
                    //     ),
                    //     // Add more widgets here as needed
                    //   ],
                    // ),
                    attendanceController.attendance.isEmpty
                        ? const Center(
                            child: Text(
                              "No Attendance Records Found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 100.0),
                              itemCount: attendanceController.attendance.length,
                              itemBuilder: (BuildContext context, int index) {
                                final record =
                                    attendanceController.attendance[index];
                                return Card(
                                  margin: EdgeInsets.only(
                                    left: 5.0,
                                    top: 8.0,
                                    right: 5.0,
                                    // bottom: 5.0,
                                  ),
                                  elevation: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppConstants.logoBlueColor,
                                        width: 1.0,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: ListTile(
                                      // shape: ,
                                      leading: Text(
                                        (DateFormat.yMMMd().format(
                                          record.date,
                                        )).toString(),
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      title: Center(
                                        child: Text(
                                          "${record.checkInTime != null ? DateFormat('hh:mm a').format(record.checkInTime!).toString() : "--:--"} - ${record.checkOutTime != null ? DateFormat('hh:mm a').format(record.checkOutTime!).toString() : "--:--"}",
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                      trailing: (record.status == 'absent')
                                          ? SvgPicture.asset(
                                              'assets/icons/red-cross-line.svg',
                                              height: 18,
                                              width: 8.0,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icons/green-check.svg',
                                              height: 18,
                                              width: 8.0,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
