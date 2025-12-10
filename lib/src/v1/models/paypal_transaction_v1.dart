import 'package:flutter_paypal_payment_checkout_v2/src/v1/enums/paypal_allowed_payment_method_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/models/paypal_shipping_address_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/models/paypal_transaction_v1_amount.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/models/paypal_transaction_v1_item.dart';

/// Represents a single PayPal **Payments API V1 transaction**.
///
/// V1 transactions are part of the request body in:
/// `POST /v1/payments/payment`
///
/// Each transaction defines:
/// - `amount` (total, currency, details)
/// - `description`
/// - `custom` metadata
/// - `item_list` (items + optional shipping address)
/// - Optional invoice number
/// - Optional payment restrictions (allowed payment method)
/// - Optional soft descriptor (bank statement description)
///
/// Example (simplified):
/// ```json
/// {
///   "amount": { ... },
///   "description": "Order #123",
///   "item_list": {
///     "items": [ ... ],
///     "shipping_address": { ... }
///   },
///   "invoice_number": "INV-1234",
///   "payment_options": {
///     "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
///   },
///   "soft_descriptor": "MYSHOP*ORDER"
/// }
/// ```
class PaypalTransactionV1 {
  /// Full amount breakdown (subtotal, tax, shipping, total).
  final PaypalTransactionV1Amount amount;

  /// Description of the transaction shown to the payer.
  final String description;

  /// Custom field returned in PayPal webhooks / API responses.
  ///
  /// Often used to store internal metadata (order IDs, user IDs, etc.).
  final dynamic custom;

  /// List of items making up the transaction.
  final List<PaypalTransactionV1Item> items;

  /// Optional shipping address used for this transaction.
  final PayPalShippingAddressV1? shippingAddress;

  /// Optional invoice number.
  ///
  /// Helps prevent duplicate transactions and is shown inside PayPal.
  final String? invoiceNumber;

  /// Limits what funding sources PayPal may use.
  ///
  /// Useful to force instant payment methods or unrestricted behavior.
  final PayPalAllowedPaymentMethodV1? payPalAllowedPaymentMethod;

  /// Optional business descriptor shown on the buyer’s bank statement.
  final String? softDescriptor;

  PaypalTransactionV1({
    required this.amount,
    required this.description,
    required this.custom,
    required this.items,
    this.shippingAddress,
    this.invoiceNumber,
    this.payPalAllowedPaymentMethod,
    this.softDescriptor,
  });

  /// Converts this transaction into the JSON structure expected by PayPal V1.
  ///
  /// Only includes optional fields when present.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "amount": amount.toJson(),
      "description": description,
      "custom": custom,
      "item_list": {
        "items": items.map((e) => e.toJson()).toList(),
        if (shippingAddress != null)
          "shipping_address": shippingAddress!.toJson(),
      },
    };

    if (invoiceNumber != null) {
      map["invoice_number"] = invoiceNumber;
    }

    if (payPalAllowedPaymentMethod != null) {
      map["payment_options"] = {
        "allowed_payment_method": payPalAllowedPaymentMethod?.value,
      };
    }

    if (softDescriptor != null) {
      map["soft_descriptor"] = softDescriptor;
    }

    return map;
  }
}
