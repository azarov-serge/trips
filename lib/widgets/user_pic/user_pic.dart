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
    final Widget defaultUserPic = Icon(
      CupertinoIcons.person_circle_fill,
      size: size - 4,
      color: CupertinoTheme.of(context).textTheme.textStyle.color,
    );

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
              child: Image.network(
                url,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  child: defaultUserPic,
                  margin: const EdgeInsets.only(top: 100),
                ),
              ),
            )
          : Center(child: defaultUserPic),
    );
  }
}
