// import 'dart:math';

// // import 'package:flutter_server_driven_ui/home_page.dart';
// // import 'package:flutter_server_driven_ui/home_page_2.dart';
// import 'package:flutter_server_driven_ui/nfc_reader.dart';
// import 'package:json_dynamic_widget/json_dynamic_widget.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final registry = JsonWidgetRegistry.instance;

//   registry.registerFunctions({
//     'simplePrintMessage': ({args, required registry}) => () {
//           var message = 'This is a simple print message';
//           if (args?.isEmpty == false) {
//             for (var arg in args!) {
//               message += ' $arg';
//             }
//           }
//           // ignore: avoid_print
//           print(message);
//         },
//     // 'updateCustomBg': ({args, required registry}) => () {
//     //       registry.setValue(
//     //         'customBg',
//     //         Colors.yellow,
//     //       );
//     //     },
//     'updateCustomBg': ({args, required registry}) => () {
//           final id = Random().nextInt(9);
//           // print('Button đang đc chọn: ${id + 1}');
//           registry.setValue(
//             'customBg${id + 1}',
//             Color.fromRGBO(
//               Random().nextInt(255),
//               Random().nextInt(255),
//               Random().nextInt(255),
//               1,
//             ),
//           );
//         },
//   });

//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: NFCReaderWidget(),
//       // home: GridViewButtonsPage(),
//     );
//   }
// }
