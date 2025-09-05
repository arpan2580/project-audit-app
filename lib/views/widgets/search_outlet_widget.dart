import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/bit_plan_controller.dart';

class SearchOutletWidget extends StatelessWidget {
  final BitPlanController controller;
  const SearchOutletWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextField(
        onTap: () {
          BaseController.showOptions.value = false;
        },
        controller: BitPlanController.txtSearchOutlet,
        decoration: InputDecoration(
          hintText: 'Search Outlet',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 8.0,
              right: 4.0,
              bottom: 8.0,
            ),
            child: Image.asset('assets/icons/store-icon.png', height: 20.0),
          ),
          suffixIcon: !BitPlanController.isSearch.value
              ? IconButton(
                  onPressed: () {
                    if (BitPlanController.txtSearchOutlet.text.isNotEmpty) {
                      BitPlanController.isSearch.value = true;
                      controller.searchOutlet();
                    } else {
                      BitPlanController.txtSearchOutlet.clear();
                      BitPlanController.isSearch.value = false;
                      controller.clearSearch();
                    }
                  },
                  icon: Icon(
                    Icons.search,
                    size: 40.0,
                    color: AppConstants.logoBlueColor,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // if (BitPlanController.txtSearchOutlet.text.isNotEmpty) {
                    BitPlanController.txtSearchOutlet.clear();
                    BitPlanController.isSearch.value = false;
                    controller.clearSearch();
                    // }
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 35.0,
                    color: AppConstants.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}
