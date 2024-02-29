import 'dart:typed_data';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_server_driven_ui/presentation/choose_mode/choose_mode.dart';
import 'package:flutter_server_driven_ui/src/utils/mrtd.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatelessWidget {
  final MrtdData? mrtdData;
  final String id;
  const ResultScreen({
    super.key,
    required this.mrtdData,
    required this.id,
  });

  int findSequence(Uint8List data, Uint8List sequence) {
    final MRZ? x = mrtdData?.dg1?.mrz;
    debugPrint(x.toString());
    for (int i = 0; i < data.length - sequence.length; i++) {
      bool found = true;
      for (int j = 0; j < sequence.length; j++) {
        if (data[i + j] != sequence[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  Uint8List? getJpegIm(Uint8List efDg2) {
    // Find the start of the JPEG image
    int imStart =
        findSequence(efDg2, Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]));
    if (imStart == -1) {
      imStart = findSequence(
          efDg2, Uint8List.fromList([0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50]));
    }

    // If the sequence was not found, return null or throw an error
    if (imStart == -1) {
      return null;
      // or throw Exception('JPEG image not found');
    }

    // Get the image bytes
    Uint8List image = efDg2.sublist(imStart);

    return image;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
// back to ChooseModeScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChooseModeScreen()),
                  (Route<dynamic> route) => false,
                );
              }),
          title: const Text('Result'),
          //
          actions: [],
        ),
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.memory(getJpegIm(mrtdData!.dg2!.toBytes())!),
            ),
            if (mrtdData!.dg1 != null)
              // Text(formatMRZ(mrtdData!.dg1!.mrz)),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    InfoRow(
                      label: 'firstName',
                      value: mrtdData!.dg1!.mrz.firstName,
                    ),
                    InfoRow(
                      label: 'lastName',
                      value: mrtdData!.dg1!.mrz.lastName,
                    ),
                    InfoRow(
                      label: 'Ngày sinh',
                      value: DateFormat('dd/MM/yy')
                          .format(mrtdData!.dg1!.mrz.dateOfBirth),
                    ),
                    InfoRow(
                      label: 'Ngày hết hạn thẻ',
                      value: DateFormat('dd/MM/yy')
                          .format(mrtdData!.dg1!.mrz.dateOfExpiry),
                    ),
                    InfoRow(
                      label: 'Giới tính',
                      value: mrtdData!.dg1!.mrz.gender == 'M' ? 'Nam' : 'Nữ',
                    ),
                    InfoRow(
                      label: 'Quốc tịch',
                      value: mrtdData!.dg1!.mrz.nationality == 'VNM'
                          ? 'Việt Nam'
                          : 'Nước Ngoài',
                    ),
                    InfoRow(
                      label: 'Số căn cước',
                      value: id,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        const SizedBox(
          width: 50,
        ),
        Text(value),
      ],
    );
  }
}
