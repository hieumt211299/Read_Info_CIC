// import 'dart:async';

// import 'package:dmrtd/dmrtd.dart';
// import 'package:dmrtd/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_server_driven_ui/presentation/result/result_screen.dart';
// import 'package:flutter_server_driven_ui/presentation/type_info/formats/formats.dart';
// import 'package:flutter_server_driven_ui/src/utils/mrtd.dart';
// import 'package:intl/intl.dart';
// import 'package:logging/logging.dart';

// class ReadMRTDScreen extends StatefulWidget {
//   final String id;
//   final String dob;
//   final String doe;
//   const ReadMRTDScreen(
//       {super.key, required this.id, required this.dob, required this.doe});

//   @override
//   State<ReadMRTDScreen> createState() => _ReadMRTDScreenState();
// }

// class _ReadMRTDScreenState extends State<ReadMRTDScreen> {
//   final NfcProvider _nfc = NfcProvider();
//   MrtdData? _mrtdData;
//   var _alertMessage = "";
//   final _log = Logger("mrtdeg.app");
//   var _isReading = false;

//   DateTime? _getDate(String day) {
//     if (day.isEmpty) {
//       return null;
//     }

//     return DateFormat.yMd().parse(day);
//   }

//   Future<void> readMRTD() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Center(
//               child: AlertDialog(
//                 content: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Text(_alertMessage),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//     try {
//       setState(() {
//         _mrtdData = null;
//         _alertMessage = "Waiting for ID tag ...";

//         _isReading = true;
//       });
//       await _nfc.connect(iosAlertMessage: "Hold your phone near Biometric ID");
//       final passport = Passport(_nfc);
//       setState(() {
//         _alertMessage = "Reading ID ...";
//       });
//       final mrtdData = MrtdData();

//       _nfc.setIosAlertMessage("Trying to read EF.CardAccess ...");
//       setState(() {
//         _alertMessage = "Trying to read EF.CardAccess ...";
//       });
//       try {
//         mrtdData.cardAccess = await passport.readEfCardAccess();
//       } on PassportError {
//         //if (e.code != StatusWord.fileNotFound) rethrow;
//       }
//       _nfc.setIosAlertMessage("Trying to read EF.CardSecurity ...");
//       setState(() {
//         _alertMessage = "Trying to read EF.CardSecurity ...";
//       });
//       try {
//         mrtdData.cardSecurity = await passport.readEfCardSecurity();
//       } on PassportError {
//         //if (e.code != StatusWord.fileNotFound) rethrow;
//       }
//       _nfc.setIosAlertMessage("Initiating session ...");
//       setState(() {
//         _alertMessage = "Initiating session ...";
//       });
//       final bacKeySeed =
//           DBAKeys(widget.id, _getDate(widget.dob)!, _getDate(widget.doe)!);
//       await passport.startSession(bacKeySeed);

//       _nfc.setIosAlertMessage(
//           Fortmats.formatProgressMsg("Reading EF.COM ...", 0));
//       setState(() {
//         _alertMessage = "Reading EF.COM ...";
//       });
//       mrtdData.com = await passport.readEfCOM();

//       _nfc.setIosAlertMessage(
//           Fortmats.formatProgressMsg("Reading Data Groups ...", 20));
//       setState(() {
//         _alertMessage = "Reading Data Groups ...";
//       });
//       if (mrtdData.com!.dgTags.contains(EfDG1.TAG)) {
//         mrtdData.dg1 = await passport.readEfDG1();
//       }

//       if (mrtdData.com!.dgTags.contains(EfDG2.TAG)) {
//         mrtdData.dg2 = await passport.readEfDG2();
//       }
//       setState(() {
//         _mrtdData = mrtdData;
//         _alertMessage = "";
//       });
//       if (context.mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResultScreen(
//               mrtdData: _mrtdData,
//               id: widget.id,
//             ),
//           ),
//         );
//       }
//     } on Exception catch (e) {
//       final se = e.toString().toLowerCase();
//       String alertMsg = "An error has occurred while reading Passport!";
//       if (e is PassportError) {
//         if (se.contains("security status not satisfied")) {
//           alertMsg =
//               "Failed to initiate session with passport.\nCheck input data!";
//         }
//         _log.error("PassportError: ${e.message}");
//       } else {
//         _log.error("An exception was encountered while trying to read ID: $e");
//       }

//       if (se.contains('timeout')) {
//         alertMsg = "Timeout while waiting for Passport tag";
//       } else if (se.contains("tag was lost")) {
//         alertMsg = "Tag was lost. Please try again!";
//       } else if (se.contains("invalidated by user")) {
//         alertMsg = "";
//       }

//       setState(() {
//         _alertMessage = alertMsg;
//       });
//     } finally {
//       if (_alertMessage.isNotEmpty) {
//         await _nfc.disconnect(iosErrorMessage: _alertMessage);
//       } else {
//         await _nfc.disconnect(
//             iosAlertMessage: Fortmats.formatProgressMsg("Finished", 100));
//       }
//       setState(() {
//         _isReading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Read MRTD'),
//       ),
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             children: <Widget>[
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isReading ? null : readMRTD,
//                 child: const Text('Read MRTD'),
//               ),
//               const SizedBox(height: 20),
//               if (_alertMessage.isNotEmpty)
//                 Text(
//                   _alertMessage,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
