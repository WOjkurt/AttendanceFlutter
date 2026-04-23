import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin service layer around Firebase Auth and Firestore.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Auth State ───────────────────────────────────────────────────
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ─── Registration ─────────────────────────────────────────────────
  /// Creates a Firebase Auth user with the real school email and stores
  /// the user document in Firestore.
  Future<User> register({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  // ─── Login ────────────────────────────────────────────────────────
  /// Signs in directly with the school email and password.
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return credential.user!;
  }

  // ─── Logout ───────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // ─── Firestore Data ───────────────────────────────────────────────
  /// Fetches the Firestore user document for the given [uid].
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
