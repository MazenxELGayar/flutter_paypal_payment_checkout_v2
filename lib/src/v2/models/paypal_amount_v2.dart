/// Represents the total amount and breakdown for a **PayPal Orders V2**
/// purchase unit.
///
/// Maps to:
/// `purchase_units[].amount`
///
/// Example PayPal JSON:
/// ```json
/// {
///   "currency_code": "USD",
///   "value": "100.00",
///   "breakdown": {
///     "item_total": { "currency_code": "USD", "value": "90.00" },
///     "tax_total": { "currency_code": "USD", "value": "10.00" }
///   }
/// }
/// ```
///
/// Notes:
/// - All numeric values must be serialized as strings.
/// - `value` must equal the sum of `item_total + tax_total` unless using
///   additional fields like shipping, handling, etc.
class PayPalAmountV2 {
  /// Currency code (e.g., "USD", "EUR", "EGP").
  final String currency;

  /// Total order amount (as decimal, converted to string in JSON).
  final double value;

  /// Sum of all item amounts before tax.
  final double itemTotal;

  /// Total tax applied across all items.
  final double taxTotal;

  PayPalAmountV2({
    required this.currency,
    required this.value,
    required this.itemTotal,
    required this.taxTotal,
  });

  /// Converts this amount into PayPal V2 amount JSON.
  Map<String, dynamic> toJson() => {
        "currency_code": currency,
        "value": value.toString(),
        "breakdown": {
          "item_total": {
            "currency_code": currency,
            "value": itemTotal.toString(),
          },
          "tax_total": {
            "currency_code": currency,
            "value": taxTotal.toString(),
          },
        }
      };
}
