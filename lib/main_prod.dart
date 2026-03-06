import 'package:uangku/core/config/app_config.dart';
import 'package:uangku/main.dart';

// TODO: Run 'flutterfire configure' for prod and import the generated options.
// import 'package:uangku/firebase_options_prod.dart';

void main() {
  mainRunner(Environment.prod, null); // Pass Prod options when available.
}
