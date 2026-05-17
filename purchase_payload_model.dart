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

  factory PurchasePayloadModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchasePayloadModel(
      productId: json['productId'],
      purchaseId: json['purchaseId'],
      verificationData:
          json['verificationData'],
      source: json['source'],
      transactionDate:
          json['transactionDate'],
      platform: json['platform'],
      plan: json['plan'],
      isRestore: json['isRestore'],
    );
  }
}
