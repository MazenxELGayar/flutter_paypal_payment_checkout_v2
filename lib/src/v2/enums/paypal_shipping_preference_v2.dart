/// PayPal Orders V2 `shipping_preference`
///
/// Controls how PayPal handles shipping addresses during checkout.
///
/// Maps to:
/// `application_context.shipping_preference`
///
/// - **GET_FROM_FILE**
///   Use buyer’s PayPal-saved address.
///
/// - **NO_SHIPPING**
///   No address required (digital items, services, subscriptions).
///
/// - **SET_PROVIDED_ADDRESS**
///   Use the address in your API request.
///   ❗ Buyer cannot change it on PayPal.
enum PayPalShippingPreferenceV2 {
  getFromFile,
  noShipping,
  setProvidedAddress;

  /// Converts enum → PayPal API string.
  String get value {
    switch (this) {
      case PayPalShippingPreferenceV2.getFromFile:
        return "GET_FROM_FILE";
      case PayPalShippingPreferenceV2.noShipping:
        return "NO_SHIPPING";
      case PayPalShippingPreferenceV2.setProvidedAddress:
        return "SET_PROVIDED_ADDRESS";
    }
  }

  /// Converts API string → enum value.
  ///
  /// Throws [ArgumentError] for unknown values.
  static PayPalShippingPreferenceV2 fromString(String raw) {
    switch (raw) {
      case "GET_FROM_FILE":
        return PayPalShippingPreferenceV2.getFromFile;
      case "NO_SHIPPING":
        return PayPalShippingPreferenceV2.noShipping;
      case "SET_PROVIDED_ADDRESS":
        return PayPalShippingPreferenceV2.setProvidedAddress;
      default:
        throw ArgumentError("Invalid PayPalShippingPreference: $raw");
    }
  }
}
