import 'package:e_signature/core/services/in_app_purchase_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<InAppPurchaseService>(
      () async =>
          await InAppPurchaseService()
              .init(),
      permanent: true,
    );
  }
}
