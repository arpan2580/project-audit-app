import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/bit_plan_controller.dart';
import 'package:jnk_app/models/bit_plan_model.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:jnk_app/views/screens/outlet_details_screen.dart';
import 'package:jnk_app/views/widgets/search_outlet_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BitPlanScreen extends StatelessWidget {
  const BitPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BitPlanController bitPlanController = Get.find();
    RxBool isExpanded = false.obs;
    RxString olCode = ''.obs;
    return Obx(
      () => bitPlanController.isLoading.value
          ? Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: const Center(child: CircularProgressIndicator.adaptive()),
            )
          : Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: AppBar(title: const Text('Bit Plan'), centerTitle: true),
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
                        child: SafeArea(
                          left: false,
                          right: false,
                          bottom: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: SearchOutletWidget(
                                  controller: bitPlanController,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    BitPlanController.isViewAll.value =
                                        !BitPlanController.isViewAll.value;
                                    BitPlanController.isSearch.value = false;
                                    bitPlanController.clearSearch();
                                  },
                                  child: Text(
                                    BitPlanController.isViewAll.value
                                        ? "Todays Bit"
                                        : "View All",
                                    style: TextStyle(
                                      color: AppConstants.backgroundColor,
                                      fontSize: AppConstants.fontLarge,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bitPlanController.filteredBit.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 270.0),
                              child: Text(
                                "No Bit Plan Found",
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
                                await bitPlanController.fetchBitPlanData();
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 100.0),
                                // itemCount: isViewAll.value
                                //     ? bitPlanController.bitPlan.length
                                //     : bitPlanController.todaysBitPlan.length,
                                itemCount: bitPlanController.filteredBit.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // final record = isViewAll.value
                                  //     ? bitPlanController.bitPlan[index]
                                  //     : bitPlanController.todaysBitPlan[index];
                                  final record =
                                      bitPlanController.filteredBit[index];
                                  // DateTime visitDate = DateTime(1900);
                                  // DateTime today = DateTime.now();
                                  if (record.lastVisitDate != null) {
                                    // today = DateTime.now();
                                    DateTime.parse(record.lastVisitDate!);
                                  }
                                  return Card(
                                    margin: EdgeInsets.only(
                                      left: 5.0,
                                      top: 8.0,
                                      right: 5.0,
                                      // bottom: 5.0,
                                    ),
                                    elevation: 2.0,
                                    color: Colors.transparent,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => OutletDetailsScreen(
                                            outletDetails: record,
                                          ),
                                        );
                                      },
                                      child:
                                          BaseController.user.value?.role ==
                                              'mngr'
                                          ? Slidable(
                                              endActionPane: ActionPane(
                                                motion: const DrawerMotion(),
                                                extentRatio: 0.2,
                                                children: [
                                                  Obx(
                                                    () => SlidableAction(
                                                      onPressed: (context) {
                                                        if (olCode.value ==
                                                                record.olCode &&
                                                            isExpanded.value) {
                                                          isExpanded.value =
                                                              false;
                                                          olCode.value = '';
                                                        } else {
                                                          isExpanded.value =
                                                              true;
                                                          olCode.value =
                                                              record.olCode;
                                                        }
                                                      },
                                                      backgroundColor:
                                                          (olCode.value ==
                                                                  record
                                                                      .olCode &&
                                                              isExpanded.value)
                                                          ? AppConstants
                                                                .primaryColor
                                                          : AppConstants
                                                                .logoBlueColor,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(10),
                                                          ),
                                                      icon:
                                                          (olCode.value ==
                                                                  record
                                                                      .olCode &&
                                                              isExpanded.value)
                                                          ? Icons.cancel_rounded
                                                          : Icons.info_outlined,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppConstants
                                                        .logoBlueColor,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      AppConstants
                                                          .backgroundColor
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      AppConstants
                                                          .backgroundColor
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor:
                                                            record.isInBitPlan
                                                            ? record.inBitVisitStatus ==
                                                                          null ||
                                                                      record.inBitVisitStatus ==
                                                                          'pending'
                                                                  ? AppConstants
                                                                        .primaryColor
                                                                  : record.inBitVisitStatus ==
                                                                        'started'
                                                                  ? Colors
                                                                        .orangeAccent
                                                                  : const Color.fromARGB(
                                                                      255,
                                                                      34,
                                                                      106,
                                                                      36,
                                                                    )
                                                            : record.lastVisitDate !=
                                                                      null &&
                                                                  DateTime.parse(
                                                                        record
                                                                            .lastVisitDate!,
                                                                      ).day ==
                                                                      DateTime.now().day
                                                            ? record.lastVisit?.status ==
                                                                      'completed'
                                                                  ? const Color.fromARGB(
                                                                      255,
                                                                      34,
                                                                      106,
                                                                      36,
                                                                    )
                                                                  : record
                                                                            .lastVisit
                                                                            ?.status ==
                                                                        'started'
                                                                  ? Colors
                                                                        .orangeAccent
                                                                  : AppConstants
                                                                        .primaryColor
                                                            : AppConstants
                                                                  .primaryColor,
                                                        child: SvgPicture.asset(
                                                          'assets/icons/outlet-icon.svg',
                                                        ),
                                                      ),
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            record.olCode,
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            record.olName,
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            record.isInBitPlan
                                                                ? "In Today's bit"
                                                                : "Not in Today's bit",
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  record
                                                                      .isInBitPlan
                                                                  ? const Color.fromARGB(
                                                                      255,
                                                                      34,
                                                                      106,
                                                                      36,
                                                                    )
                                                                  : AppConstants
                                                                        .primaryColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      trailing:
                                                          record.inBitVisitStatus !=
                                                                  null &&
                                                              record.inBitVisitStatus !=
                                                                  'pending'
                                                          ? record.inBitVisitStatus ==
                                                                    'started'
                                                                ? SvgPicture.asset(
                                                                    'assets/icons/progress-icon.svg',
                                                                    height: 18,
                                                                    width: 8.0,
                                                                  )
                                                                : SvgPicture.asset(
                                                                    'assets/icons/green-check.svg',
                                                                    height: 18,
                                                                    width: 8.0,
                                                                  )
                                                          : record.lastVisitDate !=
                                                                    null &&
                                                                DateTime.parse(
                                                                      record
                                                                          .lastVisitDate!,
                                                                    ).day ==
                                                                    DateTime.now()
                                                                        .day
                                                          ? record
                                                                        .lastVisit
                                                                        ?.status ==
                                                                    'completed'
                                                                ? SvgPicture.asset(
                                                                    'assets/icons/green-check.svg',
                                                                    height: 18,
                                                                    width: 8.0,
                                                                  )
                                                                : record
                                                                          .lastVisit
                                                                          ?.status ==
                                                                      'started'
                                                                ? SvgPicture.asset(
                                                                    'assets/icons/progress-icon.svg',
                                                                    height: 18,
                                                                    width: 8.0,
                                                                  )
                                                                : SvgPicture.asset(
                                                                    'assets/icons/red-cross-line.svg',
                                                                    height: 18,
                                                                    width: 8.0,
                                                                  )
                                                          : SvgPicture.asset(
                                                              'assets/icons/red-cross-line.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            ),
                                                    ),
                                                    Obx(
                                                      () =>
                                                          (isExpanded.value &&
                                                              olCode.value ==
                                                                  record.olCode)
                                                          ? Column(
                                                              children: [
                                                                const SizedBox(
                                                                  height: 3.0,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: FadedDivider(
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        height:
                                                                            3.0,
                                                                        begin: Alignment
                                                                            .centerLeft,
                                                                        end: Alignment
                                                                            .centerRight,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                      ),
                                                                      child: Text(
                                                                        "Today's Audits",
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              16.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: FadedDivider(
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        height:
                                                                            3.0,
                                                                        begin: Alignment
                                                                            .centerRight,
                                                                        end: Alignment
                                                                            .centerLeft,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                // const SizedBox(
                                                                //   height: 1.0,
                                                                // ),
                                                                record
                                                                        .todaysVisitList
                                                                        .isNotEmpty
                                                                    ? Column(
                                                                        children: record
                                                                            .todaysVisitList
                                                                            .map(
                                                                              (
                                                                                visit,
                                                                              ) => buildVisitRow(
                                                                                visit,
                                                                                record.todaysVisitList.length,
                                                                                record.todaysVisitList.indexOf(
                                                                                  visit,
                                                                                ),
                                                                              ),
                                                                            )
                                                                            .toList(),
                                                                      )
                                                                    : Column(
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                10.0,
                                                                          ),
                                                                          Text(
                                                                            "No visits yet.",
                                                                            style: TextStyle(
                                                                              color: Colors.grey[600],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                20.0,
                                                                          ),
                                                                        ],
                                                                      ),
                                                              ],
                                                            )
                                                          : Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppConstants
                                                      .logoBlueColor,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppConstants.backgroundColor
                                                        .withValues(alpha: 0.8),
                                                    AppConstants.backgroundColor
                                                        .withValues(alpha: 0.7),
                                                  ],
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                      record.isInBitPlan
                                                      ? record.inBitVisitStatus ==
                                                                    null ||
                                                                record.inBitVisitStatus ==
                                                                    'pending'
                                                            ? AppConstants
                                                                  .primaryColor
                                                            : record.inBitVisitStatus ==
                                                                  'started'
                                                            ? Colors
                                                                  .orangeAccent
                                                            : const Color.fromARGB(
                                                                255,
                                                                34,
                                                                106,
                                                                36,
                                                              )
                                                      : record.lastVisitDate !=
                                                                null &&
                                                            DateTime.parse(
                                                                  record
                                                                      .lastVisitDate!,
                                                                ).day ==
                                                                DateTime.now()
                                                                    .day
                                                      ? record
                                                                    .lastVisit
                                                                    ?.status ==
                                                                'completed'
                                                            ? const Color.fromARGB(
                                                                255,
                                                                34,
                                                                106,
                                                                36,
                                                              )
                                                            : record
                                                                      .lastVisit
                                                                      ?.status ==
                                                                  'started'
                                                            ? Colors
                                                                  .orangeAccent
                                                            : AppConstants
                                                                  .primaryColor
                                                      : AppConstants
                                                            .primaryColor,
                                                  child: SvgPicture.asset(
                                                    'assets/icons/outlet-icon.svg',
                                                  ),
                                                ),
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      record.olCode,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      record.olName,
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      record.isInBitPlan
                                                          ? "In Today's bit"
                                                          : "Not in Today's bit",
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            record.isInBitPlan
                                                            ? const Color.fromARGB(
                                                                255,
                                                                34,
                                                                106,
                                                                36,
                                                              )
                                                            : AppConstants
                                                                  .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing:
                                                    record.inBitVisitStatus !=
                                                            null &&
                                                        record.inBitVisitStatus !=
                                                            'pending'
                                                    ? record.inBitVisitStatus ==
                                                              'started'
                                                          ? SvgPicture.asset(
                                                              'assets/icons/progress-icon.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            )
                                                          : SvgPicture.asset(
                                                              'assets/icons/green-check.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            )
                                                    : record.lastVisitDate !=
                                                              null &&
                                                          DateTime.parse(
                                                                record
                                                                    .lastVisitDate!,
                                                              ).day ==
                                                              DateTime.now().day
                                                    ? record
                                                                  .lastVisit
                                                                  ?.status ==
                                                              'completed'
                                                          ? SvgPicture.asset(
                                                              'assets/icons/green-check.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            )
                                                          : record
                                                                    .lastVisit
                                                                    ?.status ==
                                                                'started'
                                                          ? SvgPicture.asset(
                                                              'assets/icons/progress-icon.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            )
                                                          : SvgPicture.asset(
                                                              'assets/icons/red-cross-line.svg',
                                                              height: 18,
                                                              width: 8.0,
                                                            )
                                                    : SvgPicture.asset(
                                                        'assets/icons/red-cross-line.svg',
                                                        height: 18,
                                                        width: 8.0,
                                                      ),
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

  Widget buildVisitRow(Visit visit, int count, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 0,
            bottom: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(visit.userName, style: const TextStyle(fontSize: 16)),
              Text(
                "Start: ${visit.startTime != null ? DateFormat('hh:mm a').format(DateTime.parse(visit.startTime!)) : '--:--'}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "End: ${visit.endTime != null ? DateFormat('hh:mm a').format(DateTime.parse(visit.endTime!)) : '--:--'}",
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed:
                    (visit.startLatitude != null &&
                        visit.startLongitude != null)
                    ? () async {
                        final url =
                            'https://maps.google.com/maps?q=${visit.startLatitude},${visit.startLongitude}';
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    : null,
                icon: Icon(Icons.location_on_rounded, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        count > 1 && index != count - 1
            ? Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  thickness: 0.5,
                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                ),
              )
            : SizedBox(height: 6.0),
      ],
    );
  }
}
