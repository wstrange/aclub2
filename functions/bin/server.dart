import 'package:firebase_functions/firebase_functions.dart';
import 'package:aclub_functions/functions.dart';

Future<void> main(List<String> args) async {
  await runFunctions(registerFunctions);
}