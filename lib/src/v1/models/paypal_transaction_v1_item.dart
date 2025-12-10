/// Represents an individual item within a PayPal **Payments API V1** transaction.
///
/// Items appear inside:
/// ```json
/// "item_list": {
///   "items": [ ... ]
/// }
/// ```
///
/// Each item must include:
/// - `name`
/// - `quantity`
/// - `price` (as string)
/// - `currency`
///
/// Optional fields include:
/// - `description`
/// - `tax`
/// - `sku`
///
/// Example:
/// ```json
/// {
///   "name": "T-Shirt",
///   "description": "Blue, Medium",
///   "quantity": 2,
///   "price": "25.00",
///   "tax": "3.00",
///   "sku": "TSHIRT-BLUE-M",
///   "currency": "USD"
/// }
/// ```
class PaypalTransactionV1Item {
  /// Item name presented to the payer.
  final String name;

  /// Optional description providing more item detail.
  final String description;

  /// Quantity of this item.
  final int quantity;

  /// Unit price (will be converted to string).
  final double price;

  /// Tax applied per item (also converted to string).
  final double tax;

  /// Optional SKU or internal reference code.
  final String sku;

  /// Currency for this item's price (e.g., `"USD"`).
  final String currency;

  PaypalTransactionV1Item({
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.tax,
    required this.sku,
    required this.currency,
  });

  /// Converts this item into PayPal's expected JSON structure.
  ///
  /// PayPal V1 requires `price` and `tax` as **strings**.
  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "quantity": quantity,
        "price": price.toString(),
        "tax": tax.toString(),
        "sku": sku,
        "currency": currency,
      };
}
