import 'package:intl/intl.dart';

String toIso8601(DateTime dt) {
  return DateFormat("yyyy-MM-ddTHH:mm:ss").format(dt);
}

String toIso8601WithTimezone(DateTime dt) {
  var result = DateFormat("yyyy-MM-ddTHH:mm:ss").format(dt);

  var offset = dt.timeZoneOffset;
  int minutes = (offset.inMinutes % 60);
  int hours = offset.inHours.toInt();

  String minutesStr;
  if (minutes < 10) {
    minutesStr = '0' + minutes.toString();
  } else {
    minutesStr = minutes.toString();
  }

  String hourStr;
  if (hours < 10) {
    hourStr = '0' + hours.toString();
  } else {
    hourStr = hours.toString();
  }

  return result + '+' + hourStr + ':' + minutesStr;
}
