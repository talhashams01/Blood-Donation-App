
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Expose the auth state stream for Riverpod
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a user and store profile
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String bloodGroup,
    required String city,
    required String role,
    required String phone,
    String? lastDonated,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return false;
      final token = await _fcm.getToken();
      await _fs.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'bloodGroup': bloodGroup == '' ? null : bloodGroup,
        'city': city == '' ? null : city,
        'role': role,
        'phone': phone,
        'lastDonated': lastDonated,
        'fcmToken': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseAuthException catch (e) {
      // you may want to rethrow or return error messages; boolean keeps it simple
      print('Auth register error: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      print('General register error: $e');
      return false;
    }
  }

  // Login and update token
  Future<bool> loginUser(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return false;
      final newToken = await _fcm.getToken();
      await _fs.collection('users').doc(user.uid).update({
        'fcmToken': newToken,
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseAuthException catch (e) {
      print('Auth login error: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      print('General login error: $e');
      return false;
    }
  }

  Future<void> logoutUser() async => await _auth.signOut();
}