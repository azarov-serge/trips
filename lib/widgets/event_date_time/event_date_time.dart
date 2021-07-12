import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:trips/widgets/widgets.dart';

class EventDateTime extends StatelessWidget {
  final DateTime _eventDateTime;

  const EventDateTime(this._eventDateTime);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hint(DateFormat('dd.MM.yyyy').format(_eventDateTime)),
        SizedBox(width: 5),
        Hint(DateFormat('Hm').format(_eventDateTime)),
      ],
    );
  }
}
