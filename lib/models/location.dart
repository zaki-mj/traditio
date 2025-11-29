// models/location_models.dart

class City {
  final String nameAR;
  final String nameFR;

  City({required this.nameAR, required this.nameFR});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(nameAR: json['name_ar'] as String, nameFR: json['name_fr'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name_ar': nameAR, 'name_fr': nameFR};
  }
}

class Wilaya {
  final String code;
  final String nameAR;
  final String nameFR;
  final List<City> cities;

  Wilaya({required this.code, required this.nameAR, required this.nameFR, required this.cities});

  factory Wilaya.fromJson(Map<String, dynamic> json) {
    return Wilaya(code: json['code'] as String, nameAR: json['name_ar'] as String, nameFR: json['name_fr'] as String, cities: (json['cities'] as List).map((cityJson) => City.fromJson(cityJson as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name_ar': nameAR, 'name_fr': nameFR, 'cities': cities.map((city) => city.toJson()).toList()};
  }
}

// Store the selected location info
class LocationData {
  final String wilayaCode;
  final String wilayaNameAr;
  final String wilayaNameFr;
  final String cityNameAr;
  final String cityNameFr;

  LocationData({required this.wilayaCode, required this.wilayaNameAr, required this.wilayaNameFr, required this.cityNameAr, required this.cityNameFr});

  Map<String, dynamic> toJson() {
    return {'wilaya_code': wilayaCode, 'wilaya_name_ar': wilayaNameAr, 'wilaya_name_fr': wilayaNameFr, 'city_name_ar': cityNameAr, 'city_name_fr': cityNameFr};
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(wilayaCode: json['wilaya_code'] as String, wilayaNameAr: json['wilaya_name_ar'] as String, wilayaNameFr: json['wilaya_name_fr'] as String, cityNameAr: json['city_name_ar'] as String, cityNameFr: json['city_name_fr'] as String);
  }
}
