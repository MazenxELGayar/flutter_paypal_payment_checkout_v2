import 'package:flutter_paypal_payment_checkout_v2/src/v2/enums/pay_pal_item_category_v2.dart';

/// -------------------- PURCHASE UNITS / ITEMS --------------------

class PayPalAmountV2 {
  final String currency;
  final double value;
  final double itemTotal;
  final double taxTotal;

  PayPalAmountV2({
    required this.currency,
    required this.value,
    required this.itemTotal,
    required this.taxTotal,
  });

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

class PaypalTransactionV2Item {
  final String name;
  final String description;
  final int quantity;
  final double unitAmount;
  final String currency;
  final PayPalItemCategoryV2 category;
  final String sku;
  final String? imageUrl;
  final String? url;
  final String? upcCode; // optional
  final String? upcType; // optional, e.g., "UPC-A"

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

/// Define this according to your existing shipping model
class PayPalShippingAddressV2 {
  // Example fields:
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
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

class PayPalPurchaseUnitV2 {
  final String? invoiceId;
  final PayPalAmountV2 amount;
  final List<PaypalTransactionV2Item> items;
  final PayPalShippingAddressV2? shippingAddress;

  PayPalPurchaseUnitV2({
    this.invoiceId,
    required this.amount,
    required this.items,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
        if (invoiceId != null) "invoice_id": invoiceId,
        "amount": amount.toJson(),
        "items": items.map((e) => e.toJson()).toList(),
        if (shippingAddress != null) "shipping": shippingAddress!.toJson(),
      };
}
