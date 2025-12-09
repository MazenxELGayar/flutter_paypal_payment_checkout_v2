part of '../pay_pal_service_v2.dart';

/// PayPal Orders V2 intent: "CAPTURE" or "AUTHORIZE"
enum PayPalOrderIntentV2 {
  capture,
  authorize;

  String get value {
    switch (this) {
      case PayPalOrderIntentV2.capture:
        return "CAPTURE";
      case PayPalOrderIntentV2.authorize:
        return "AUTHORIZE";
    }
  }
}