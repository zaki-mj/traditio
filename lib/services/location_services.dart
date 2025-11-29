import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AlgeriaLocationService {
  static List<dynamic>? _states;

  static Future<void> load() async {
    if (_states != null) return;
    final String data = await rootBundle.loadString('assets/data/algeria_cities.json');
    _states = json.decode(data);
  }

  static Future<List<Map<String, dynamic>>> getStates() async {
    await load();
    return _states!.map<Map<String, dynamic>>((state) => {'code': state['code'], 'nameAR': state['name_ar'], 'nameFR': state['name_fr'], 'cities': state['cities']}).toList();
  }

  static Future<List<Map<String, dynamic>>> getCitiesForState(String stateCode) async {
    await load();
    final state = _states!.firstWhere((s) => s['code'] == stateCode, orElse: () => null);
    if (state == null) return [];
    return (state['cities'] as List).map<Map<String, dynamic>>((city) => {'nameAR': city['name_ar'], 'nameFR': city['name_fr']}).toList();
  }
}
