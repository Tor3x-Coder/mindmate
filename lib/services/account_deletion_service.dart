import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/constants.dart';

enum AccountDeletionStage {
  reauthentication,
  firestoreData,
  authenticationAccount,
}

class AccountDeletionFailure implements Exception {
  final AccountDeletionStage stage;
  final String code;
  final bool someDataMayAlreadyBeDeleted;

  const AccountDeletionFailure({
    required this.stage,
    required this.code,
    this.someDataMayAlreadyBeDeleted = false,
  });

  @override
  String toString() => 'AccountDeletionFailure($stage, $code)';
}

class AccountDeletionSummary {
  final int deletedDocuments;

  const AccountDeletionSummary({required this.deletedDocuments});
}

/// Spark-plan-compatible account deletion.
///
/// The operation is intentionally repeatable: every collection is deleted in
/// small batches, the profile is deleted last, and Firebase Auth is deleted
/// only after Firestore succeeds. If the app/network is interrupted, signing
/// in and running the flow again safely continues from the remaining data.
class AccountDeletionService {
  static const int _batchSize = 200;

  static const List<String> _ownedCollections = [
    FirestoreCollections.moodLogs,
    FirestoreCollections.journalEntries,
    FirestoreCollections.wellnessAssessments,
    FirestoreCollections.meditationHistory,
    FirestoreCollections.breathingSessions,
    FirestoreCollections.appointments,
    FirestoreCollections.thoughtRecords,
    FirestoreCollections.feedbackRecords,
    FirestoreCollections.trustedContacts,
    FirestoreCollections.supportEvents,
  ];

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AccountDeletionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AccountDeletionSummary> deleteCurrentAccount({
    required String password,
  }) async {
    final currentUser = _auth.currentUser;
    final email = currentUser?.email;
    if (currentUser == null || email == null || email.isEmpty) {
      throw const AccountDeletionFailure(
        stage: AccountDeletionStage.reauthentication,
        code: 'no-current-email-user',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionFailure(
        stage: AccountDeletionStage.reauthentication,
        code: error.code,
      );
    } catch (_) {
      throw const AccountDeletionFailure(
        stage: AccountDeletionStage.reauthentication,
        code: 'reauthentication-failed',
      );
    }

    var deletedDocuments = 0;
    try {
      for (final collectionName in _ownedCollections) {
        deletedDocuments += await _deleteOwnedCollection(
          collectionName: collectionName,
          uid: currentUser.uid,
        );
      }

      final profileRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(currentUser.uid);
      final profile = await profileRef.get();
      if (profile.exists) {
        await profileRef.delete();
        deletedDocuments++;
      }
    } on FirebaseException catch (error) {
      throw AccountDeletionFailure(
        stage: AccountDeletionStage.firestoreData,
        code: error.code,
        someDataMayAlreadyBeDeleted: deletedDocuments > 0,
      );
    } catch (_) {
      throw AccountDeletionFailure(
        stage: AccountDeletionStage.firestoreData,
        code: 'firestore-deletion-failed',
        someDataMayAlreadyBeDeleted: deletedDocuments > 0,
      );
    }

    try {
      // Reauthentication happened immediately before data deletion. Auth is
      // deliberately last so a partial Firestore failure remains retryable.
      await currentUser.delete();
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionFailure(
        stage: AccountDeletionStage.authenticationAccount,
        code: error.code,
        someDataMayAlreadyBeDeleted: true,
      );
    } catch (_) {
      throw const AccountDeletionFailure(
        stage: AccountDeletionStage.authenticationAccount,
        code: 'auth-deletion-failed',
        someDataMayAlreadyBeDeleted: true,
      );
    }

    return AccountDeletionSummary(deletedDocuments: deletedDocuments);
  }

  Future<int> _deleteOwnedCollection({
    required String collectionName,
    required String uid,
  }) async {
    var deleted = 0;

    while (true) {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('uid', isEqualTo: uid)
          .limit(_batchSize)
          .get();
      if (snapshot.docs.isEmpty) return deleted;

      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
      deleted += snapshot.docs.length;
    }
  }
}
