/// Represents a shipping address for PayPal **Payments API V1**.
///
/// This maps directly to the `shipping_address` object inside a V1 transaction:
/// ```json
/// {
///   "shipping_address": {
///     "recipient_name": "...",
///     "line1": "...",
///     "line2": "...",
///     "city": "...",
///     "state": "...",
///     "postal_code": "...",
///     "country_code": "...",
///     "phone": "..."
///   }
/// }
/// ```
///
/// Notes:
/// - PayPal V1 requires `recipient_name`, address fields, state, and phone.
/// - `line2` is optional.
/// - Country code must follow ISO-3166-1 alpha-2 (e.g. `"US"`, `"GB"`, `"EG"`).
class PayPalShippingAddressV1 {
  /// Name of the recipient.
  final String recipientName;

  /// Primary address line (street address).
  final String line1;

  /// Additional address line (apartment, building, suite).
  final String? line2;

  /// City or locality.
  final String city;

  /// ISO country code (e.g. `"US"`, `"CA"`, `"EG"`).
  final String countryCode;

  /// Postal or ZIP code.
  final String postalCode;

  /// Recipient phone number in international format.
  final String phone;

  /// State, province, or region.
  final String state;

  PayPalShippingAddressV1({
    required this.recipientName,
    required this.line1,
    this.line2,
    required this.city,
    required this.countryCode,
    required this.postalCode,
    required this.phone,
    required this.state,
  });

  /// Converts this model into the JSON structure expected by PayPal V1.
  ///
  /// Only includes `line2` when provided.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "recipient_name": recipientName,
      "line1": line1,
      "city": city,
      "country_code": countryCode,
      "postal_code": postalCode,
      "phone": phone,
      "state": state,
    };

    if (line2 != null) {
      map["line2"] = line2;
    }

    return map;
  }
}
