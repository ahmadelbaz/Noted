import 'package:uuid/uuid.dart';

String generateRandomNum() {
  var uuid = Uuid();
  String finalRandom =
      uuid.v4(options: {'date': DateTime.now().toIso8601String()});
  return finalRandom;
}
