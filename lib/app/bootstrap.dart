import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Touch secure storage early so MethodChannel is ready on Android.
  const FlutterSecureStorage();
}
