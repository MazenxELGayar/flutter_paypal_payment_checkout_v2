part of '../paypal_service_v1.dart';

class PaypalTransactionV1Amount {
  final double subTotal;
  final double tax;
  final double total;
  final double shipping;
  final double handlingFee;
  final double shippingDiscount;
  final double insurance;
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
