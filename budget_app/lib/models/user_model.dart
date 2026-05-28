// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String currency;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.currency = 'PHP',
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:       doc.id,
      name:      data['name']     ?? '',
      email:     data['email']    ?? '',
      currency:  data['currency'] ?? 'PHP',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':      name,
    'email':     email,
    'currency':  currency,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({String? name, String? currency}) => UserModel(
    uid:       uid,
    name:      name      ?? this.name,
    email:     email,
    currency:  currency  ?? this.currency,
    createdAt: createdAt,
  );
}
