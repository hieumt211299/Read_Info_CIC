// import 'package:flutter_server_driven_ui/nfc_reader.dart';

// class ApduCommand {
//   int class_;
//   int instruction;
//   int p1;
//   int p2;
//   List<int>? data;

//   ApduCommand({
//     required this.class_,
//     required this.instruction,
//     required this.p1,
//     required this.p2,
//     this.data,
//   });

//   List<int> getForTransceive() {
//     if (data != null) {
//       return [
//         class_,
//         instruction,
//         p1,
//         p2,
//         data!.length,
//         ...data!,
//         0x00,
//       ];
//     }

//     return [class_, instruction, p1, p2, 0x00];
//   }

//   @override
//   String toString() {
//     return '>>> ' + toHexString(getForTransceive());
//   }

//   static ApduCommand getPPSE() {
//     return getApplication([
//       0x32,
//       0x50,
//       0x41,
//       0x59,
//       0x2e,
//       0x53,
//       0x59,
//       0x53,
//       0x2e,
//       0x44,
//       0x44,
//       0x46,
//       0x30,
//       0x31,
//     ]);
//   }

//   static ApduCommand getApplication(List<int> aid) {
//     return ApduCommand(
//         class_: 0x00, instruction: 0xa4, p1: 0x04, p2: 0x00, data: aid);
//   }

//   static ApduCommand getProcessingOptions(List<int> pdolValue) {
//     return ApduCommand(
//         class_: 0x80, instruction: 0xa8, p1: 0x00, p2: 0x00, data: pdolValue);
//   }

//   static ApduCommand readRecord(int sfi, int record) {
//     return ApduCommand(
//         class_: 0x00, instruction: 0xb2, p1: record, p2: sfi + 4);
//   }
// }
