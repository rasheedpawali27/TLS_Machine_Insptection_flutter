import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<User> _users = [
    User(
        username: 'habib',
        password: '123',
        email: 'habib@interloop.com.pk',
        assignedLine: 'Line 1',
        fullName: 'Habib'
    ),
    User(
        username: 'tayyab',
        password: '123',
        email: 'tayyab@interloop.com.pk',
        assignedLine: 'Line 2',
        fullName: 'Tayyab'
    ),
    User(
        username: 'Ahmad',
        password: '123',
        email: 'ahmad@interloop.com.pk',
        assignedLine: 'Line 3',
        fullName: 'Ahmad'
    ),
    User(
        username: 'shahzad',
        password: '123',
        email: 'shahzad@interloop.com.pk',
        assignedLine: 'Line 4',
        fullName: 'Shahzad'
    ),
    User(
        username: 'zahid',
        password: '123',
        email: 'zahid@interloop.com.pk',
        assignedLine: 'Line 5',
        fullName: 'Zahid'
    ),
    User(
        username: 'amir',
        password: '123',
        email: 'amir@interloop.com.pk',
        assignedLine: 'Line 6',
        fullName: 'Amir'
    ),
    User(
        username: 'sohail',
        password: '123',
        email: 'sohail@interloop.com.pk',
        assignedLine: 'Line 7',
        fullName: 'sohail'
    ),
    User(
        username: 'sobia',
        password: '123',
        email: 'sobia@interloop.com.pk',
        assignedLine: 'Line 8',
        fullName: 'Sobia'
    ),
    User(
        username: 'amir',
        password: '123',
        email: 'amir@interloop.com.pk',
        assignedLine: 'Line 9',
        fullName: 'Amir'
    ),
    User(
        username: 'ammar',
        password: '123',
        email: 'ammar@interloop.com.pk',
        assignedLine: 'Line 10',
        fullName: 'Ammar'
    ),
  ];

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    final user = _users.firstWhere(
          (user) => (user.username == username || user.email == username) && user.password == password,
      orElse: () => User(username: '', password: '', email: '', assignedLine: '', fullName: ''),
    );

    if (user.username.isNotEmpty) {
      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', user.username);
      await prefs.setBool('rememberUser', true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUser');
    final rememberUser = prefs.getBool('rememberUser') ?? false;

    if (username != null && rememberUser) {
      final user = _users.firstWhere(
            (user) => user.username == username,
        orElse: () => User(username: '', password: '', email: '', assignedLine: '', fullName: ''),
      );

      if (user.username.isNotEmpty) {
        _currentUser = user;
      }
    }
  }
}



/*
// auth_service.dart
import 'api_service.dart';

class AuthService {
  Future<bool> login(String username, String password) async {
    try {
      return await ApiService.login(username, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
  }

  bool isLoggedIn() {
    return ApiService.isLoggedIn();
  }
}

*/





