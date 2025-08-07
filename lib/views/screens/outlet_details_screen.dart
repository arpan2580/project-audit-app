import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';

class OutletDetailsScreen extends StatelessWidget {
  const OutletDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(title: const Text('Outlet Details'), centerTitle: true),
      body: GestureDetector(
        onTap: () {
          BaseController.showOptions.value = false;
        },
        child: Column(
          children: [
            Container(
              height: 360,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/icons/store-icon.png',
                              height: 45.0,
                              color: AppConstants.backgroundColor,
                            ),
                            Text(
                              "Outlet Id: JNK123456",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Outlet Name:",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppConstants.backgroundColor,
                          ),
                        ),
                        Text(
                          "Colins Variety Store PVT. LTD.",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.backgroundColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Address:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                // color: AppConstants.backgroundColor,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              "Bhawanipore, Kolkata 700020, India",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppConstants.backgroundColor.withAlpha(
                                  240,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Divider(
                          thickness: 0.3,
                          color: AppConstants.backgroundColor,
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              "Last Audited On:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text("08/08/2025", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 25.0),
                            VerticalDivider(
                              thickness: 0.8,
                              color: AppConstants.backgroundColor,
                            ),
                            SizedBox(width: 25.0),
                            Text(
                              "Audit Count:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text("3", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
