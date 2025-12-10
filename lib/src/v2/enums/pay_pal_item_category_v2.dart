

/// PayPal Orders V2 Item Category
enum PayPalItemCategoryV2 {
  physicalGoods,
  digitalGoods,
  donation;

  /// Convert enum → API string
  String get value {
    switch (this) {
      case PayPalItemCategoryV2.physicalGoods:
        return "PHYSICAL_GOODS";
      case PayPalItemCategoryV2.digitalGoods:
        return "DIGITAL_GOODS";
      case PayPalItemCategoryV2.donation:
        return "DONATION";
    }
  }

  /// Convert API string → enum
  static PayPalItemCategoryV2 fromString(String raw) {
    switch (raw) {
      case "PHYSICAL_GOODS":
        return PayPalItemCategoryV2.physicalGoods;
      case "DIGITAL_GOODS":
        return PayPalItemCategoryV2.digitalGoods;
      case "DONATION":
        return PayPalItemCategoryV2.donation;
      default:
        throw ArgumentError("Invalid PayPalItemCategory: $raw");
    }
  }
}
