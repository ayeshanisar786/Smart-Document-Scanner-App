import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final bool isPremium;
  final DateTime? subscriptionExpires;
  final int scansThisMonth;
  final int scanLimit;
  final DateTime? lastScanReset;
  final String? subscriptionPlatform;
  final String? subscriptionProductId;

  UserModel({
    required this.uid,
    this.isPremium = false,
    this.subscriptionExpires,
    this.scansThisMonth = 0,
    this.scanLimit = 10,
    this.lastScanReset,
    this.subscriptionPlatform,
    this.subscriptionProductId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      isPremium: data['isPremium'] ?? false,
      subscriptionExpires: data['subscriptionExpires'] != null
          ? (data['subscriptionExpires'] as Timestamp).toDate()
          : null,
      scansThisMonth: data['scansThisMonth'] ?? 0,
      scanLimit: data['scanLimit'] ?? 10,
      lastScanReset: data['lastScanReset'] != null
          ? (data['lastScanReset'] as Timestamp).toDate()
          : null,
      subscriptionPlatform: data['subscriptionPlatform'],
      subscriptionProductId: data['subscriptionProductId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isPremium': isPremium,
      'subscriptionExpires': subscriptionExpires != null
          ? Timestamp.fromDate(subscriptionExpires!)
          : null,
      'scansThisMonth': scansThisMonth,
      'scanLimit': scanLimit,
      'lastScanReset':
          lastScanReset != null ? Timestamp.fromDate(lastScanReset!) : null,
      'subscriptionPlatform': subscriptionPlatform,
      'subscriptionProductId': subscriptionProductId,
    };
  }

  bool get hasScansRemaining => isPremium || scansThisMonth < scanLimit;
  int get remainingScans => isPremium ? -1 : scanLimit - scansThisMonth;
}
