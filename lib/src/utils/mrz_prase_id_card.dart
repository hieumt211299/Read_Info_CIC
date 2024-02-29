class MRZPraseIDCard {
  String type;
  String country1;
  String shortID;
  String id;
  String dob;
  String gender;
  String doe;
  String country2;

  MRZPraseIDCard({
    required this.type,
    required this.country1,
    required this.shortID,
    required this.id,
    required this.dob,
    required this.gender,
    required this.doe,
    required this.country2,
  });

  // toString() method
  @override
  String toString() {
    return 'MRZPraseIDCard{type: $type, country1: $country1, shortID: $shortID, id: $id, dob: $dob, gender: ${(gender == 'M' ? 'Nam' : 'Nữ')}, doe: $doe, country2: $country2';
  }

  int fieldLength(String fieldName) {
    switch (fieldName) {
      case 'type':
        return 2;
      case 'country':
        return 3;
      case 'shortID':
        return 9;
      case 'id':
        return 12;
      case 'day':
        return 6;
      case 'gender':
        return 1;
      default:
        throw Exception('Invalid field name');
    }
  }
}
