import 'package:flutter/material.dart';

class ChooseModeScreen extends StatelessWidget {
  const ChooseModeScreen({super.key});

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
