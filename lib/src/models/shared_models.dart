import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';

class PayPalBaseModel {
  final String message;
  final String key;
  final int code;

  PayPalBaseModel({
    required this.message,
    required this.key,
    required this.code,
  });
}

class PayPalAccessTokenModel extends PayPalBaseModel {
  final String accessToken;

  PayPalAccessTokenModel({
    required this.accessToken,
    required super.message,
    required super.key,
    required super.code,
  });
}

class PayPalErrorModel extends PayPalBaseModel {
  final String error;

  PayPalErrorModel({
    required this.error,
    required super.message,
    required super.key,
    required super.code,
  });
}

typedef PayPalOnError = dynamic Function(PayPalErrorModel error);

typedef PayPalGetAccessToken = Future<String> Function();

typedef PayPalTransactionsFunction = Map<String, dynamic> Function();

abstract class PayPalOrderRequestBase {
  const PayPalOrderRequestBase();

  /// Must be implemented by V1 and V2
  Map<String, dynamic> toJson();

  bool get isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get isV1;

  bool get isV2;
}

const defaultReturnURL = 'paypal-sdk://success';
const defaultCancelURL = 'paypal-sdk://cancel';

typedef PayPalOnSuccess = dynamic Function(
  PayPalSuccessPaymentModel? response,
  PaypalPaymentModel payment,
);

class PayPalSuccessPaymentModel extends PayPalBaseModel {
  final dynamic data; // PayPal response body

  PayPalSuccessPaymentModel({
    required this.data,
    required super.message,
    required super.key,
    required super.code,
  });
}
