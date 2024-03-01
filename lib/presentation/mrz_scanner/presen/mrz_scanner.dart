import 'dart:async';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_server_driven_ui/presentation/nfc_screen/nfc_screen.dart';
import 'package:flutter_server_driven_ui/src/utils/mrz_prase_id_card.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import '../mrz_scanner.dart';
import 'camera_view.dart';

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
  }) : super(key: controller);
  final Function(MRZResult mrzResult, List<String> lines) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
  @override
  // ignore: library_private_types_in_public_api
  MRZScannerState createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  var _isNfcAvailable = false;
  var _isReading = false;
  // ignore: unused_field
  late Timer _timerStateUpdater;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  List result = [];

  void resetScanning() => _isBusy = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPlatformState();
    _timerStateUpdater = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _initPlatformState();
    });
  }

  Future<void> _initPlatformState() async {
    bool isNfcAvailable;
    try {
      NfcStatus status = await NfcProvider.nfcStatus;
      isNfcAvailable = status == NfcStatus.enabled;
    } on PlatformException {
      isNfcAvailable = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isNfcAvailable = isNfcAvailable;
    });
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MRZCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      onImage: _processImage,
    );
  }

  // void _parseScannedText(List<String> lines) {
  //   try {
  //     final data = MRZParser.parse(lines);
  //     _isBusy = true;

  //     widget.onSuccess(data, lines);
  //   } catch (e) {
  //     _isBusy = false;
  //   }
  // }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final recognizedText = await _textRecognizer.processImage(inputImage);
    String fullText = recognizedText.text;
    String trimmedText = fullText.replaceAll(' ', '');
    // List allText = trimmedText.split('\n');
    print(trimmedText);
    //
    int startIndex = trimmedText.indexOf("IDVNM");
    int endIndex = trimmedText.indexOf("VNM<<<<");
    if (startIndex != -1 && endIndex != -1) {
      String test;
      try {
        test = trimmedText.substring(startIndex, endIndex + 5).trim();
        _isBusy = await _verifyMRZ(test);
      } catch (e) {}
    } else {
      print("IDVNM not found in the text");
      _isBusy = false;
    }
  }

  Future<bool> _verifyMRZ(String recognizedText) async {
    _isBusy = true;
    String _text = recognizedText;
    MRZPraseIDCard _mrzParseIdCard = MRZPraseIDCard(
      type: '',
      country1: '',
      shortID: '',
      id: '',
      dob: '',
      gender: '',
      doe: '',
      country2: '',
    );

    String getData(String filedName, [int extraLength = 0]) {
      String data = _text.substring(0, _mrzParseIdCard.fieldLength(filedName));
      _text =
          _text.substring(_mrzParseIdCard.fieldLength(filedName) + extraLength);
      return data;
    }

    try {
      _mrzParseIdCard.type = getData('type');
      _mrzParseIdCard.country1 = getData('country');
      _mrzParseIdCard.shortID = getData('shortID', 1);
      _mrzParseIdCard.id = getData('id', 4);
      _mrzParseIdCard.dob = getData('day', 1);
      _mrzParseIdCard.gender = getData('gender');
      _mrzParseIdCard.doe = getData('day', 1);
      _mrzParseIdCard.country2 = getData('country');
      if (_mrzParseIdCard.country1 == _mrzParseIdCard.country2 &&
          _mrzParseIdCard.type == "ID") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NFCScreen(
              id: _mrzParseIdCard.id,
              dob: _parseDateTime(_mrzParseIdCard.dob),
              doe: _parseDateTime(_mrzParseIdCard.doe),
            ),
          ),
        );

        _canProcess = false;
        _textRecognizer.close();
        return true;
        // ReadMRTD.readmrtd(
        //   context,
        //   _mrzParseIdCard.id,
        //   _parseDateTime(_mrzParseIdCard.dob),
        //   _parseDateTime(_mrzParseIdCard.doe),
        // );
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Hãy thử lại'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  String _parseDateTime(String day) {
    String year = day.substring(0, 2);
    year = int.parse(year) < 50 ? "20$year" : "19$year";
    day = year + day.substring(2);
    DateTime dateTime = DateTime.parse(day);

    String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);
    return formattedDate;
  }
}
