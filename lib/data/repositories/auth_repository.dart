import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final GoogleSignIn _googleSignIn;

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _customAuth = firebaseAuth,
        _customFirestore = firestore,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth.instance unavailable: $e');
      return null;
    }
  }

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirebaseFirestore.instance unavailable: $e');
      return null;
    }
  }

  Stream<UserModel?> get authStateChanges {
    try {
      final auth = _auth;
      if (auth != null) {
        return auth.authStateChanges().asyncMap((user) async {
          if (user == null) {
            _currentUser = null;
            return null;
          }
          final userModel =
              await _getUserFromFirestore(user.uid, user.email ?? '');
          _currentUser = userModel;
          return userModel;
        });
      }
    } catch (e) {
      debugPrint('Error in authStateChanges: $e');
    }
    return _authStateController.stream;
  }

  UserModel? get currentUser {
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        final displayName = user.displayName;
        final nameToUse = (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (_currentUser?.fullName ?? _formatNameFromEmail(user.email ?? ''));

        _currentUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: nameToUse,
          phoneNumber: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
        );
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error fetching currentUser: $e');
    }
    return _currentUser;
  }

  static String _formatNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final parts = email.split('@').first.split(RegExp(r'[._-]'));
    return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() + p.substring(1) : '').join(' ').trim();
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String healthCondition = 'Diabetes',
  }) async {
    final auth = _auth;
    final db = _db;

    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        await user.updateDisplayName(fullName);

        final userModel = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          healthCondition: healthCondition,
          createdAt: DateTime.now(),
        );

        if (db != null) {
          try {
            await db
                .collection('users')
                .doc(user.uid)
                .set(userModel.toMap(), SetOptions(merge: true))
                .timeout(const Duration(seconds: 4));
          } catch (e) {
            debugPrint('Notice writing user doc to Firestore: $e');
          }
        }

        try {
          await user.sendEmailVerification();
        } catch (e) {
          debugPrint('Notice sending verification email: $e');
        }

        _currentUser = userModel;
        _authStateController.add(userModel);
        return userModel;
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase Auth SignUp Error: ${e.code} - ${e.message}');
        throw Exception(e.message ?? 'Sign up failed: ${e.code}');
      } catch (e) {
        debugPrint('General SignUp Error: $e');
        throw Exception(e.toString());
      }
    }

    final userModel = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );

    _currentUser = userModel;
    _authStateController.add(userModel);
    return userModel;
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;

    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        final userModel =
            await _getUserFromFirestore(user.uid, user.email ?? email);
        _currentUser = userModel;
        _authStateController.add(userModel);
        return userModel;
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase Auth SignIn Error: ${e.code} - ${e.message}');
        throw Exception(e.message ?? 'Sign in failed: ${e.code}');
      } catch (e) {
        debugPrint('General SignIn Error: $e');
        throw Exception(e.toString());
      }
    }

    final userModel = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: _formatNameFromEmail(email),
      phoneNumber: '',
      createdAt: DateTime.now(),
    );

    _currentUser = userModel;
    _authStateController.add(userModel);
    return userModel;
  }

  Future<UserModel> signInWithGoogle() async {
    final auth = _auth;
    final db = _db;

    if (auth != null && db != null) {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          final user = userCredential.user!;

          final userModel = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : _formatNameFromEmail(user.email ?? ''),
            phoneNumber: user.phoneNumber ?? '',
            createdAt: DateTime.now(),
          );

          try {
            await db
                .collection('users')
                .doc(user.uid)
                .set(userModel.toMap(), SetOptions(merge: true))
                .timeout(const Duration(seconds: 4));
          } catch (_) {}

          _currentUser = userModel;
          _authStateController.add(userModel);
          return userModel;
        }
      } catch (e) {
        debugPrint('Google Sign-In Error: $e');
        throw Exception('Google sign-in failed: $e');
      }
    }

    final mock = UserModel(
      uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'googleuser@gmail.com',
      fullName: 'Google User',
      phoneNumber: '',
      createdAt: DateTime.now(),
    );
    _currentUser = mock;
    _authStateController.add(mock);
    return mock;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email);
      } catch (e) {
        debugPrint('Password reset error: $e');
        throw Exception('Password reset failed: $e');
      }
    }
  }

  Future<void> sendEmailVerification() async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.currentUser?.sendEmailVerification();
      } catch (e) {
        debugPrint('Send verification error: $e');
      }
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signOut();
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
      }
    }
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<UserModel> _getUserFromFirestore(
    String uid,
    String fallbackEmail,
  ) async {
    final db = _db;
    if (db != null) {
      try {
        final doc = await db
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          final model = UserModel.fromMap(doc.data()!, doc.id);
          _currentUser = model;
          return model;
        }
      } catch (e) {
        debugPrint('Firestore fetch notice: $e');
      }
    }

    final authUser = _auth?.currentUser;
    final fullName = (authUser?.displayName != null && authUser!.displayName!.isNotEmpty)
        ? authUser.displayName!
        : (_currentUser?.fullName ?? _formatNameFromEmail(fallbackEmail));

    final model = UserModel(
      uid: uid,
      email: fallbackEmail,
      fullName: fullName,
      phoneNumber: '',
      createdAt: DateTime.now(),
    );
    _currentUser = model;
    return model;
  }

  void dispose() {
    _authStateController.close();
  }
}
