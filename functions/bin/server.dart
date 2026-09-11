import 'package:functions_framework/serve.dart';
import 'package:aclub_admin/functions.dart';

final Map<String, FunctionTarget> nameToFunctionTargets = {
  'helloWorld': FunctionTarget.http(
    helloWorld,
  ),
  'adminSeed': FunctionTarget.http(
    adminSeed,
  ),
  'adminStats': FunctionTarget.http(
    adminStats,
  ),
};

Future<void> main(List<String> args) async {
  await serve(args, (name) => nameToFunctionTargets[name]);
}
