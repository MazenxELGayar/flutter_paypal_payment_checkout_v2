

class PaypalTransactionV1Item {
  final String name;
  final String description;
  final int quantity;
  final double price;
  final double tax;
  final String sku;
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
