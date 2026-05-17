import 'dart:async';
import 'dart:developer';

import 'package:e_signature/core/enums/purchase_state_enum.dart';
import 'package:e_signature/core/extensions/iterable_extension.dart';
import 'package:e_signature/core/services/firebase_subscription_service.dart';
import 'package:e_signature/core/services/purchase_product_ids.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchasePayloadModel {
  final String productId;

  final String purchaseId;

  final String verificationData;

  final String source;

  final String? transactionDate;

  final String platform;

  final String plan;

  final bool isRestore;

  PurchasePayloadModel({
    required this.productId,
    required this.purchaseId,
    required this.verificationData,
    required this.source,
    required this.transactionDate,
    required this.platform,
    required this.plan,
    required this.isRestore,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "purchaseId": purchaseId,
      "verificationData": verificationData,
      "source": source,
      "transactionDate": transactionDate,
      "platform": platform,
      "plan": plan,
      "isRestore": isRestore,
    };
  }
}

class InAppPurchaseService extends GetxService {
  final InAppPurchase _iap =
      InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>?
      _subscription;

  final RxList<ProductDetails> _products =
      <ProductDetails>[].obs;

  List<ProductDetails> get products =>
      _products;

  final purchaseState =
      PurchaseState.idle.obs;

  final errorMessage = ''.obs;

  final isStoreAvailable = false.obs;

  /// =========================
  /// INIT
  /// =========================

  Future<InAppPurchaseService> init() async {
    await initialize();

    return this;
  }

  Future<void> initialize() async {
    try {
      final available =
          await _iap.isAvailable();

      isStoreAvailable.value =
          available;

      if (!available) {
        errorMessage.value =
            "Store unavailable";

        return;
      }

      await loadProducts();

      _listenToPurchases();

      await syncPurchases();
    } catch (e) {
      errorMessage.value = e.toString();

      log("IAP INITIALIZE ERROR => $e");
    }
  }

  /// =========================
  /// LOAD PRODUCTS
  /// =========================

  Future<void> loadProducts() async {
    try {
      final response =
          await _iap.queryProductDetails(
        PurchaseProductIds.all,
      );

      if (response.error != null) {
        throw Exception(
          response.error!.message,
        );
      }

      _products.assignAll(
        response.productDetails,
      );

      log(
        "PRODUCTS LOADED => ${_products.length}",
      );
    } catch (e) {
      errorMessage.value = e.toString();

      log("LOAD PRODUCTS ERROR => $e");
    }
  }

  /// =========================
  /// PRODUCT HELPERS
  /// =========================

  ProductDetails? _findProduct(
    String id,
  ) {
    return _products.firstWhereOrNull(
      (e) => e.id == id,
    );
  }

  ProductDetails? get weeklyProduct {
    return _findProduct(
      PurchaseProductIds.weekly,
    );
  }

  ProductDetails? get monthlyProduct {
    return _findProduct(
      PurchaseProductIds.monthly,
    );
  }

  ProductDetails? get yearlyProduct {
    return _findProduct(
      PurchaseProductIds.yearly,
    );
  }

  /// =========================
  /// BUY SUBSCRIPTION
  /// =========================

  Future<void> buySubscription(
    String plan,
  ) async {
    try {
      if (purchaseState.value ==
          PurchaseState.loading) {
        return;
      }

      purchaseState.value =
          PurchaseState.loading;

      final productId =
          _getProductId(plan);

      final product =
          _findProduct(productId);

      if (product == null) {
        throw Exception(
          "Product not found",
        );
      }

      final purchaseParam =
          PurchaseParam(
        productDetails: product,
      );

      log(
        "BUYING SUBSCRIPTION => ${product.id}",
      );

      await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      purchaseState.value =
          PurchaseState.error;

      errorMessage.value = e.toString();

      log("BUY SUBSCRIPTION ERROR => $e");

      rethrow;
    }
  }

  /// =========================
  /// RESTORE PURCHASES
  /// =========================

