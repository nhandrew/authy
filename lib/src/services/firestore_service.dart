import 'package:authy/src/models/authy_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUser(AuthyUser user){
    return _db.collection('users').doc(user.userId).set(user.toMap());
  }
  
  Future<void> updateEmailVerified({
    @required String userId,
    @required String email,
    @required String displayName,
    @required bool verified}){
    _db.collection('users').doc(userId).update({
      'verified': verified,
      'display_name':displayName,
      'email' : email
    });
  }

  Future<AuthyUser> getUser(String userId){
      return _db
          .collection('users')
          .doc(userId)
          .get()
          .then((snapshot) => AuthyUser.fromJson(snapshot.data()));
  }
}