import 'package:flutter/widgets.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/pages.dart';

List<Page> onGenerateAppViewPages(AuthStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AuthStatus.authenticated:
      return [HomePage.page()];
    case AuthStatus.unauthenticated:
    default:
      return [LoginPage.page()];
  }
}
