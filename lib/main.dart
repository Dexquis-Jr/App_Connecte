import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injector.dart';
import 'core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();
  Injector.setup();
  runApp(const MovieApp());
}
