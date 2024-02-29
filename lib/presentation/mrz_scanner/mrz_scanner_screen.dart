import 'package:flutter/material.dart';
import 'mrz_scanner.dart';

class MRZScanScreen extends StatefulWidget {
  const MRZScanScreen({super.key});

  @override
  State<MRZScanScreen> createState() => _MRZScanScreenState();
}

class _MRZScanScreenState extends State<MRZScanScreen> {
  final MRZController controller = MRZController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return MRZScanner(
            controller: controller,
            onSuccess: (mrzResult, lines) async {
              // await showDialog(
              //   context: context,
              //   builder: (context) => Dialog(
              //     insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: SingleChildScrollView(
              //       padding: const EdgeInsets.all(10),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           TextButton(
              //             onPressed: () {
              //               Navigator.pop(context);
              //               controller.currentState?.resetScanning();
              //             },
              //             child: const Text('Reset Scanning'),
              //           ),
              //           Text(mrzResult.toString()),
              //           // Text('Name : ${mrzResult.givenNames}'),
              //           // Text('Gender : ${mrzResult.sex.name}'),
              //           // Text('CountryCode : ${mrzResult.countryCode}'),
              //           // Text('Date of Birth : ${mrzResult.birthDate}'),
              //           // Text('Expiry Date : ${mrzResult.expiryDate}'),
              //           // Text('DocNum : ${mrzResult.documentNumber}'),
              //         ],
              //       ),
              //     ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}
