part of '../paypal_service_v1.dart';

class PaypalTransactionV1 {
  final PaypalTransactionV1Amount amount;
  final String description;
  final dynamic custom;
  final List<PaypalTransactionV1Item> items;
  final PayPalShippingAddressV1? shippingAddress;

  final String? invoiceNumber;
  final PayPalAllowedPaymentMethodV1? payPalAllowedPaymentMethod;
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
