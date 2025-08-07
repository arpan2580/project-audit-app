import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/screens/outlet_details_screen.dart';
import 'package:jnk_app/views/widgets/search_outlet_widget.dart';

class BitPlanScreen extends StatelessWidget {
  const BitPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Center(child: SearchOutletWidget()),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 100.0),
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
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
                        Get.to(() => OutletDetailsScreen());
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
                              AppConstants.backgroundColor.withValues(
                                alpha: 0.8,
                              ),
                              AppConstants.backgroundColor.withValues(
                                alpha: 0.7,
                              ),
                            ],
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: index / 2 == 0
                                ? AppConstants.primaryColor
                                : const Color.fromARGB(255, 34, 106, 36),
                            child: SvgPicture.asset(
                              'assets/icons/outlet-icon.svg',
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("123456", style: TextStyle(fontSize: 18.0)),
                              Text(
                                "Colins Variety Store",
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                index / 2 == 0 ? "Pending" : "Success",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: index / 2 == 0
                                      ? AppConstants.primaryColor
                                      : const Color.fromARGB(255, 34, 106, 36),
                                ),
                              ),
                            ],
                          ),
                          trailing: (index / 2) == 0
                              ? SvgPicture.asset(
                                  'assets/icons/green-check.svg',
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
          ],
        ),
      ),
    );
  }
}
