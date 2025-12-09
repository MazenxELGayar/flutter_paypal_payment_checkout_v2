part of '../pay_pal_service_v2.dart';

/// "PAY_NOW" or "CONTINUE"
enum PayPalUserActionV2 {
  payNow,
  continueAction;

  String get value {
    switch (this) {
      case PayPalUserActionV2.payNow:
        return "PAY_NOW";
      case PayPalUserActionV2.continueAction:
        return "CONTINUE";
    }
  }
}
