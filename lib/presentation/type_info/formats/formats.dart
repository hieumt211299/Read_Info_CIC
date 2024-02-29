import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:flutter_server_driven_ui/src/utils/dg_tag.dart';
import 'package:intl/intl.dart';

class Fortmats {
  static String formatEfCom(final EfCOM efCom) {
    var str = "version: ${efCom.version}\n"
        "unicode version: ${efCom.unicodeVersion}\n"
        "DG tags:";

    for (final t in efCom.dgTags) {
      try {
        str += " ${dgTagToString[t]!}";
      } catch (e) {
        str += " 0x${t.value.toRadixString(16)}";
      }
    }
    return str;
  }

  static String formatMRZ(final MRZ mrz) {
    return "MRZ\n"
            "  version: ${mrz.version}\n" +
        "  doc code: ${mrz.documentCode}\n" +
        "  doc No.: ${mrz.documentNumber}\n" +
        "  country: ${mrz.country}\n" +
        "  nationality: ${mrz.nationality}\n" +
        "  name: ${mrz.firstName}\n" +
        "  surname: ${mrz.lastName}\n" +
        "  gender: ${mrz.gender}\n" +
        "  date of birth: ${DateFormat.yMd().format(mrz.dateOfBirth)}\n" +
        "  date of expiry: ${DateFormat.yMd().format(mrz.dateOfExpiry)}\n" +
        "  add. data: ${mrz.optionalData}\n" +
        "  add. data: ${mrz.optionalData2}";
  }

  static String formatDG15(final EfDG15 dg15) {
    var str = "EF.DG15:\n"
        "  AAPublicKey\n"
        "    type: ";

    final rawSubPubKey = dg15.aaPublicKey.rawSubjectPublicKey();
    if (dg15.aaPublicKey.type == AAPublicKeyType.RSA) {
      final tvSubPubKey = TLV.fromBytes(rawSubPubKey);
      var rawSeq = tvSubPubKey.value;
      if (rawSeq[0] == 0x00) {
        rawSeq = rawSeq.sublist(1);
      }

      final tvKeySeq = TLV.fromBytes(rawSeq);
      final tvModule = TLV.decode(tvKeySeq.value);
      final tvExp = TLV.decode(tvKeySeq.value.sublist(tvModule.encodedLen));

      str += "RSA\n"
          "    exponent: ${tvExp.value.hex()}\n"
          "    modulus: ${tvModule.value.hex()}";
    } else {
      str += "EC\n    SubjectPublicKey: ${rawSubPubKey.hex()}";
    }
    return str;
  }

  static String formatProgressMsg(String message, int percentProgress) {
    final p = (percentProgress / 20).round();
    final full = "🟢 " * p;
    final empty = "⚪️ " * (5 - p);
    return message + "\n\n" + full + empty;
  }
}
