import 'package:flutter_paypal_payment_checkout_v2/flutter_paypal_payment_checkout_v2.dart';

/// Represents a single line item in a **PayPal Orders V2** purchase unit.
///
/// Maps to:
/// `purchase_units[].items[]`
///
/// Example JSON:
/// ```json
/// {
///   "name": "T-Shirt",
///   "description": "Blue, Size M",
///   "unit_amount": { "currency_code": "USD", "value": "25.00" },
///   "quantity": "2",
///   "category": "PHYSICAL_GOODS",
///   "sku": "TSHIRT-BLUE-M",
///   "image_url": "https://example.com/img.jpg",
///   "url": "https://example.com/product",
///   "upc": { "type": "UPC-A", "code": "123456789012" }
/// }
/// ```
class PaypalTransactionV2Item {
  /// Product name (required).
  final String name;

  /// Item description shown during checkout.
  final String description;

  /// Item quantity (must be sent as a string).
  final int quantity;

  /// Unit price per item.
  final double unitAmount;

  /// Currency code for price.
  final String currency;

  /// PayPal-defined item category (physical, digital, donation).
  final PayPalItemCategoryV2 category;

  /// SKU or internal product identifier.
  final String sku;

  /// Optional product image URL.
  final String? imageUrl;

  /// Optional product detail page URL.
  final String? url;

  /// Optional barcode value (UPC).
  final String? upcCode;

  /// Optional barcode type ("UPC-A", "UPC-E", etc.).
  final String? upcType;

  PaypalTransactionV2Item({
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitAmount,
    required this.currency,
    required this.category,
    required this.sku,
    this.imageUrl,
    this.url,
    this.upcCode,
    this.upcType,
  });

  /// Converts this item to PayPal V2 JSON.
  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "unit_amount": {
          "currency_code": currency,
          "value": unitAmount.toString(),
        },
        "quantity": quantity.toString(),
        "category": category.value,
        "sku": sku,
        if (imageUrl != null) "image_url": imageUrl,
        if (url != null) "url": url,
        if (upcCode != null)
          "upc": {
            "type": upcType ?? "UPC-A",
            "code": upcCode,
          },
      };
}
