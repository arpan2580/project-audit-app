import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/attendance_controller.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/user_model.dart';

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
                      height: (BaseController.user.value?.role == 'mngr')
                          ? 240
                          : 180,
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
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (BaseController.user.value?.role == 'mngr')
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: DropdownButtonFormField2<Agent>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        hint: Text(
                                          "Select Agents",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        items: attendanceController.agents
                                            .map(
                                              (
                                                agent,
                                              ) => DropdownMenuItem<Agent>(
                                                value: agent,
                                                child: agent.id == 0
                                                    ? Text(
                                                        agent.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .logoBlueColor,
                                                        ),
                                                      )
                                                    : Text(agent.name),
                                              ),
                                            )
                                            .toList(),
                                        value:
                                            attendanceController
                                                .chooseAgent
                                                .isNotEmpty
                                            ? attendanceController
                                                  .chooseAgent[0]
                                            : null,
                                        onChanged: (Agent? value) {
                                          attendanceController
                                              .chooseAgent
                                              .value = [
                                            value,
                                          ];
                                          attendanceController
                                              .fetchAgentAttendance(value!.id);
                                        },

                                        // Controls the button height & width
                                        buttonStyleData: ButtonStyleData(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          height: 55,
                                          width: double.infinity,
                                        ),

                                        // Controls the dropdown's appearance & position
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 300,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Colors.white,
                                          ),
                                          offset: const Offset(
                                            0,
                                            0,
                                          ), // Ensures dropdown opens **below** button
                                        ),
                                      ),
                                    )
                                  : Container(),
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
                    attendanceController.isAgentAttendanceFetch.value
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          )
                        : attendanceController.attendance.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 270.0),
                              child: Text(
                                "No Attendance Records Found",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                if (BaseController.user.value?.role == 'mngr' &&
                                    attendanceController
                                        .chooseAgent
                                        .isNotEmpty) {
                                  await attendanceController
                                      .fetchAgentAttendance(
                                        attendanceController.chooseAgent[0]!.id,
                                      );
                                } else {
                                  await attendanceController
                                      .fetchAttendanceData();
                                }
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 100.0),
                                itemCount:
                                    attendanceController.attendance.length,
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
                                            // record.checkInTime != null
                                            //     ? DateFormat('hh:mm:ss a')
                                            //           .format(
                                            //             record.checkInTime!,
                                            //           )
                                            //           .toString()
                                            //     : "--:--:--",
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                        trailing: (record.status == 'absent')
                                            ? SvgPicture.asset(
                                                'assets/icons/red-cross-line.svg',
                                                height: 18,
                                                width: 8.0,
                                              )
                                            : (record.status == 'present')
                                            ? SvgPicture.asset(
                                                'assets/icons/green-check.svg',
                                                height: 18,
                                                width: 8.0,
                                              )
                                            : Icon(
                                                Icons.event_busy,
                                                size: 21.0,
                                                color: Colors.grey[600],
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
