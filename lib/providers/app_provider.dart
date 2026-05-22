import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  bool _isLoggedIn = false;
  String? _token;
  String? _username;
  String? _phoneNumber;
  String? _name;
  String? _profilePicture;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get username => _username;
  String? get phoneNumber => _phoneNumber;
  String? get name => _name;
  String? get profilePicture => _profilePicture;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _reminders = [];

  double _accountBalance = 0.0;
  double _inHandBalance = 0.0;
  double _depositBalance = 0.0;

  double get accountBalance => _accountBalance;
  double get inHandBalance => _inHandBalance;
  double get depositBalance => _depositBalance;

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _noteCategories = [];
  List<Map<String, dynamic>> _salaries = [];

  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get reminders => _reminders;
  List<Map<String, dynamic>> get notes => _notes;
  List<Map<String, dynamic>> get noteCategories => _noteCategories;
  List<Map<String, dynamic>> get salaries => _salaries;

  double get totalExpense {
    return _transactions
        .where((t) => t['type'] == 'expense' && t['exclude'] != true)
        .fold(0.0, (sum, item) => sum + (item['amount'] as num));
  }

  double get totalIncome {
    return _transactions
        .where((t) => t['type'] == 'income' && t['exclude'] != true)
        .fold(0.0, (sum, item) => sum + (item['amount'] as num));
  }

  double get balance => accountCalculated + inHandCalculated;

  double get accountCalculated => _accountBalance + 
        _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));

  double get inHandCalculated => _inHandBalance + 
        _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));

  double get depositCalculated => _depositBalance + 
        _transactions.where((t) => t['payment_method'] == 'deposit' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'deposit' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));

  double get creditCalculated => _transactions.where((t) => t['payment_method'] == 'credit' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num)) -
        _transactions.where((t) => t['payment_method'] == 'credit' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num)); 

  AppProvider() {
    checkSavedAuth();
  }

  Future<void> checkSavedAuth() async {
    _setBusy(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUsername = prefs.getString('username');
      final savedPhone = prefs.getString('phone_number');
      final savedName = prefs.getString('name');
      final savedProfilePic = prefs.getString('profile_picture');

      if (savedToken != null) {
        _token = savedToken;
        _username = savedUsername;
        _phoneNumber = savedPhone;
        _name = savedName;
        _profilePicture = savedProfilePic;
        _dbService.token = savedToken;
        _isLoggedIn = true;
        await loadData();
      }
    } catch (e) {
      debugPrint("Error loading saved auth: $e");
    } finally {
      _setBusy(false);
    }
  }

  Future<void> login(String username, String password) async {
    _setBusy(true);
    try {
      final data = await _dbService.login(username, password);
      _token = data['token'];
      _username = data['username'];
      _phoneNumber = data['phone_number'];
      _name = data['name'];
      _profilePicture = data['profile_picture'];
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setString('phone_number', _phoneNumber!);
      await prefs.setString('name', _name ?? '');
      await prefs.setString('profile_picture', _profilePicture ?? '');

      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<Map<String, dynamic>> signup(String username, String password, String phoneNumber) async {
    _setBusy(true);
    try {
      final result = await _dbService.signup(username, password, phoneNumber);
      if (result.containsKey('token')) {
        _token = result['token'];
        _username = result['username'];
        _phoneNumber = result['phone_number'];
        _name = result['name'];
        _profilePicture = result['profile_picture'];
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('username', _username!);
        await prefs.setString('phone_number', _phoneNumber!);
        await prefs.setString('name', _name ?? '');
        await prefs.setString('profile_picture', _profilePicture ?? '');

        await loadData();
        return {'success': true};
      }
      return result; // Has validation details ('error', 'field', 'suggestions')
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setBusy(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('username');
      await prefs.remove('phone_number');
      await prefs.remove('name');
      await prefs.remove('profile_picture');

      _token = null;
      _username = null;
      _phoneNumber = null;
      _name = null;
      _profilePicture = null;
      _isLoggedIn = false;
      _dbService.token = null;

      _transactions = [];
      _reminders = [];
      _notes = [];
      _noteCategories = [];
      _personalDebts = [];
      _salaries = [];

      _accountBalance = 0.0;
      _inHandBalance = 0.0;
      _depositBalance = 0.0;

      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String username,
    String? password,
    String? profilePicture,
  }) async {
    _setBusy(true);
    try {
      final result = await _dbService.updateProfile(
        name: name,
        username: username,
        password: password,
        profilePicture: profilePicture,
      );
      if (result.containsKey('error')) {
        return result;
      }

      _username = result['username'];
      _name = result['name'];
      _profilePicture = result['profile_picture'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username!);
      await prefs.setString('name', _name ?? '');
      await prefs.setString('profile_picture', _profilePicture ?? '');

      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    } finally {
      _setBusy(false);
    }
  }

  Future<void> loadData() async {
    if (!_isLoggedIn) return;
    try {
      final results = await Future.wait([
        _dbService.getBalances(),
        _dbService.getTransactions(),
        _dbService.getReminders(),
        _dbService.getNotes(),
        _dbService.getNoteCategories(),
        _dbService.getPersonalDebts(),
        _dbService.getSalaries(),
      ]);

      final balancesMap = results[0] as Map<String, double>;
      _accountBalance = balancesMap['account']!;
      _inHandBalance = balancesMap['in_hand']!;
      _depositBalance = balancesMap['deposit']!;
      
      _transactions = results[1] as List<Map<String, dynamic>>;
      _reminders = results[2] as List<Map<String, dynamic>>;
      _notes = results[3] as List<Map<String, dynamic>>;
      _noteCategories = results[4] as List<Map<String, dynamic>>;
      _personalDebts = results[5] as List<Map<String, dynamic>>;
      _salaries = results[6] as List<Map<String, dynamic>>;
      notifyListeners();
    } catch (e) {
      debugPrint("Error in loadData: $e");
    }
  }

  Future<void> updateBalances(double account, double inHand, {double deposit = 0.0}) async {
    _setBusy(true);
    try {
      await _dbService.updateBalances(account, inHand, deposit: deposit);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> addTransaction(String title, double amount, String category, String date, String type, String paymentMethod, {bool exclude = false}) async {
    _setBusy(true);
    try {
      await _dbService.insertTransaction({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
        'type': type,
        'payment_method': paymentMethod,
        'exclude': exclude,
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteTransaction(String id) async {
    _setBusy(true);
    try {
      await _dbService.deleteTransaction(id);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> addReminder(String title, String datetime) async {
    _setBusy(true);
    try {
      final docId = await _dbService.insertReminder({
        'title': title,
        'datetime': datetime,
        'is_completed': 0,
      });
      
      // Schedule notification
      final DateTime scheduledDate = DateTime.parse(datetime);
      await NotificationService().scheduleReminderNotification(docId, title, scheduledDate);
      
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> toggleReminder(String id, int isCompleted) async {
    _setBusy(true);
    try {
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
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteReminder(String id) async {
    _setBusy(true);
    try {
      await _dbService.deleteReminder(id);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  // Notes
  Future<void> addNoteCategory(String name) async {
    _setBusy(true);
    try {
      await _dbService.insertNoteCategory(name);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> addNote(String title, String content, String categoryId, String date) async {
    _setBusy(true);
    try {
      await _dbService.insertNote({
        'title': title,
        'content': content,
        'category_id': categoryId,
        'date': date,
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteNote(String id) async {
    _setBusy(true);
    try {
      await _dbService.deleteNote(id);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  // Personal Debts (Me feature)
  List<Map<String, dynamic>> _personalDebts = [];
  List<Map<String, dynamic>> get personalDebts => _personalDebts;

  double get myTotalCredit => _personalDebts
      .where((d) => d['type'] == 'credit')
      .fold(0.0, (sum, item) => sum + (item['amount'] as num));

  double get myTotalDebit => _personalDebts
      .where((d) => d['type'] == 'debit')
      .fold(0.0, (sum, item) => sum + (item['amount'] as num));

  Future<void> addPersonalDebt(String title, double amount, String type, String person) async {
    _setBusy(true);
    try {
      await _dbService.insertPersonalDebt({
        'title': title,
        'amount': amount,
        'type': type,
        'person': person,
        'status': 'active', // active, settled, rejected
        'date': DateTime.now().toIso8601String(),
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updatePersonalDebt(String id, String title, double amount, String type, String person, {String? status}) async {
    _setBusy(true);
    try {
      final updateData = {
        'title': title,
        'amount': amount,
        'type': type,
        'person': person,
      };
      if (status != null) updateData['status'] = status;
      
      await _dbService.updatePersonalDebt(id, updateData);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deletePersonalDebt(String id) async {
    _setBusy(true);
    try {
      await _dbService.deletePersonalDebt(id);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  // Balance Adjustments
  Future<void> markAsDeposited(double amount, {String source = 'in_hand', bool subtractFromSource = true}) async {
    _setBusy(true);
    try {
      final date = DateTime.now().toIso8601String();
      if (subtractFromSource) {
        await _dbService.insertTransaction({
          'title': 'Deposit to Savings',
          'amount': amount,
          'category': 'Transfer',
          'date': date,
          'type': 'expense',
          'payment_method': source,
        });
      }
      await _dbService.insertTransaction({
        'title': 'Deposit from ${subtractFromSource ? (source == 'in_hand' ? 'Hand' : 'Account') : 'External Source'}',
        'amount': amount,
        'category': 'Transfer',
        'date': date,
        'type': 'income',
        'payment_method': 'deposit',
        'exclude': !subtractFromSource,
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> addBalance(double amount, String paymentMethod, {bool subtract = false}) async {
    _setBusy(true);
    try {
      await _dbService.insertTransaction({
        'title': subtract ? 'Balance Correction (Subtract)' : 'Direct Balance Addition',
        'amount': amount,
        'category': 'Adjustment',
        'date': DateTime.now().toIso8601String(),
        'type': subtract ? 'expense' : 'income',
        'payment_method': paymentMethod,
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setCurrentAccountBalance(double target) async {
    _setBusy(true);
    try {
      double income = _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num));
      double expense = _transactions.where((t) => t['payment_method'] == 'account' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));
      
      double newInitialAccount = target - income + expense;
      await _dbService.updateBalances(newInitialAccount, _inHandBalance, deposit: _depositBalance);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setCurrentInHandBalance(double target) async {
    _setBusy(true);
    try {
      double income = _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num));
      double expense = _transactions.where((t) => t['payment_method'] == 'in_hand' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));
      
      double newInitialInHand = target - income + expense;
      await _dbService.updateBalances(_accountBalance, newInitialInHand, deposit: _depositBalance);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setCurrentDepositBalance(double target) async {
    _setBusy(true);
    try {
      double income = _transactions.where((t) => t['payment_method'] == 'deposit' && t['type'] == 'income').fold(0.0, (s, i) => s + (i['amount'] as num));
      double expense = _transactions.where((t) => t['payment_method'] == 'deposit' && t['type'] == 'expense').fold(0.0, (s, i) => s + (i['amount'] as num));
      
      double newInitialDeposit = target - income + expense;
      await _dbService.updateBalances(_accountBalance, _inHandBalance, deposit: newInitialDeposit);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  // Salary methods
  Future<void> addSalary(String title, double amount, String month, String date) async {
    _setBusy(true);
    try {
      await _dbService.insertSalary({
        'title': title,
        'amount': amount,
        'month': month,
        'date': date,
        'status': 'pending',
      });
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> settleSalary(String id, double amount, String paymentMethod) async {
    _setBusy(true);
    try {
      await _dbService.updateSalary(id, {'status': 'recieved'});
      
      final salary = _salaries.firstWhere((s) => s['id'] == id);
      await addTransaction(
        'Salary Recieved: ${salary['title']} (${salary['month']})',
        amount,
        'Salary',
        DateTime.now().toIso8601String(),
        'income',
        paymentMethod
      );
      
      await loadData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteSalary(String id) async {
    _setBusy(true);
    try {
      await _dbService.deleteSalary(id);
      await loadData();
    } finally {
      _setBusy(false);
    }
  }
}
