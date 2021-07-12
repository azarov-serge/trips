import 'package:flutter/widgets.dart';
import 'package:trips/app/app.dart';
import 'package:trips/pages/pages.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    // return [FollowingTripsScreen.page()];
    case AppStatus.unauthenticated:
    default:
      return [LoginPage.page()];
  }
}
