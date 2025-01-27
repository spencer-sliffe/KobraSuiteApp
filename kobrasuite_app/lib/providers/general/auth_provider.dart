import 'package:flutter/foundation.dart';
import '../../services/general/auth_service.dart';
import '../../services/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String _errorMessage = '';
  int? _userPk;
  int? _schoolProfilePk;
  int? _userProfilePk;
  int? _workProfilePk;
  int? _financeProfilePk;


  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.accessToken != null;
  int get userPk => _userPk ?? 0;
  int get schoolProfilePk => _schoolProfilePk ?? 0;
  int get userProfilePk => _userProfilePk ?? 0;
  int get workProfilePk => _workProfilePk ?? 0;
  int get financeProfilePk => _financeProfilePk ?? 0;

  AuthProvider() : _authService = serviceLocator<AuthService>() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    if (isLoggedIn) {
      _userPk = _authService.loggedInUserId;
      notifyListeners();
    }
  }

  Future<void> fetchWhoami() async {
    if (!isLoggedIn) return;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    final result = await _authService.whoami();
    _isLoading = false;
    if (result['success'] == true) {
      final userData = result['user'];
      _userPk = userData['id'];
      _schoolProfilePk = userData['school_profile'] != null
          ? (userData['school_profile']['id'] ?? 0)
          : 0;
      _userProfilePk = userData['profile'] != null
          ? (userData['profile']['id'] ?? 0)
          : 0;
      _workProfilePk = userData['work_profile'] != null
          ? (userData['work_profile']['id'] ?? 0)
          : 0;
      _financeProfilePk = userData['finance_profile'] != null
          ? (userData['finance_profile']['id'] ?? 0)
          : 0;
    } else {
      _errorMessage = result['errors']?.toString() ?? 'Failed to confirm login.';
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both username/email and password';
      notifyListeners();
      return false;
    }
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(username: username, password: password);
      if (result['success'] == true) {
        final userData = result['user'];
        _userPk = userData['id'];
        _schoolProfilePk = userData['school_profile'] != null
            ? userData['school_profile']['id']
            : 0;
        _userProfilePk = userData['profile'] != null
            ? userData['profile']['id']
            : 0;
        _workProfilePk = userData['work_profile'] != null
            ? userData['work_profile']['id']
            : 0;
        _financeProfilePk = userData['finance_profile'] != null
            ? userData['finance_profile']['id']
            : 0;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['errors']?.toString() ?? 'Invalid credentials.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String phoneNumber, String password, String confirmPassword) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Please fill out all required fields';
      notifyListeners();
      return false;
    }
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.register(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (result['success'] == true) {
        final userData = result['user'];
        _userPk = userData['id'];
        _schoolProfilePk = userData['school_profile'] != null
            ? userData['school_profile']['id']
            : 0;
        _userProfilePk = userData['profile'] != null
            ? userData['profile']['id']
            : 0;
        _workProfilePk = userData['work_profile'] != null
            ? userData['work_profile']['id']
            : 0;
        _financeProfilePk = userData['finance_profile'] != null
            ? userData['finance_profile']['id']
            : 0;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['errors']?.toString() ?? 'Unknown error';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final result = await _authService.logout();
      if (result['success'] == true) {
        _userPk = null;
        _schoolProfilePk = null;
        _userProfilePk = null;
        _workProfilePk = null;
        _financeProfilePk = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['errors']?.toString() ?? 'Logout failed.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred during logout: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}