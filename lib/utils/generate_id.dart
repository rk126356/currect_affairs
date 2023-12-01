import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

String generateQuizID() {
  const uuid = Uuid();
  final randomNumbers = uuid.v4().replaceAll('-', '').substring(0, 8);
  if (kDebugMode) {
    print(randomNumbers);
  }
  return randomNumbers;
}
