import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await signInAnonymously();
    _isInitialized = true;
  }

  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    if (!_isInitialized) {
      await initialize();
    }

    final user = _auth.currentUser;
    
    if (user == null) {
      await signInAnonymously();
      final newUser = _auth.currentUser;
      if (newUser == null) {
        throw Exception('No authenticated user available');
      }
      final token = await newUser.getIdToken(true);
      return {'Authorization': 'Bearer $token'};
    }

    final token = await user.getIdToken(true);
    if (token == null) {
      throw Exception('Failed to get ID token');
    }

    return {'Authorization': 'Bearer $token'};
  }
}
