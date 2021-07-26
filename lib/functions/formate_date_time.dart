String formatDateTime(DateTime dateTime) {
  String finalTime = '';
  String hour = dateTime.hour.toString();
  String minute = dateTime.minute.toString();
  String meridiem = '';
  if (int.parse(hour) > 12) {
    hour = '${int.parse(hour) - 12}';
  }
  if (int.parse(hour) < 1) {
    hour = '${int.parse(hour) + 12}';
  }
  if (int.parse(minute) < 10) {
    minute = '0$minute';
  }
  if (int.parse(dateTime.hour.toString()) < 12) {
    meridiem = 'AM';
  } else {
    meridiem = 'PM';
  }
  finalTime =
      '${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}  $hour:$minute $meridiem';
  return finalTime;
}