  Future<void> restorePurchases() async {
    try {
      purchaseState.value =
          PurchaseState.loading;

      await _iap.restorePurchases();

      log("PURCHASES RESTORED");
    } catch (e) {
      purchaseState.value =
          PurchaseState.error;

      errorMessage.value = e.toString();

      log("RESTORE ERROR => $e");
    }
  }

  /// =========================
  /// SYNC PURCHASES
  /// =========================

  Future<void> syncPurchases() async {
    try {
      await _iap.restorePurchases();

      log("SYNC PURCHASES SUCCESS");
    } catch (e) {
      log("SYNC PURCHASES ERROR => $e");
    }
  }

  /// =========================
  /// PURCHASE LISTENER
  /// =========================

  void _listenToPurchases() {
    _subscription?.cancel();

    _subscription =
        _iap.purchaseStream.listen(
      (purchases) async {
        log(
          "PURCHASE STREAM => ${purchases.length}",
        );

        for (final purchase in purchases) {
          await _handlePurchase(
            purchase,
          );
        }
      },
      onError: (e) {
        purchaseState.value =
            PurchaseState.error;

        errorMessage.value = e.toString();

        log(
          "PURCHASE STREAM ERROR => $e",
        );
      },
    );
  }

  /// =========================
  /// HANDLE PURCHASE
  /// =========================

  Future<void> _handlePurchase(
    PurchaseDetails purchase,
  ) async {
    try {
      log(
        "PURCHASE STATUS => ${purchase.status}",
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          purchaseState.value =
              PurchaseState.pending;

          break;

        case PurchaseStatus.error:
          purchaseState.value =
              PurchaseState.error;

          errorMessage.value =
              purchase.error?.message ??
                  "Purchase failed";

          log(
            "PURCHASE ERROR => ${purchase.error}",
          );

          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final plan =
              PurchaseProductIds
                  .getPlanFromProductId(
            purchase.productID,
          );

          final payload =
              PurchasePayloadModel(
            productId:
                purchase.productID,

            purchaseId:
                purchase.purchaseID ??
                    '',

            verificationData:
                purchase
                    .verificationData
                    .serverVerificationData,

            source:
                purchase
                    .verificationData
                    .source,

            transactionDate:
                purchase.transactionDate,

            platform:
                GetPlatform.isIOS
                    ? "ios"
                    : "android",

            plan: plan,

            isRestore:
                purchase.status ==
                    PurchaseStatus
                        .restored,
          );

          log(
            "PURCHASE PAYLOAD => ${payload.toJson()}",
          );

          /// =========================
          /// SEND TO BACKEND
          /// =========================

          await FirebaseSubscriptionService
              .verifyAndActivateSubscription(
            payload,
          );

          /// =========================
          /// COMPLETE PURCHASE
          /// =========================

          if (purchase
              .pendingCompletePurchase) {
            await _iap.completePurchase(
              purchase,
            );
          }

          purchaseState.value =
              purchase.status ==
                      PurchaseStatus
                          .restored
                  ? PurchaseState
                      .restored
                  : PurchaseState
                      .purchased;

          break;

        case PurchaseStatus.canceled:
          purchaseState.value =
              PurchaseState.idle;

          log("PURCHASE CANCELED");

          break;
      }
    } catch (e) {
      purchaseState.value =
          PurchaseState.error;

      errorMessage.value = e.toString();

      log("HANDLE PURCHASE ERROR => $e");
    }
  }

  /// =========================
  /// HELPERS
  /// =========================

  String _getProductId(String plan) {
    switch (plan) {
      case "weekly":
        return PurchaseProductIds
            .weekly;

      case "yearly":
        return PurchaseProductIds
            .yearly;

      default:
        return PurchaseProductIds
            .monthly;
    }
  }

  /// =========================
  /// DISPOSE
  /// =========================

  @override
  void onClose() {
    _subscription?.cancel();

    super.onClose();
  }
}
