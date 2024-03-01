import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ChooseModeScreen extends StatelessWidget {
  const ChooseModeScreen({super.key});
  Future<String> checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      // NFC is not available on the device.
      return 'NFC is not available on this device.';
    } else {
      // NFC is available on the device.
      return 'NFC is available on this device.';
    }
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
            FutureBuilder(
              future: checkNfcAvailability(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Checking NFC availability...');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('NFC is available and enabled.');
                }
              },
            ),
            ElevatedButton(
              // onTap: () => Navigator.of(context).pushNamed('/type-info'),
              onPressed: () {
                Navigator.of(context).pushNamed('/type_info');
              },
              child: const Text('Type Info'),
            ),
            ElevatedButton(
              // onTap: () => Navigator.of(context).pushNamed('/scan-mrz'),
              onPressed: () {
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
