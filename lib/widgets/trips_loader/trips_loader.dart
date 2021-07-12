import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class TripsLoader extends StatelessWidget {
  const TripsLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      CupertinoTheme.of(context).brightness == Brightness.dark
          ? 'assets/lottie/logo/logo_dark.json'
          : 'assets/lottie/logo/logo_light.json',
    );
  }
}
