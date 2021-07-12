import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class Logo extends StatelessWidget {
  const Logo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo/trips_logo.svg',
      color: CupertinoTheme.of(context).textTheme.navTitleTextStyle.color,
    );
  }
}
