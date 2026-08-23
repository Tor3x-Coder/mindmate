import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user!;
    final uid = firebaseUser.uid;
    final newUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      age: age,
      gender: gender,
      createdAt: DateTime.now(),
    );

    try {
      await firebaseUser.updateDisplayName(fullName);
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(newUser.toMap());
      return newUser;
    } catch (_) {
      // Do not leave an Auth-only account when profile creation fails. A newly
      // created user is recent enough to delete without another password ask.
      try {
        await firebaseUser.delete();
      } catch (_) {
        await _auth.signOut();
      }
      rethrow;
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserModel> restoreMissingProfile({required String fullName}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw StateError('No signed-in email account is available to restore.');
    }

    final profile = UserModel(
      uid: user.uid,
      fullName: fullName.trim(),
      email: email,
      createdAt: DateTime.now(),
    );
    await user.updateDisplayName(profile.fullName);
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(profile.toMap());
    return profile;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> saveOnboardingData({
    required String uid,
    required List<String> goals,
    required String reminderTime,
  }) async {
    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      'goals': goals,
      'reminderTime': reminderTime,
    });
  }
}