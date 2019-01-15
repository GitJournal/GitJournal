import 'package:intl/intl.dart';

String toIso8601WithTimezone(DateTime dt) {
  var result = DateFormat("y-M-dTH:m:s").format(dt);
  var offset = dt.timeZoneOffset;
  if (offset.inSeconds == 0) {
    return result + 'Z';
  } else {
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
}
