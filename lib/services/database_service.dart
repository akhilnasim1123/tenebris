import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  // Token storage
  String? token;

  // Determine base URL dynamically: Android emulator needs 10.0.2.2, others use localhost.
  static String get baseUrl {
    final String host =
        defaultTargetPlatform == TargetPlatform.android
            ? '192.168.18.68'
            : '192.168.18.68';
    return 'http://192.168.18.68:8000/api';
  }

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      token = data['token'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Invalid username or password');
    }
  }

  Future<Map<String, dynamic>> signup(
    String username,
    String password,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      token = data['token'];
      return data;
    } else {
      return {
        'error': data['error'] ?? 'Registration failed',
        'field': data['field'],
        'suggestions': data['suggestions'],
      };
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    String? username,
    String? phoneNumber,
  }) async {
    final queryParams = <String, String>{};
    if (username != null) queryParams['username'] = username;
    if (phoneNumber != null) queryParams['phone_number'] = phoneNumber;

    final uri = Uri.parse(
      '$baseUrl/auth/check-availability/',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to check availability');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String username,
    String? password,
    String? profilePicture,
  }) async {
    final bodyMap = <String, dynamic>{
      'name': name,
      'username': username,
    };
    if (password != null && password.isNotEmpty) {
      bodyMap['password'] = password;
    }
    if (profilePicture != null) {
      bodyMap['profile_picture'] = profilePicture;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: _headers,
      body: jsonEncode(bodyMap),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return {
        'error': data['error'] ?? 'Profile update failed',
        'field': data['field'],
      };
    }
  }

  // Balance methods
  Future<void> updateBalances(
    double account,
    double inHand, {
    double deposit = 0.0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/balances/'),
      headers: _headers,
      body: jsonEncode({
        'account': account,
        'in_hand': inHand,
        'deposit': deposit,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update balances');
    }
  }

  Future<Map<String, double>> getBalances() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balances/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'account': (data['account'] as num?)?.toDouble() ?? 0.0,
          'in_hand': (data['in_hand'] as num?)?.toDouble() ?? 0.0,
          'deposit': (data['deposit'] as num?)?.toDouble() ?? 0.0,
        };
      }
    } catch (e) {
      debugPrint("Error fetching balances: $e");
    }
    return {'account': 0.0, 'in_hand': 0.0, 'deposit': 0.0};
  }

  // Transaction methods
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/'),
      headers: _headers,
      body: jsonEncode(transaction),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert transaction');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
    return [];
  }

  Future<void> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }
  }

  // Reminder methods
  Future<String> insertReminder(Map<String, dynamic> reminder) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reminders/'),
      headers: _headers,
      body: jsonEncode(reminder),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'].toString();
    }
    throw Exception('Failed to insert reminder');
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reminders/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching reminders: $e");
    }
    return [];
  }

  Future<void> updateReminder(String id, int isCompleted) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/reminders/$id/'),
      headers: _headers,
      body: jsonEncode({'is_completed': isCompleted}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> deleteReminder(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reminders/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete reminder');
    }
  }

  // Note Categories methods
  Future<void> insertNoteCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/note-categories/'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to insert note category');
    }
  }

  Future<List<Map<String, dynamic>>> getNoteCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/note-categories/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
    return [];
  }

  // Notes methods
  Future<void> insertNote(Map<String, dynamic> note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: _headers,
      body: jsonEncode(note),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert note');
    }
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }
    return [];
  }

  Future<void> deleteNote(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notes/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete note');
    }
  }

  // Personal Debts (Me feature)
  Future<void> insertPersonalDebt(Map<String, dynamic> debt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/personal-debts/'),
      headers: _headers,
      body: jsonEncode(debt),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert personal debt');
    }
  }

  Future<List<Map<String, dynamic>>> getPersonalDebts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personal-debts/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching personal debts: $e");
    }
    return [];
  }

  Future<void> updatePersonalDebt(String id, Map<String, dynamic> debt) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/personal-debts/$id/'),
      headers: _headers,
      body: jsonEncode(debt),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update personal debt');
    }
  }

  Future<void> deletePersonalDebt(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/personal-debts/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete personal debt');
    }
  }

  // Salary methods
  Future<void> insertSalary(Map<String, dynamic> salary) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salaries/'),
      headers: _headers,
      body: jsonEncode(salary),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert salary');
    }
  }

  Future<List<Map<String, dynamic>>> getSalaries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/salaries/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Error fetching salaries: $e");
    }
    return [];
  }

  Future<void> updateSalary(String id, Map<String, dynamic> salary) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/salaries/$id/'),
      headers: _headers,
      body: jsonEncode(salary),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update salary');
    }
  }

  Future<void> deleteSalary(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/salaries/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete salary');
    }
  }
}
