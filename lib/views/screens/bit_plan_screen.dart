import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/bit_plan_controller.dart';
import 'package:jnk_app/views/screens/outlet_details_screen.dart';
import 'package:jnk_app/views/widgets/search_outlet_widget.dart';

class BitPlanScreen extends StatelessWidget {
  const BitPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BitPlanController bitPlanController = Get.find();
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
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppConstants.logoBlueColor,
                                            width: 1.0,
                                          ),
                                          borderRadius: const BorderRadius.all(
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
                                            backgroundColor: record.isInBitPlan
                                                ? record.inBitVisitStatus ==
                                                              null ||
                                                          record.inBitVisitStatus ==
                                                              'pending'
                                                      ? AppConstants
                                                            .primaryColor
                                                      : record.inBitVisitStatus ==
                                                            'started'
                                                      ? Colors.orangeAccent
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
                                                      ? Colors.orangeAccent
                                                      : AppConstants
                                                            .primaryColor
                                                : AppConstants.primaryColor,
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
                                                  fontWeight: FontWeight.w500,
                                                  color: record.isInBitPlan
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
                                              record.inBitVisitStatus != null &&
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
                                              : record.lastVisitDate != null &&
                                                    DateTime.parse(
                                                          record.lastVisitDate!,
                                                        ).day ==
                                                        DateTime.now().day
                                              ? record.lastVisit?.status ==
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
}
