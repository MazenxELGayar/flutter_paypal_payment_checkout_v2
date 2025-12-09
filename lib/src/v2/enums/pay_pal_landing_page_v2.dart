part of '../pay_pal_service_v2.dart';

/// "LOGIN" or "NO_PREFERENCE"
enum PayPalLandingPageV2 {
  login,
  noPreference;

  String get value {
    switch (this) {
      case PayPalLandingPageV2.login:
        return "LOGIN";
      case PayPalLandingPageV2.noPreference:
        return "NO_PREFERENCE";
    }
  }
}
