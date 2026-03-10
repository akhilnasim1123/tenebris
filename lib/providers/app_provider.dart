import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _reminders = [];

  double _accountBalance = 0.0;
  double _inHandBalance = 0.0;

  double get accountBalance => _accountBalance;
  double get inHandBalance => _inHandBalance;

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _noteCategories = [];

  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get reminders => _reminders;
  List<Map<String, dynamic>> get notes => _notes;
  List<Map<String, dynamic>> get noteCategories => _noteCategories;

  double get totalExpense {
    return _transactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, item) => sum + (item['amount'] as num));
  }

  double get totalIncome {
    return _transactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, item) => sum + (item['amount'] as num));
  }

  double get balance => _accountBalance + _inHandBalance + totalIncome - totalExpense;

  double get accountCalculated => _accountBalance + 
        _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));

  double get inHandCalculated => _inHandBalance + 
        _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));

  double get creditCalculated => _transactions.where((t) => t['payment_method'] == 'credit' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'credit' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)); // if paying OFF credit

  AppProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final balancesMap = await _dbService.getBalances();
    _accountBalance = balancesMap['account']!;
    _inHandBalance = balancesMap['in_hand']!;
    
    _transactions = await _dbService.getTransactions();
    _reminders = await _dbService.getReminders();
    _notes = await _dbService.getNotes();
    _noteCategories = await _dbService.getNoteCategories();
    notifyListeners();
  }

  Future<void> updateBalances(double account, double inHand) async {
    await _dbService.updateBalances(account, inHand);
    await loadData();
  }

  Future<void> addTransaction(String title, double amount, String category, String date, String type, String paymentMethod) async {
    await _dbService.insertTransaction({
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'type': type,
      'payment_method': paymentMethod,
    });
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.deleteTransaction(id);
    await loadData();
  }

  Future<void> addReminder(String title, String datetime) async {
    final docId = await _dbService.insertReminder({
      'title': title,
      'datetime': datetime,
      'is_completed': 0,
    });
    
    // Schedule notification
    final DateTime scheduledDate = DateTime.parse(datetime);
    await NotificationService().scheduleReminderNotification(docId, title, scheduledDate);
    
    await loadData();
  }

  Future<void> toggleReminder(String id, int isCompleted) async {
    await _dbService.updateReminder(id, isCompleted);
    
    // Cancel notification if completed, reschedule if uncompleted
    if (isCompleted == 1) {
      await NotificationService().cancelReminderNotification(id);
    } else {
      final reminder = _reminders.firstWhere((r) => r['id'] == id);
      await NotificationService().scheduleReminderNotification(
        id, 
        reminder['title'], 
        DateTime.parse(reminder['datetime'])
      );
    }
    
    await loadData();
  }

  Future<void> deleteReminder(String id) async {
    await _dbService.deleteReminder(id);
    await loadData();
  }

  // Notes
  Future<void> addNoteCategory(String name) async {
    await _dbService.insertNoteCategory(name);
    await loadData();
  }

  Future<void> addNote(String title, String content, String categoryId, String date) async {
    await _dbService.insertNote({
      'title': title,
      'content': content,
      'category_id': categoryId,
      'date': date,
    });
    await loadData();
  }

  Future<void> deleteNote(String id) async {
    await _dbService.deleteNote(id);
    await loadData();
  }
}
