import 'dart:async';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_server_driven_ui/presentation/nfc_screen/nfc_screen.dart';
import 'package:intl/intl.dart';

class TypeInfoScreen extends StatefulWidget {
  const TypeInfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TypeInfoScreenState createState() => _TypeInfoScreenState();
}

class _TypeInfoScreenState extends State<TypeInfoScreen> {
  var _isNfcAvailable = false;
  var _isReading = false;
  final _mrzData = GlobalKey<FormState>();

  // mrz data
  final _docNumber = TextEditingController();
  final _dob = TextEditingController(); // date of birth
  final _doe = TextEditingController(); // date of doc expiry
  // ignore: unused_field
  late Timer _timerStateUpdater;
  final _scrollController = ScrollController();

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

  DateTime? _getDOBDate() {
    if (_dob.text.isEmpty) {
      return null;
    }
    print(_dob.text);

    return DateFormat.yMd().parse(_dob.text);
  }

  DateTime? _getDOEDate() {
    if (_doe.text.isEmpty) {
      return null;
    }
    print(_doe.text);
    return DateFormat.yMd().parse(_doe.text);
  }

  Future<String?> _pickDate(BuildContext context, DateTime firstDate,
      DateTime initDate, DateTime lastDate) async {
    final locale = Localizations.localeOf(context);
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: firstDate,
        initialDate: initDate,
        lastDate: lastDate,
        locale: locale);

