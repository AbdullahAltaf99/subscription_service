import 'dart:io';

class PurchaseProductIds {
  PurchaseProductIds._();

  /// ANDROID
  static const _androidWeekly =
      'com.xxxx.xxxx.xxxx.weekly';

  static const _androidMonthly =
      'com.xxxx.xxxx.xxxx.monthly';

  static const _androidYearly =
      'com.xxxx.xxxx.xxxx.yearly';

  /// IOS
  static const _iosWeekly =
      'com.xxxx.xxxx.xxxx.weekly';

  static const _iosMonthly =
      'com.xxxx.xxxx.xxxx.monthly';

  static const _iosYearly =
      'com.xxxx.xxxx.xxxx.yearly';

  static String get weekly =>
      Platform.isIOS
          ? _iosWeekly
          : _androidWeekly;

  static String get monthly =>
      Platform.isIOS
          ? _iosMonthly
          : _androidMonthly;

  static String get yearly =>
      Platform.isIOS
          ? _iosYearly
          : _androidYearly;

  static Set<String> get all => {
        weekly,
        monthly,
        yearly,
      };

  static String getPlanFromProductId(
    String id,
  ) {
    if (id == weekly) {
      return "weekly";
    }

    if (id == yearly) {
      return "yearly";
    }

    return "monthly";
  }
}  
