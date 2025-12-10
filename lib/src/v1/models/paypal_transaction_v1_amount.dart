/// Represents the full amount breakdown for a PayPal **Payments API V1** transaction.
///
/// This corresponds to the V1 field:
/// ```json
/// "amount": {
///   "total": "100.00",
///   "currency": "USD",
///   "details": {
///     "subtotal": "80.00",
///     "tax": "10.00",
///     "shipping": "5.00",
///     "handling_fee": "2.00",
///     "shipping_discount": "-2.00",
///     "insurance": "5.00"
///   }
/// }
/// ```
///
/// Notes:
/// - All numeric values must be sent as **strings**—this is a PayPal V1 requirement.
/// - `total` must equal the mathematical sum of the components.
class PaypalTransactionV1Amount {
  /// Items subtotal before taxes and fees.
  final double subTotal;

  /// Total tax amount applied across items.
  final double tax;

  /// Total charge to the payer (must match PayPal validation rules).
  final double total;

  /// Shipping charge.
  final double shipping;

  /// Handling fee added to the transaction.
  final double handlingFee;

  /// Discount applied to shipping (often negative).
  final double shippingDiscount;

  /// Insurance cost associated with the transaction.
  final double insurance;

  /// Currency code (e.g., `"USD"`, `"EUR"`, `"EGP"`).
  final String currency;

  PaypalTransactionV1Amount({
    required this.subTotal,
    required this.tax,
    required this.total,
    required this.shipping,
    required this.handlingFee,
    required this.shippingDiscount,
    required this.insurance,
    required this.currency,
  });

  /// Converts this amount structure into the JSON expected by PayPal V1.
  ///
  /// All numeric fields are converted to strings.
  Map<String, dynamic> toJson() => {
        "total": total.toString(),
        "currency": currency,
        "subtotal": subTotal.toString(),
        "tax": tax.toString(),
        "shipping": shipping.toString(),
        "handling_fee": handlingFee.toString(),
        "shipping_discount": shippingDiscount.toString(),
        "insurance": insurance.toString(),
      };
}
