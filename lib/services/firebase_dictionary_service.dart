import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dictionary_entry.dart';

class FirebaseDictionaryService {
  final CollectionReference _dictionaryCollection = FirebaseFirestore.instance.collection('dictionary');

  // Add new entry
  Future<void> addEntry(DictionaryEntry entry) async {
    await _dictionaryCollection.add(entry.toMap());
  }

  // Update entry
  Future<void> updateEntry(String id, DictionaryEntry entry) async {
    await _dictionaryCollection.doc(id).update(entry.toMap());
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    await _dictionaryCollection.doc(id).delete();
  }

  // Stream all entries
  Stream<List<DictionaryEntry>> getEntries() {
    return _dictionaryCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => DictionaryEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }
}
