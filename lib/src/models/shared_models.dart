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
  final dynamic error;

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
