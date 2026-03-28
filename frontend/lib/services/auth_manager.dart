class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  
  Map<String, dynamic>? get currentUser => _currentUser;

  void setUser(Map<String, dynamic> userData) {
    _currentUser = userData;
  }

  void logout() {
    _currentUser = null;
  }
}
