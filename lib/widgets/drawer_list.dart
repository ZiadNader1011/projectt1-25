import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/profile_screen.dart';

import 'app_icon.dart';
import 'drawer_item.dart';

class DrawerList extends StatefulWidget {
  const DrawerList({super.key});

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppIcon(
                width: 80.w,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.32),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          DrawerItem(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ));
            },
            title: 'My Profile',
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            ending: Icon(Icons.arrow_forward_ios),
          ),
          DrawerItem(
            title: 'Home',
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            ending: Icon(Icons.arrow_forward_ios),
          ),
          DrawerItem(
            title: 'settings',
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            ending: Icon(Icons.arrow_forward_ios),
          ),
          DrawerItem(
            title: 'Notification',
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            ending: Text('12'),
          ),
          DrawerItem(
            title: 'Signout',
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            ending: SizedBox(),
          ),
          // DrawerItem(
          //       title: 'Profile',
          //       icon: Icons.person,
          //     ),
          // DrawerItem(
          //       title: 'Settings',
          //       icon: Icons.settings,
          //     ),
          // DrawerItem(
          //       title: 'Logout',)
        ],
      ),
    );
  }
}
