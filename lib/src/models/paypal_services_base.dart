import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

abstract class PaypalServicesBase {
  final String? clientId, secretKey;
  final bool sandboxMode;
  final bool overrideInsecureClientCredentials;
  final PayPalGetAccessToken? getAccessTokenFunction;

  const PaypalServicesBase({
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    required this.getAccessTokenFunction,
    this.overrideInsecureClientCredentials = false,
  });

  String get baseUrl => sandboxMode
      ? "https://api-m.sandbox.paypal.com"
      : "https://api-m.paypal.com";

  PayPalErrorModel? validateInlineCredentials() {
    final hasInlineCredentials = (clientId != null && clientId!.isNotEmpty) ||
        (secretKey != null && secretKey!.isNotEmpty);

    if (!sandboxMode &&
        !overrideInsecureClientCredentials &&
        hasInlineCredentials) {
      return PayPalErrorModel(
        error: "INSECURE_CLIENT_CREDENTIALS",
        message:
        "You are passing clientId / secretKey directly into the app while not in sandboxMode.\n\n"
            "This is NOT safe for production: anyone can decompile the app and steal your PayPal keys.\n"
            "Recommended production setup:\n"
            "- Move all PayPal calls (access token, create order/payment, capture) to your backend.\n"
            "- Use the `approvalUrl` callback so the client only receives the checkout URL.",
        key: "INSECURE_CLIENT_CREDENTIALS",
        code: 400,
      );
    }

    return null;
  }

  Future<Either<PayPalErrorModel, PayPalAccessTokenModel>>
  getAccessToken() async {
    try {
      if (getAccessTokenFunction != null) {
        final accessToken = await getAccessTokenFunction!();

        return Right(
          PayPalAccessTokenModel(
            accessToken: accessToken,
            message: "Success",
            key: "ACCESS_TOKEN_SUCCESS",
            code: 200,
          ),
        );
      }

      final authToken = base64.encode(
        utf8.encode("$clientId:$secretKey"),
      );

      final response = await Dio().post(
        '$baseUrl/v1/oauth2/token?grant_type=client_credentials',
        options: Options(
          headers: {
            'Authorization': 'Basic $authToken',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final token = response.data["access_token"];

      return Right(
        PayPalAccessTokenModel(
          accessToken: token,
          message: "Success",
          key: "ACCESS_TOKEN_SUCCESS",
          code: 200,
        ),
      );
    } on DioException catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.response?.data,
          message: "Your PayPal credentials seem incorrect",
          key: "PAYPAL_CREDENTIALS_ERROR",
          code: e.response?.statusCode ?? 400,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Unable to proceed, check your internet connection.",
          key: "ACCESS_TOKEN_NETWORK_ERROR",
          code: 500,
        ),
      );
    }
  }

  Future<Either<PayPalErrorModel, PaypalPaymentModel>> initialize({
    required PayPalGetApprovalUrl? getApprovalUrl,
    required PayPalOrderRequestBase? payPalOrder,
  }) async {
    /// 1) Most secure flow → backend already created the order
    ///   and just gives us an approval URL.
    if (getApprovalUrl != null) {
      final checkoutUrl = await getApprovalUrl();
      return Right(
        checkoutUrl,
      );
    } else {
      /// 2) Less secure flow → client creates the payment.
      final insecureError = validateInlineCredentials();
      if (insecureError != null) {
        return Left(insecureError);
      }

      final tokenResponse = await getAccessToken();
      return await tokenResponse.fold(
            (failure) {
          return Left(failure);
        },
            (accessTokenModel) async {
          if (payPalOrder == null) {
            return Left(
              PayPalErrorModel(
                error: "PayPal order cannot be null.",
                message: "PayPal order cannot be null.",
                key: "NULL_ORDER",
                code: 400,
              ),
            );
          }

          if (payPalOrder.isEmpty) {
            final label = payPalOrder.isV1 ? "Transactions" : "Purchase Units";
            final key = payPalOrder.isV1 ? "EMPTY_TRANSACTIONS" : "EMPTY_PURCHASE_UNITS";

            return Left(
              PayPalErrorModel(
                error: "$label cannot be empty.",
                message: "$label cannot be empty.",
                key: key,
                code: 400,
              ),
            );
          }

          final createPaypalPaymentResponse = await createPaypalPayment(
            payPalOrder: payPalOrder,
            accessToken: accessTokenModel.accessToken,
          );

          return createPaypalPaymentResponse.fold(
                (failure) => Left(failure),
                (paymentModel) => Right(paymentModel),
          );
        },
      );
    }
  }

  Future<Either<PayPalErrorModel, PaypalPaymentModel>> createPaypalPayment({
    required PayPalOrderRequestBase payPalOrder,
    required String accessToken,
  });

}
