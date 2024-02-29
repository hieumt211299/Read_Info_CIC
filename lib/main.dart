// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_server_driven_ui/presentation/choose_mode/choose_mode.dart';
import 'package:flutter_server_driven_ui/presentation/type_info/type_info_screen.dart';
import 'package:flutter_server_driven_ui/presentation/result/result_screen.dart';
import 'package:logging/logging.dart';

import 'presentation/mrz_scanner/mrz_scanner_screen.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const MrtdEgApp());
}

class MrtdEgApp extends StatelessWidget {
  const MrtdEgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      material: (_, __) => MaterialAppData(),
      cupertino: (_, __) => CupertinoAppData(),
      home: const ChooseModeScreen(),
      routes: <String, WidgetBuilder>{
        '/type_info': (BuildContext context) => const TypeInfoScreen(),
        '/scan_mrz': (BuildContext context) => const MRZScanScreen(),
        // result screen
      },
    );
  }
}
