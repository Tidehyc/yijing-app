import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'src/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(dbHelper)],
      child: const YijingApp(),
    ),
  );
}
