import 'package:flutter/cupertino.dart';

class CupertinoTitle extends StatelessWidget {
  final String text;

  const CupertinoTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: CupertinoTheme.of(context).textTheme.navTitleTextStyle.color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
