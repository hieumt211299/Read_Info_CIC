import 'dart:async';

import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_server_driven_ui/presentation/result/result_screen.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../../src/utils/mrtd.dart';
import '../type_info/formats/formats.dart';

class NFCScreen extends StatefulWidget {
  final String id;
  final String dob;
  final String doe;
  const NFCScreen(
      {super.key, required this.id, required this.dob, required this.doe});

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  var _alertMessage = "";
  final _log = Logger("mrtdeg.app");
  var _isNfcAvailable = false;
  var _isReading = false;

  MrtdData? _mrtdData;

  final NfcProvider _nfc = NfcProvider();
  // ignore: unused_field
  late Timer _timerStateUpdater;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _initPlatformState();

    // Update platform state every 3 sec
    _timerStateUpdater = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _initPlatformState();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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

  DateTime? _getDate(String day) {
    if (day.isEmpty) {
      return null;
    }

    return DateFormat.yMd().parse(day);
  }

  bool _disabledInput() {
    return _isReading || !_isNfcAvailable;
  }

  Future<void> _readMRTD() async {
    try {
      setState(() {
        _mrtdData = null;
        _alertMessage = "Waiting for ID tag ...";
        _isReading = true;
      });
      await _nfc.connect(iosAlertMessage: "Hold your phone near Biometric ID");
      final passport = Passport(_nfc);
      setState(() {
        _alertMessage = "Reading ID ...";
      });
      setState(() {
        _alertMessage = "Trying to read EF.CardAccess ...";
      });
      _nfc.setIosAlertMessage("Trying to read EF.CardAccess ...");

      final mrtdData = MrtdData();
      try {
        mrtdData.cardAccess = await passport.readEfCardAccess();
      } on PassportError {
        //if (e.code != StatusWord.fileNotFound) rethrow;
      }
      _nfc.setIosAlertMessage("Trying to read EF.CardSecurity ...");
      setState(() {
        _alertMessage = "Trying to read EF.CardSecurity ...";
      });
      try {
        mrtdData.cardSecurity = await passport.readEfCardSecurity();
      } on PassportError {
        //if (e.code != StatusWord.fileNotFound) rethrow;
      }
      _nfc.setIosAlertMessage("Initiating session ...");
      setState(() {
        _alertMessage = "Initiating session ...";
      });
      final bacKeySeed =
          DBAKeys(widget.id, _getDate(widget.dob)!, _getDate(widget.doe)!);
      await passport.startSession(bacKeySeed);

      _nfc.setIosAlertMessage(
          Fortmats.formatProgressMsg("Reading EF.COM ...", 0));
      setState(() {
        _alertMessage = "Reading EF.COM ...";
      });
      mrtdData.com = await passport.readEfCOM();

      _nfc.setIosAlertMessage(
          Fortmats.formatProgressMsg("Reading Data Groups ...", 20));
      setState(() {
        _alertMessage = "Reading Data Groups ...";
      });
      if (mrtdData.com!.dgTags.contains(EfDG1.TAG)) {
        mrtdData.dg1 = await passport.readEfDG1();
      }

      if (mrtdData.com!.dgTags.contains(EfDG2.TAG)) {
        mrtdData.dg2 = await passport.readEfDG2();
      }
      setState(() {
        _mrtdData = mrtdData;
        _alertMessage = "";
      });
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              mrtdData: _mrtdData,
              id: widget.id,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      final se = e.toString().toLowerCase();
      String alertMsg = "An error has occurred while reading Passport!";
      if (e is PassportError) {
        if (se.contains("security status not satisfied")) {
          alertMsg =
              "Failed to initiate session with passport.\nCheck input data!";
        }
        _log.error("PassportError: ${e.message}");
      } else {
        _log.error("An exception was encountered while trying to read ID: $e");
      }

      if (se.contains('timeout')) {
        alertMsg = "Timeout while waiting for Passport tag";
      } else if (se.contains("tag was lost")) {
        alertMsg = "Tag was lost. Please try again!";
      } else if (se.contains("invalidated by user")) {
        alertMsg = "";
      }

      setState(() {
        _alertMessage = alertMsg;
      });
    } finally {
      if (_alertMessage.isNotEmpty) {
        await _nfc.disconnect(iosErrorMessage: _alertMessage);
      } else {
        await _nfc.disconnect(
            iosAlertMessage: Fortmats.formatProgressMsg("Finished", 100));
      }
      setState(() {
        _isReading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader Screen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('NFC reader ready to scan!'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _disabledInput() ? null : _readMRTD,
                child: PlatformText(_isReading ? 'Reading ...' : 'Read ID'),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(_alertMessage),
            ],
          ),
        ),
      ),
    );
  }
}
