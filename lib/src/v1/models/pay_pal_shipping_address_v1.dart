part of '../paypal_service_v1.dart';

class PayPalShippingAddressV1 {
  final String recipientName;
  final String line1;
  final String? line2;
  final String city;
  final String countryCode;
  final String postalCode;
  final String phone;
  final String state;

  PayPalShippingAddressV1({
    required this.recipientName,
    required this.line1,
    this.line2,
    required this.city,
    required this.countryCode,
    required this.postalCode,
    required this.phone,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "recipient_name": recipientName,
      "line1": line1,
      "city": city,
      "country_code": countryCode,
      "postal_code": postalCode,
      "phone": phone,
      "state": state,
    };

    if (line2 != null) {
      map["line2"] = line2;
    }

    return map;
  }
}
