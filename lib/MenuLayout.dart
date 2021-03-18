import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'ApplicationConstants.dart';
import 'ads_remove.dart';

Widget buildDrawer(BuildContext context) {

  return Drawer(
    child: ListView(
      children: <Widget>[
        buildHeadingMenu('Menu'),
        Container(
          child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              title: Text('Remove Ads'),
              leading: Icon(FlutterIcons.ad_faw5s),
              onTap: () {
                Get.to(AdsRemove());
              }),
        ),
        // buildHeadingMenu('${ApplicationConstants.webVersionNumber}'),
        buildHeadingMenu('${ApplicationConstants.copyrightText}'),
      ],
    ),
  );
}

Widget buildMenuItem(BuildContext context, String name, String route) {
  return Container(
    child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: Text(name),
        onTap: () {
          Navigator.pushNamed(context, '/' + route);
        }),
  );
}

Widget buildMenuItemWithout(String name) {
  return Container(
    child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: Text(name),
        onTap: () {}),
  );
}

Widget buildHeadingMenu(String name) {
  return Container(
    child: ListTile(
      title: Text(
        name,
        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
      ),
    ),
  );
}
