import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_signature/core/models/purchase_payload_model.dart';

class FirebaseSubscriptionService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// =========================
  /// VERIFY + ACTIVATE
  /// =========================

  static Future<void>
      verifyAndActivateSubscription(
    PurchasePayloadModel payload,
  ) async {
    try {
      /// SAVE VERIFICATION LOG

      await _firestore
          .collection(
            "subscription_verifications",
          )
          .add(payload.toJson());

      /// TODO:
      /// VERIFY WITH BACKEND

      await activateSubscription(
        planType: payload.plan,
      );
    } catch (e) {
      log(
        "VERIFY SUBSCRIPTION ERROR => $e",
      );

      rethrow;
    }
  }

  /// =========================
  /// ACTIVATE
  /// =========================

  static Future<void>
      activateSubscription({
    required String planType,
  }) async {
    try {
      await _firestore
          .collection("subscriptions")
          .doc("USER_ID")
          .set({
        "isPremium": true,
        "planType": planType,
        "updatedAt":
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      log(
        "ACTIVATE SUBSCRIPTION ERROR => $e",
      );

      rethrow;
    }
  }
}
