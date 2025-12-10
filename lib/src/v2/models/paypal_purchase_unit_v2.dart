import 'package:flutter_paypal_payment_checkout_v2/src/v2/models/paypal_amount_v2.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/models/paypal_shipping_address_v2.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/models/paypal_transaction_item_v2.dart';

/// Represents a **purchase unit** in PayPal Orders V2.
///
/// Each purchase unit contains:
/// - Amount & breakdown
/// - Items
/// - Optional invoice ID
/// - Optional shipping information
///
/// Maps to:
/// `purchase_units[]`
///
/// Example:
/// ```json
/// {
///   "invoice_id": "INV-123",
///   "amount": { ... },
///   "items": [ ... ],
///   "shipping": { ... }
/// }
/// ```
class PayPalPurchaseUnitV2 {
  /// Optional invoice identifier.
  ///
  /// Helps prevent duplicate transactions.
  final String? invoiceId;

  /// Total monetary amount and its breakdown.
  final PayPalAmountV2 amount;

  /// List of items inside this purchase unit.
  final List<PaypalTransactionV2Item> items;

  /// Optional shipping address.
  final PayPalShippingAddressV2? shippingAddress;

  PayPalPurchaseUnitV2({
    this.invoiceId,
    required this.amount,
    required this.items,
    this.shippingAddress,
  });

  /// Converts this purchase unit to PayPal V2 JSON.
  Map<String, dynamic> toJson() => {
        if (invoiceId != null) "invoice_id": invoiceId,
        "amount": amount.toJson(),
        "items": items.map((e) => e.toJson()).toList(),
        if (shippingAddress != null) "shipping": shippingAddress!.toJson(),
      };
}
