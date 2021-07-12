import 'package:flutter/cupertino.dart';

class UserPic extends StatelessWidget {
  final String url;
  final double size;
  const UserPic({
    required this.url,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: CupertinoTheme.of(context).textTheme.textStyle.color!,
        ),
      ),
      child: url != ''
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(url),
            )
          : Icon(
              CupertinoIcons.person_circle_fill,
              size: size - 1,
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
            ),
    );
  }
}
