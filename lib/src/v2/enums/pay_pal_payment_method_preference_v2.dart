part of '../pay_pal_service_v2.dart';

/// "IMMEDIATE_PAYMENT_REQUIRED" or "UNRESTRICTED"
enum PayPalPaymentMethodPreferenceV2 {
  immediatePaymentRequired,
  unrestricted;

  String get value {
    switch (this) {
      case PayPalPaymentMethodPreferenceV2.immediatePaymentRequired:
        return "IMMEDIATE_PAYMENT_REQUIRED";
      case PayPalPaymentMethodPreferenceV2.unrestricted:
        return "UNRESTRICTED";
    }
  }
}
