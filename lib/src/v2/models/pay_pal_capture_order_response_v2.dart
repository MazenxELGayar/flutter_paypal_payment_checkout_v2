// import 'package:flutter/foundation.dart';
//
// typedef PayPalOnSuccessV2 = dynamic Function(
//     PayPalCaptureOrderResponse response);
//
// /// Root: /v2/checkout/orders/{id}/capture response
// class PayPalCaptureOrderResponse {
//   final PayPalCaptureOrderParsedResponse? parsedResponse;
//   final Map<String, dynamic> raw;
//
//   PayPalCaptureOrderResponse({
//     required this.parsedResponse,
//     required this.raw,
//   });
//
//   factory PayPalCaptureOrderResponse.fromJson(Map<String, dynamic> json) {
//     try {
//       final parsed = PayPalCaptureOrderParsedResponse(
//         id: json['id'] as String,
//         status: json['status'] as String,
//         paymentSource: json['payment_source'] != null
//             ? PayPalCapturePaymentSource.fromJson(
//                 json['payment_source'] as Map<String, dynamic>,
//               )
//             : null,
//         purchaseUnits: (json['purchase_units'] as List<dynamic>? ?? [])
//             .map((e) =>
//                 PayPalCapturePurchaseUnit.fromJson(e as Map<String, dynamic>))
//             .toList(),
//         payer: json['payer'] != null
//             ? PayPalPayer.fromJson(json['payer'] as Map<String, dynamic>)
//             : null,
//         links: (json['links'] as List<dynamic>? ?? [])
//             .map((e) => PayPalLink.fromJson(e as Map<String, dynamic>))
//             .toList(),
//       );
//       return PayPalCaptureOrderResponse(
//         parsedResponse: parsed,
//         raw: json,
//       );
//     } catch (e, trace) {
//       if (kDebugMode) {
//         print(
//           "couldn't parse response model: $e\n$trace",
//         );
//       }
//       return PayPalCaptureOrderResponse(
//         parsedResponse: null,
//         raw: json,
//       );
//     }
//   }
// }
//
// class PayPalCaptureOrderParsedResponse {
//   final String id;
//   final String status;
//   final PayPalCapturePaymentSource? paymentSource;
//   final List<PayPalCapturePurchaseUnit> purchaseUnits;
//   final PayPalPayer? payer;
//   final List<PayPalLink> links;
//
//   PayPalCaptureOrderParsedResponse({
//     required this.id,
//     required this.status,
//     required this.purchaseUnits,
//     required this.links,
//     this.paymentSource,
//     this.payer,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'status': status,
//         if (paymentSource != null) 'payment_source': paymentSource!.toJson(),
//         'purchase_units': purchaseUnits.map((e) => e.toJson()).toList(),
//         if (payer != null) 'payer': payer!.toJson(),
//         'links': links.map((e) => e.toJson()).toList(),
//       };
// }
//
// /// ---------------- PAYMENT SOURCE (paypal) ----------------
//
// class PayPalCapturePaymentSource {
//   final PayPalPaymentSourcePaypal? paypal;
//
//   PayPalCapturePaymentSource({this.paypal});
//
//   factory PayPalCapturePaymentSource.fromJson(Map<String, dynamic> json) {
//     return PayPalCapturePaymentSource(
//       paypal: json['paypal'] != null
//           ? PayPalPaymentSourcePaypal.fromJson(
//               json['paypal'] as Map<String, dynamic>,
//             )
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (paypal != null) 'paypal': paypal!.toJson(),
//       };
// }
//
// class PayPalPaymentSourcePaypal {
//   final PayPalName? name;
//   final String? emailAddress;
//   final String? accountId;
//
//   PayPalPaymentSourcePaypal({
//     this.name,
//     this.emailAddress,
//     this.accountId,
//   });
//
//   factory PayPalPaymentSourcePaypal.fromJson(Map<String, dynamic> json) {
//     return PayPalPaymentSourcePaypal(
//       name: json['name'] != null
//           ? PayPalName.fromJson(json['name'] as Map<String, dynamic>)
//           : null,
//       emailAddress: json['email_address'] as String?,
//       accountId: json['account_id'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (name != null) 'name': name!.toJson(),
//         if (emailAddress != null) 'email_address': emailAddress,
//         if (accountId != null) 'account_id': accountId,
//       };
// }
//
// /// ---------------- PURCHASE UNIT + SHIPPING + PAYMENTS ----------------
//
// class PayPalCapturePurchaseUnit {
//   final String? referenceId;
//   final PayPalShipping? shipping;
//   final PayPalPurchaseUnitPayments? payments;
//
//   PayPalCapturePurchaseUnit({
//     this.referenceId,
//     this.shipping,
//     this.payments,
//   });
//
//   factory PayPalCapturePurchaseUnit.fromJson(Map<String, dynamic> json) {
//     return PayPalCapturePurchaseUnit(
//       referenceId: json['reference_id'] as String?,
//       shipping: json['shipping'] != null
//           ? PayPalShipping.fromJson(json['shipping'] as Map<String, dynamic>)
//           : null,
//       payments: json['payments'] != null
//           ? PayPalPurchaseUnitPayments.fromJson(
//               json['payments'] as Map<String, dynamic>,
//             )
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (referenceId != null) 'reference_id': referenceId,
//         if (shipping != null) 'shipping': shipping!.toJson(),
//         if (payments != null) 'payments': payments!.toJson(),
//       };
// }
//
// class PayPalShipping {
//   final PayPalAddress? address;
//
//   PayPalShipping({this.address});
//
//   factory PayPalShipping.fromJson(Map<String, dynamic> json) {
//     return PayPalShipping(
//       address: json['address'] != null
//           ? PayPalAddress.fromJson(json['address'] as Map<String, dynamic>)
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (address != null) 'address': address!.toJson(),
//       };
// }
//
// class PayPalAddress {
//   final String? addressLine1;
//   final String? addressLine2;
//   final String? adminArea2;
//   final String? adminArea1;
//   final String? postalCode;
//   final String? countryCode;
//
//   PayPalAddress({
//     this.addressLine1,
//     this.addressLine2,
//     this.adminArea2,
//     this.adminArea1,
//     this.postalCode,
//     this.countryCode,
//   });
//
//   factory PayPalAddress.fromJson(Map<String, dynamic> json) {
//     return PayPalAddress(
//       addressLine1: json['address_line_1'] as String?,
//       addressLine2: json['address_line_2'] as String?,
//       adminArea2: json['admin_area_2'] as String?,
//       adminArea1: json['admin_area_1'] as String?,
//       postalCode: json['postal_code'] as String?,
//       countryCode: json['country_code'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (addressLine1 != null) 'address_line_1': addressLine1,
//         if (addressLine2 != null) 'address_line_2': addressLine2,
//         if (adminArea2 != null) 'admin_area_2': adminArea2,
//         if (adminArea1 != null) 'admin_area_1': adminArea1,
//         if (postalCode != null) 'postal_code': postalCode,
//         if (countryCode != null) 'country_code': countryCode,
//       };
// }
//
// class PayPalPurchaseUnitPayments {
//   final List<PayPalCapture> captures;
//
//   PayPalPurchaseUnitPayments({required this.captures});
//
//   factory PayPalPurchaseUnitPayments.fromJson(Map<String, dynamic> json) {
//     return PayPalPurchaseUnitPayments(
//       captures: (json['captures'] as List<dynamic>? ?? [])
//           .map((e) => PayPalCapture.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'captures': captures.map((e) => e.toJson()).toList(),
//       };
// }
//
// /// ---------------- CAPTURE + MONEY + SELLER PROTECTION ----------------
//
// class PayPalCapture {
//   final String id;
//   final String status;
//   final PayPalMoney amount;
//   final PayPalSellerProtection? sellerProtection;
//   final bool? finalCapture;
//   final String? disbursementMode;
//   final PayPalSellerReceivableBreakdown? sellerReceivableBreakdown;
//   final DateTime? createTime;
//   final DateTime? updateTime;
//   final List<PayPalLink> links;
//
//   PayPalCapture({
//     required this.id,
//     required this.status,
//     required this.amount,
//     required this.links,
//     this.sellerProtection,
//     this.finalCapture,
//     this.disbursementMode,
//     this.sellerReceivableBreakdown,
//     this.createTime,
//     this.updateTime,
//   });
//
//   factory PayPalCapture.fromJson(Map<String, dynamic> json) {
//     return PayPalCapture(
//       id: json['id'] as String,
//       status: json['status'] as String,
//       amount: PayPalMoney.fromJson(json['amount'] as Map<String, dynamic>),
//       sellerProtection: json['seller_protection'] != null
//           ? PayPalSellerProtection.fromJson(
//               json['seller_protection'] as Map<String, dynamic>,
//             )
//           : null,
//       finalCapture: json['final_capture'] as bool?,
//       disbursementMode: json['disbursement_mode'] as String?,
//       sellerReceivableBreakdown: json['seller_receivable_breakdown'] != null
//           ? PayPalSellerReceivableBreakdown.fromJson(
//               json['seller_receivable_breakdown'] as Map<String, dynamic>,
//             )
//           : null,
//       createTime: json['create_time'] != null
//           ? DateTime.parse(json['create_time'] as String)
//           : null,
//       updateTime: json['update_time'] != null
//           ? DateTime.parse(json['update_time'] as String)
//           : null,
//       links: (json['links'] as List<dynamic>? ?? [])
//           .map((e) => PayPalLink.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'status': status,
//         'amount': amount.toJson(),
//         if (sellerProtection != null)
//           'seller_protection': sellerProtection!.toJson(),
//         if (finalCapture != null) 'final_capture': finalCapture,
//         if (disbursementMode != null) 'disbursement_mode': disbursementMode,
//         if (sellerReceivableBreakdown != null)
//           'seller_receivable_breakdown': sellerReceivableBreakdown!.toJson(),
//         if (createTime != null) 'create_time': createTime!.toIso8601String(),
//         if (updateTime != null) 'update_time': updateTime!.toIso8601String(),
//         'links': links.map((e) => e.toJson()).toList(),
//       };
// }
//
// class PayPalMoney {
//   final String currencyCode;
//   final String value;
//
//   PayPalMoney({
//     required this.currencyCode,
//     required this.value,
//   });
//
//   factory PayPalMoney.fromJson(Map<String, dynamic> json) {
//     return PayPalMoney(
//       currencyCode: json['currency_code'] as String,
//       value: json['value'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'currency_code': currencyCode,
//         'value': value,
//       };
// }
//
// class PayPalSellerProtection {
//   final String status;
//   final List<String> disputeCategories;
//
//   PayPalSellerProtection({
//     required this.status,
//     required this.disputeCategories,
//   });
//
//   factory PayPalSellerProtection.fromJson(Map<String, dynamic> json) {
//     return PayPalSellerProtection(
//       status: json['status'] as String,
//       disputeCategories: (json['dispute_categories'] as List<dynamic>? ?? [])
//           .map((e) => e as String)
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'status': status,
//         'dispute_categories': disputeCategories,
//       };
// }
//
// class PayPalSellerReceivableBreakdown {
//   final PayPalMoney grossAmount;
//   final PayPalMoney? paypalFee;
//   final PayPalMoney netAmount;
//
//   PayPalSellerReceivableBreakdown({
//     required this.grossAmount,
//     required this.netAmount,
//     this.paypalFee,
//   });
//
//   factory PayPalSellerReceivableBreakdown.fromJson(Map<String, dynamic> json) {
//     return PayPalSellerReceivableBreakdown(
//       grossAmount:
//           PayPalMoney.fromJson(json['gross_amount'] as Map<String, dynamic>),
//       paypalFee: json['paypal_fee'] != null
//           ? PayPalMoney.fromJson(json['paypal_fee'] as Map<String, dynamic>)
//           : null,
//       netAmount:
//           PayPalMoney.fromJson(json['net_amount'] as Map<String, dynamic>),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'gross_amount': grossAmount.toJson(),
//         if (paypalFee != null) 'paypal_fee': paypalFee!.toJson(),
//         'net_amount': netAmount.toJson(),
//       };
// }
//
// /// ---------------- PAYER + NAME + LINKS ----------------
//
// class PayPalPayer {
//   final PayPalName? name;
//   final String? emailAddress;
//   final String? payerId;
//
//   PayPalPayer({
//     this.name,
//     this.emailAddress,
//     this.payerId,
//   });
//
//   factory PayPalPayer.fromJson(Map<String, dynamic> json) {
//     return PayPalPayer(
//       name: json['name'] != null
//           ? PayPalName.fromJson(json['name'] as Map<String, dynamic>)
//           : null,
//       emailAddress: json['email_address'] as String?,
//       payerId: json['payer_id'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (name != null) 'name': name!.toJson(),
//         if (emailAddress != null) 'email_address': emailAddress,
//         if (payerId != null) 'payer_id': payerId,
//       };
// }
//
// class PayPalName {
//   final String? givenName;
//   final String? surname;
//
//   PayPalName({this.givenName, this.surname});
//
//   factory PayPalName.fromJson(Map<String, dynamic> json) {
//     return PayPalName(
//       givenName: json['given_name'] as String?,
//       surname: json['surname'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         if (givenName != null) 'given_name': givenName,
//         if (surname != null) 'surname': surname,
//       };
// }
//
// class PayPalLink {
//   final String href;
//   final String rel;
//   final String method;
//
//   PayPalLink({
//     required this.href,
//     required this.rel,
//     required this.method,
//   });
//
//   factory PayPalLink.fromJson(Map<String, dynamic> json) {
//     return PayPalLink(
//       href: json['href'] as String,
//       rel: json['rel'] as String,
//       method: json['method'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'href': href,
//         'rel': rel,
//         'method': method,
//       };
// }
