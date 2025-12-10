/// Represents a shipping address for **PayPal Orders V2**.
///
/// Maps to:
/// `purchase_units[].shipping`
///
/// Example PayPal JSON:
/// ```json
/// {
///   "name": { "full_name": "John Doe" },
///   "address": {
///     "address_line_1": "123 Main St",
///     "address_line_2": "Apt 5",
///     "admin_area_1": "CA",
///     "admin_area_2": "San Francisco",
///     "postal_code": "94107",
///     "country_code": "US"
///   }
/// }
/// ```
class PayPalShippingAddressV2 {
  /// Full name of recipient.
  final String name;

  /// Address line 1 (street, building number).
  final String addressLine1;

  /// Optional address line 2.
  final String? addressLine2;

  /// City or locality.
  final String city;

  /// State, province, or region.
  final String state;

  /// ZIP or postal code.
  final String postalCode;

  /// ISO country code (e.g., "US", "CA", "EG").
  final String countryCode;

  PayPalShippingAddressV2({
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
  });

  /// Converts this address into PayPal V2 JSON format.
  Map<String, dynamic> toJson() => {
        "name": {
          "full_name": name,
        },
        "address": {
          "address_line_1": addressLine1,
          if (addressLine2 != null) "address_line_2": addressLine2,
          "admin_area_2": city,
          "admin_area_1": state,
          "postal_code": postalCode,
          "country_code": countryCode,
        },
      };
}
