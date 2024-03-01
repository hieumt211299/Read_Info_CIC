import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ChooseModeScreen extends StatefulWidget {
  const ChooseModeScreen({super.key});

  @override
  State<ChooseModeScreen> createState() => _ChooseModeScreenState();
}

class _ChooseModeScreenState extends State<ChooseModeScreen> {
  bool isNfcAvailable = false;
  @override
  initState() {
    super.initState();
    checkNfcAvailability();
  }

  Future<void> checkNfcAvailability() async {
    final checkNFC = await NfcManager.instance.isAvailable();
    setState(() {
      isNfcAvailable = checkNFC;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Choose Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isNfcAvailable
                ? Text('Your device\'s NFC is available')
                : Text('Your device\'s NFC isn\' available'),
            ElevatedButton(
              // onTap: () => Navigator.of(context).pushNamed('/type-info'),
              onPressed: !isNfcAvailable
                  ? null
                  : () {
                      Navigator.of(context).pushNamed('/type_info');
                    },
              child: const Text('Type Info'),
            ),
            ElevatedButton(
              // onTap: () => Navigator.of(context).pushNamed('/scan-mrz'),
              onPressed: !isNfcAvailable
                  ? null
                  : () {
                      Navigator.of(context).pushNamed('/scan_mrz');
                    },
              child: const Text('Scan MRZ'),
            ),
          ],
        ),
      ),
    ));
  }
}
