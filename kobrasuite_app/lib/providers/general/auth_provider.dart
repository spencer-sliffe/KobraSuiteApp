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
  int? _homeLifeProfilePk;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.accessToken != null;

  int get userPk => _userPk ?? 0;
  int get schoolProfilePk => _schoolProfilePk ?? 0;
  int get userProfilePk => _userProfilePk ?? 0;
  int get workProfilePk => _workProfilePk ?? 0;
  int get financeProfilePk => _financeProfilePk ?? 0;
  int get homeLifeProfilePk => _homeLifeProfilePk ?? 0;

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
      final userData = result['user'] as Map<String, dynamic>?;

      if (userData != null) {
        _userPk = userData['id'] as int?;
        final profileObj = userData['profile'] as Map<String, dynamic>?;

        if (profileObj != null) {
          _userProfilePk = profileObj['id'] as int? ?? 0;

          final schoolProfileObj = profileObj['school_profile'] as Map<String, dynamic>?;
          _schoolProfilePk = schoolProfileObj != null ? (schoolProfileObj['id'] ?? 0) : 0;

          final workProfileObj = profileObj['work_profile'] as Map<String, dynamic>?;
          _workProfilePk = workProfileObj != null ? (workProfileObj['id'] ?? 0) : 0;

          final financeProfileObj = profileObj['finance_profile'] as Map<String, dynamic>?;
          _financeProfilePk = financeProfileObj != null ? (financeProfileObj['id'] ?? 0) : 0;

          final homeLifeProfileObj = profileObj['homelife_profile'] as Map<String, dynamic>?;
          _homeLifeProfilePk = homeLifeProfileObj != null ? (homeLifeProfileObj['id'] ?? 0) : 0;
        }
      }
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
        final userData = result['user'] as Map<String, dynamic>?;

        if (userData != null) {
          _userPk = userData['id'] as int?;
          final profileObj = userData['profile'] as Map<String, dynamic>?;

          if (profileObj != null) {
            _userProfilePk = profileObj['id'] as int? ?? 0;

            final schoolProfileObj = profileObj['school_profile'] as Map<String, dynamic>?;
            _schoolProfilePk = schoolProfileObj != null ? (schoolProfileObj['id'] ?? 0) : 0;

            final workProfileObj = profileObj['work_profile'] as Map<String, dynamic>?;
            _workProfilePk = workProfileObj != null ? (workProfileObj['id'] ?? 0) : 0;

            final financeProfileObj = profileObj['finance_profile'] as Map<String, dynamic>?;
            _financeProfilePk = financeProfileObj != null ? (financeProfileObj['id'] ?? 0) : 0;

            final homeLifeProfileObj = profileObj['homelife_profile'] as Map<String, dynamic>?;
            _homeLifeProfilePk = homeLifeProfileObj != null ? (homeLifeProfileObj['id'] ?? 0) : 0;
          }
        }
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
        final userData = result['user'] as Map<String, dynamic>?;

        if (userData != null) {
          _userPk = userData['id'] as int?;
          final profileObj = userData['profile'] as Map<String, dynamic>?;

          if (profileObj != null) {
            _userProfilePk = profileObj['id'] as int? ?? 0;

            final schoolProfileObj = profileObj['school_profile'] as Map<String, dynamic>?;
            _schoolProfilePk = schoolProfileObj != null ? (schoolProfileObj['id'] ?? 0) : 0;

            final workProfileObj = profileObj['work_profile'] as Map<String, dynamic>?;
            _workProfilePk = workProfileObj != null ? (workProfileObj['id'] ?? 0) : 0;

            final financeProfileObj = profileObj['finance_profile'] as Map<String, dynamic>?;
            _financeProfilePk = financeProfileObj != null ? (financeProfileObj['id'] ?? 0) : 0;

            final homeLifeProfileObj = profileObj['homelife_profile'] as Map<String, dynamic>?;
            _homeLifeProfilePk = homeLifeProfileObj != null ? (homeLifeProfileObj['id'] ?? 0) : 0;
          }
        }
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
        _homeLifeProfilePk = null;
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

  Future<bool> passwordResetRequest(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Email is required';
      notifyListeners();
      return false;
    }
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();

    final result = await _authService.requestPasswordReset(email);
    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['errors']?.toString() ?? 'Failed to send reset email';
      notifyListeners();
      return false;
    }
  }

  Future<bool> passwordResetConfirm(String uid, String token, String newPassword) async {
    if (uid.isEmpty || token.isEmpty || newPassword.isEmpty) {
      _errorMessage = 'All fields are required';
      notifyListeners();
      return false;
    }
    _errorMessage = '';
    _isLoading = true;
    notifyListeners();

    final result = await _authService.confirmPasswordReset(uid, token, newPassword);
    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['errors']?.toString() ?? 'Failed to reset password';
      notifyListeners();
      return false;
    }
  }
}