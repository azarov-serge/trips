import 'package:flutter/cupertino.dart';

enum HintType {
  normal,
  error,
}

class Hint extends StatelessWidget {
  final String text;
  final HintType type;

  Hint(this.text, {this.type = HintType.normal});

  Color _getColor(BuildContext context) {
    switch (type) {
      case HintType.error:
        return CupertinoColors.destructiveRed;

      default:
        return CupertinoTheme.of(context)
            .textTheme
            .navTitleTextStyle
            .color!
            .withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize:
            CupertinoTheme.of(context).textTheme.navTitleTextStyle.fontSize! /
                1.5,
        color: _getColor(context),
      ),
    );
  }
}
