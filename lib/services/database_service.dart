import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Balance methods
  Future<void> updateBalances(double account, double inHand, {double deposit = 0.0}) async {
    await _db.collection('settings').doc('balances').set({
      'account': account,
      'in_hand': inHand,
      'deposit': deposit,
    });
  }

  Future<Map<String, double>> getBalances() async {
    final doc = await _db.collection('settings').doc('balances').get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'account': (data['account'] as num?)?.toDouble() ?? 0.0,
        'in_hand': (data['in_hand'] as num?)?.toDouble() ?? 0.0,
        'deposit': (data['deposit'] as num?)?.toDouble() ?? 0.0,
      };
    }
    return {'account': 0.0, 'in_hand': 0.0, 'deposit': 0.0};
  }

  // Transaction methods
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    await _db.collection('transactions').add(transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final snapshot = await _db.collection('transactions').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.collection('transactions').doc(id).delete();
  }

  // Reminder methods
  Future<String> insertReminder(Map<String, dynamic> reminder) async {
    final docRef = await _db.collection('reminders').add(reminder);
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final snapshot = await _db.collection('reminders').orderBy('datetime').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> updateReminder(String id, int isCompleted) async {
    await _db.collection('reminders').doc(id).update({'is_completed': isCompleted});
  }

  Future<void> deleteReminder(String id) async {
    await _db.collection('reminders').doc(id).delete();
  }

  // Note Categories methods
  Future<void> insertNoteCategory(String name) async {
    final query = await _db.collection('note_categories').where('name', isEqualTo: name).get();
    if (query.docs.isEmpty) {
      await _db.collection('note_categories').add({'name': name});
    }
  }

  Future<List<Map<String, dynamic>>> getNoteCategories() async {
    final snapshot = await _db.collection('note_categories').orderBy('name').get();
    if (snapshot.docs.isEmpty) {
      await insertNoteCategory('General');
      await insertNoteCategory('Knowledge');
      await insertNoteCategory('Ideas');
      return await getNoteCategories();
    }
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Notes methods
  Future<void> insertNote(Map<String, dynamic> note) async {
    await _db.collection('notes').add(note);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final results = await Future.wait([
      _db.collection('notes').orderBy('date', descending: true).get(),
      getNoteCategories(),
    ]);

    final snapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final categories = results[1] as List<Map<String, dynamic>>;
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final categoryId = data['category_id']?.toString();
      
      final category = categories.firstWhere(
        (c) => c['id'] == categoryId, 
        orElse: () => {'name': 'Unknown'}
      );
      
      return {
        'id': doc.id,
        'category_name': category['name'],
        ...data,
      };
    }).toList();
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }

  // Personal Debts (Me feature)
  Future<void> insertPersonalDebt(Map<String, dynamic> debt) async {
    await _db.collection('personal_debts').add(debt);
  }

  Future<List<Map<String, dynamic>>> getPersonalDebts() async {
    final snapshot = await _db.collection('personal_debts').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> updatePersonalDebt(String id, Map<String, dynamic> debt) async {
    await _db.collection('personal_debts').doc(id).update(debt);
  }

  Future<void> deletePersonalDebt(String id) async {
    await _db.collection('personal_debts').doc(id).delete();
  }

  // Salary methods
  Future<void> insertSalary(Map<String, dynamic> salary) async {
    await _db.collection('salaries').add(salary);
  }

  Future<List<Map<String, dynamic>>> getSalaries() async {
    final snapshot = await _db.collection('salaries').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> updateSalary(String id, Map<String, dynamic> salary) async {
    await _db.collection('salaries').doc(id).update(salary);
  }

  Future<void> deleteSalary(String id) async {
    await _db.collection('salaries').doc(id).delete();
  }
}
