import 'package:e_signature/core/components/app_snackbar.dart';
import 'package:e_signature/core/enums/purchase_state_enum.dart';
import 'package:e_signature/core/services/in_app_purchase_service.dart';
import 'package:get/get.dart';

class SubscriptionController
    extends GetxController {
  final _iapService =
      Get.find<InAppPurchaseService>();

  final selectedPlan =
      "monthly".obs;

  Rx<PurchaseState> get purchaseState =>
      _iapService.purchaseState;

  String get weeklyPrice =>
      _iapService.weeklyProduct?.price ??
      "...";

  String get monthlyPrice =>
      _iapService.monthlyProduct?.price ??
      "...";

  String get yearlyPrice =>
      _iapService.yearlyProduct?.price ??
      "...";

  @override
  void onInit() {
    super.onInit();

    ever(
      purchaseState,
      _handlePurchaseState,
    );
  }

  /// =========================
  /// BUY
  /// =========================

  Future<void> subscribe() async {
    try {
      await _iapService.buySubscription(
        selectedPlan.value,
      );
    } catch (e) {
      AppSnackbar.error(
        "Error",
        e.toString(),
      );
    }
  }

  /// =========================
  /// RESTORE
  /// =========================

  Future<void> restorePurchases() async {
    await _iapService
        .restorePurchases();
  }

  /// =========================
  /// PLAN SELECT
  /// =========================

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  /// =========================
  /// STATE HANDLER
  /// =========================

  void _handlePurchaseState(
    PurchaseState state,
  ) {
    switch (state) {
      case PurchaseState.pending:
        AppSnackbar.success(
          "Pending",
          "Purchase pending",
        );
        break;

      case PurchaseState.purchased:
        AppSnackbar.success(
          "Success",
          "Subscription activated",
        );
        break;

      case PurchaseState.restored:
        AppSnackbar.success(
          "Success",
          "Purchases restored",
        );
        break;

      case PurchaseState.error:
        AppSnackbar.error(
          "Error",
          _iapService.errorMessage.value,
        );
        break;

      default:
        break;
    }
  }
}
