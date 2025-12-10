/// Represents the item category for **PayPal Orders V2**.
///
/// Maps directly to:
/// `purchase_units[].items[].category`
///
/// Categories:
/// - **PHYSICAL_GOODS**  → Tangible items that require shipping.
/// - **DIGITAL_GOODS**   → Downloadable or software products.
/// - **DONATION**        → Contributions to nonprofits or charities.
enum PayPalItemCategoryV2 {
  physicalGoods,
  digitalGoods,
  donation;

  /// Converts enum → PayPal API string.
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

  /// Converts API string → enum value.
  ///
  /// Throws [ArgumentError] for unknown values.
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
