import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class SearchOutletWidget extends StatelessWidget {
  const SearchOutletWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextField(
        onTap: () {
          // showOptions.value = false;
        },
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
          suffixIcon: Icon(
            Icons.search,
            size: 40.0,
            color: AppConstants.logoBlueColor,
          ),
        ),
      ),
    );
  }
}
