import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_app/data/database/connection.dart';
import 'package:meu_app/data/database/local_backup_store.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:meu_app/firebase_options.dart';
import 'package:meu_app/services/firestore_backup_store.dart';

class BackupService {
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    if (register) {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  FirestoreBackupStore get _remote {
    final account = user;
    if (account == null) {
      throw const BackupException('Entre na sua conta para continuar.');
    }
    return FirestoreBackupStore(
      projectId: Firebase.app().options.projectId,
      userId: account.uid,
      idToken: account.getIdToken,
    );
  }

  Future<BackupSnapshot?> fetch() => _remote.load();

  Future<BackupSnapshot> push() async {
    final remote = _remote;
    final local = LocalBackupStore(await Connection.instance.database);
    final snapshot = await local.capture();
    await remote.save(snapshot);
    return snapshot;
  }

  Future<void> restore(BackupSnapshot snapshot) async {
    final local = LocalBackupStore(await Connection.instance.database);
    await local.restore(snapshot);
  }
}
