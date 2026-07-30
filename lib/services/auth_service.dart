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

    final uid = credential.user!.uid;
    final newUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      age: age,
      gender: gender,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(FirestoreCollections.users).doc(uid).set(newUser.toMap());

    return newUser;
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