    if (picked != null) {
      return DateFormat.yMd().format(picked);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
        builder: (BuildContext context) => _buildPage(context));
  }

  bool _disabledInput() {
    return _isReading || !_isNfcAvailable;
  }

  PlatformScaffold _buildPage(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Type Info'),
          leading: PlatformIconButton(
            icon: Icon(context.platformIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        iosContentPadding: false,
        iosContentBottomPadding: false,
        body: Material(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Row(
                    //   children: <Widget>[
                    //     const Text(
                    //       'NFC available:',
                    //       style: TextStyle(
                    //         fontSize: 18.0,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(_isNfcAvailable ? "Yes" : "No",
                    //         style: const TextStyle(fontSize: 18.0))
                    //   ],
                    // ),
                    const SizedBox(height: 40),
                    _buildForm(context),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _disabledInput() || !_mrzData.currentState!.validate()
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NFCScreen(
                                        id: _docNumber.text,
                                        dob: _dob.text,
                                        doe: _doe.text,
                                      ),
                                    ),
                                  );
                                  // ReadMRTD.readmrtd(
                                  //   context,
                                  //   _docNumber.text,
                                  //   _dob.text,
                                  //   _doe.text,
                                  // );
                                  return;
                                },
                      child: PlatformText(
                        _isReading ? 'Reading ...' : 'Read ID',
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Padding _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Form(
        key: _mrzData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              enabled: !_disabledInput(),
              controller: _docNumber,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Căn cước công dân',
                  fillColor: Colors.white),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]+')),
                LengthLimitingTextInputFormatter(14)
              ],
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  //  here`
                  // _docNumber.text = '054199009176';
                  // _dob.text = '05/09/1999';
                  // _doe.text = '05/09/2024';
                  _docNumber.text = '020099000036';
                  _dob.text = '12/21/1999';
                  _doe.text = '12/21/2024';
                  return 'Số căn cước công dân không thể trống';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
                enabled: !_disabledInput(),
                controller: _dob,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ngày tháng năm sinh',
                    fillColor: Colors.white),
                autofocus: false,
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return 'Ngày tháng năm sinh không thể trống';
                  }
                  return null;
                },
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  // Can pick date which dates 15 years back or more
                  final now = DateTime.now();
                  final firstDate = DateTime(now.year - 90, now.month, now.day);
                  final lastDate = DateTime(now.year - 15, now.month, now.day);
                  final initDate = _getDOBDate();
                  final date = await _pickDate(
                      context, firstDate, initDate ?? lastDate, lastDate);

                  FocusScope.of(context).requestFocus(FocusNode());
                  if (date != null) {
                    _dob.text = date;
                  }
                }),
            const SizedBox(height: 12),
            TextFormField(
              enabled: !_disabledInput(),
              controller: _doe,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ngày hết hạn ',
                  fillColor: Colors.white),
              autofocus: false,
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Ngày hết hạn không thể trống';
                }
                return null;
              },
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                // Can pick date from tomorrow and up to 10 years
                final now = DateTime.now();
                final firstDate = DateTime(now.year, now.month, now.day + 1);
                final lastDate =
                    DateTime(now.year + 50, now.month + 6, now.day);
                final initDate = _getDOEDate();
                final date = await _pickDate(
                    context, firstDate, initDate ?? firstDate, lastDate);

                FocusScope.of(context).requestFocus(FocusNode());
                if (date != null) {
                  _doe.text = date;
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // Widget _makeMrtdDataWidget({
  //   required String header,
  //   required String collapsedText,
  //   required dataText,
  //   Uint8List? image,
  // }) {
  //   int findSequence(Uint8List data, Uint8List sequence) {
  //     for (int i = 0; i < data.length - sequence.length; i++) {
  //       bool found = true;
  //       for (int j = 0; j < sequence.length; j++) {
  //         if (data[i + j] != sequence[j]) {
  //           found = false;
  //           break;
  //         }
  //       }
  //       if (found) return i;
  //     }
  //     return -1;
  //   }

  //   Uint8List? getJpegIm(Uint8List efDg2) {
  //     // Find the start of the JPEG image
  //     int imStart =
  //         findSequence(efDg2, Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]));
  //     if (imStart == -1) {
  //       imStart = findSequence(
  //           efDg2, Uint8List.fromList([0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50]));
  //     }

  //     // If the sequence was not found, return null or throw an error
  //     if (imStart == -1) {
  //       return null;
  //       // or throw Exception('JPEG image not found');
  //     }

  //     // Get the image bytes
  //     Uint8List image = efDg2.sublist(imStart);

  //     return image;
  //   }

  //   final iamge = image != null ? getJpegIm(image!) : null;
  //   return ExpandablePanel(
  //     theme: const ExpandableThemeData(
  //       headerAlignment: ExpandablePanelHeaderAlignment.center,
  //       tapBodyToCollapse: true,
  //       hasIcon: true,
  //       iconColor: Colors.red,
  //     ),
  //     header: Text(header),
  //     collapsed: Text(collapsedText,
  //         softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
  //     expanded: Container(
  //       padding: const EdgeInsets.all(18),
  //       color: const Color.fromARGB(255, 239, 239, 239),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           if (iamge != null) Image.memory(iamge),
  //           if (iamge == null)
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 PlatformTextButton(
  //                   child: const Text('Copy'),
  //                   onPressed: () =>
  //                       Clipboard.setData(ClipboardData(text: dataText)),
  //                   padding: const EdgeInsets.all(8),
  //                 ),
  //                 SelectableText(
  //                   dataText,
  //                   textAlign: TextAlign.left,
  //                 )
  //               ],
  //             )
  //         ],
  //       ),
  //     ),
  //   );
  // }

//   List<Widget> _mrtdDataWidgets() {
//     List<Widget> list = [];
//     if (_mrtdData == null) return list;

//     if (_mrtdData!.cardAccess != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.CardAccess',
//           collapsedText: '',
//           dataText: _mrtdData!.cardAccess!.toBytes().hex()));
//     }

//     if (_mrtdData!.cardSecurity != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.CardSecurity',
//           collapsedText: '',
//           dataText: _mrtdData!.cardSecurity!.toBytes().hex()));
//     }

//     if (_mrtdData!.sod != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.SOD',
//           collapsedText: '',
//           dataText: _mrtdData!.sod!.toBytes().hex()));
//     }

//     if (_mrtdData!.com != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.COM',
//           collapsedText: '',
//           dataText: formatEfCom(_mrtdData!.com!)));
//     }

//     if (_mrtdData!.dg1 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG1',
//           collapsedText: '',
//           dataText: formatMRZ(_mrtdData!.dg1!.mrz)));
//     }

//     if (_mrtdData!.dg2 != null) {
// // here
//       list.add(
//         _makeMrtdDataWidget(
//           header: 'EF.DG2',
//           collapsedText: '',
//           dataText: _mrtdData!.dg2!.toBytes().hex(),
//           image: _mrtdData!.dg2!.toBytes(),
//           // test: _mrtdData!.dg2!.toBytes(),
//         ),
//       );
//     }

//     if (_mrtdData!.dg3 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG3',
//           collapsedText: '',
//           dataText: _mrtdData!.dg3!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg4 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG4',
//           collapsedText: '',
//           dataText: _mrtdData!.dg4!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg5 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG5',
//           collapsedText: '',
//           dataText: _mrtdData!.dg5!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg6 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG6',
//           collapsedText: '',
//           dataText: _mrtdData!.dg6!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg7 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG7',
//           collapsedText: '',
//           dataText: _mrtdData!.dg7!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg8 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG8',
//           collapsedText: '',
//           dataText: _mrtdData!.dg8!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg9 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG9',
//           collapsedText: '',
//           dataText: _mrtdData!.dg9!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg10 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG10',
//           collapsedText: '',
//           dataText: _mrtdData!.dg10!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg11 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG11',
//           collapsedText: '',
//           dataText: _mrtdData!.dg11!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg12 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG12',
//           collapsedText: '',
//           dataText: _mrtdData!.dg12!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg13 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG13',
//           collapsedText: '',
//           dataText: _mrtdData!.dg13!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg14 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG14',
//           collapsedText: '',
//           dataText: _mrtdData!.dg14!.toBytes().hex()));
//     }

//     if (_mrtdData!.dg15 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG15',
//           collapsedText: '',
//           dataText: _mrtdData!.dg15!.toBytes().hex()));
//     }

//     if (_mrtdData!.aaSig != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'Active Authentication signature',
//           collapsedText: '',
//           dataText: _mrtdData!.aaSig!.hex()));
//     }

//     if (_mrtdData!.dg16 != null) {
//       list.add(_makeMrtdDataWidget(
//           header: 'EF.DG16',
//           collapsedText: '',
//           dataText: _mrtdData!.dg16!.toBytes().hex()));
//     }

//     return list;
//   }
}
