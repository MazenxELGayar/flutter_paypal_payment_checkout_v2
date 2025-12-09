import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment/src/models/shared_models.dart';

part 'models/pay_pal_execute_payment_model_v1.dart';
part 'models/pay_pal_shipping_address_v1.dart';
part 'models/paypal_payment_model_v1.dart';
part 'models/paypal_transaction_v1.dart';
part 'models/paypal_transaction_v1_amount.dart';
part 'models/paypal_transaction_v1_item.dart';

class PaypalServicesV1 {
  /// SHOULD NEVER BE USED FOR PRODUCTION.
  /// Only for local / sandbox testing when you don't have a backend.
  /// In production, your backend must keep clientId / secretKey secret.
  final String? clientId, secretKey;

  /// When true → calls PayPal sandbox APIs.
  /// When false → calls live / production PayPal APIs.
  final bool sandboxMode;

  /// By default this is false.
  /// If set to true, it will bypass the safety check that prevents
  /// using clientId / secretKey directly in a non-sandbox environment.
  /// Only set this to true if you fully understand the security risk.
  final bool overrideInsecureClientCredentials;

  /// Less secure and generally not recommended for production.
  /// Used when the client requests an access token directly or when the backend
  /// cannot generate the approval URL itself.
  final PayPalGetAccessToken? getAccessTokenFunction;

  // String get baseUrl =>
  //     sandboxMode ? "https://api.sandbox.paypal.com" : "https://api.paypal.com";

  String get baseUrl => sandboxMode
      ? "https://api-m.sandbox.paypal.com"
      : "https://api-m.paypal.com";

  PaypalServicesV1({
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    required this.getAccessTokenFunction,
    this.overrideInsecureClientCredentials = false,
  });

  Future<Either<PayPalErrorModel, PaypalPaymentModelV1>> initialize({
    required PayPalGetApprovalUrlV1? getApprovalUrl,
    required PayPalTransactionsFunction? transactionsFunction,
  }) async {
    /// 1) Most secure flow → backend already created the order
    ///   and just gives us an approval URL.
    if (getApprovalUrl != null) {
      final checkoutUrl = await getApprovalUrl();
      return Right(
        PaypalPaymentModelV1(
          approvalUrl: checkoutUrl,
          executeUrl: null,
          message: "Payment created successfully.",
          key: "PAYMENT_CREATE_SUCCESS",
          accessToken: null,
          code: 200,
        ),
      );
    } else {
      /// 2) Less secure flow → client creates the payment.
      ///    Enforce: clientId / secretKey must NOT be used in live mode
      ///    unless the developer explicitly overrides the safety check.
      final hasInlineCredentials = (clientId != null && clientId!.isNotEmpty) ||
          (secretKey != null && secretKey!.isNotEmpty);

      if (!sandboxMode &&
          !overrideInsecureClientCredentials &&
          hasInlineCredentials) {
        return Left(
          PayPalErrorModel(
            error: "INSECURE_CLIENT_CREDENTIALS",
            message:
                "You are passing clientId / secretKey directly into the app while not in sandboxMode.\n\n"
                "This is NOT safe for production: anyone can decompile the app and steal your PayPal keys.\n"
                "Recommended production setup:\n"
                "- Move all PayPal calls (access token, create order/payment, capture) to your backend.\n"
                "- Use the `approvalUrl` callback so the client only receives the checkout URL.",
            key: "INSECURE_CLIENT_CREDENTIALS",
            code: 400,
          ),
        );
      }

      final tokenResponse = await getAccessToken();
      return await tokenResponse.fold(
        (failure) {
          return Left(
            failure,
          );
        },
        (accessTokenModel) async {
          final transactions = transactionsFunction?.call();
          if (transactions?.isEmpty ?? true) {
            return Left(
              PayPalErrorModel(
                error: null,
                message: "Transactions cannot be empty",
                key: "EMPTY_TRANSACTIONS",
                code: 400,
              ),
            );
          }
          final createPaypalPaymentResponse = await createPaypalPayment(
            transactions: transactions!,
            accessToken: accessTokenModel.accessToken,
          );
          return createPaypalPaymentResponse.fold(
            (failure) {
              return Left(
                failure,
              );
            },
            (paymentModel) {
              return Right(
                paymentModel,
              );
            },
          );
        },
      );
    }
  }

  Future<Either<PayPalErrorModel, PayPalAccessTokenModel>>
      getAccessToken() async {
    try {
      // If using backend-provided token
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

      // Fallback: Local token generation (not recommended)
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

  Future<Either<PayPalErrorModel, PaypalPaymentModelV1>> createPaypalPayment({
    required Map<String, dynamic> transactions,
    required String accessToken,
  }) async {
    try {
      final response = await Dio().post(
        '$baseUrl/v1/payments/payment',
        data: jsonEncode(transactions),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = response.data;

      if (body["links"] != null && body["links"].length > 0) {
        final List links = body["links"];

        String executeUrl = "";
        String approvalUrl = "";

        final approvalItem = links.firstWhere(
          (o) => o["rel"] == "approval_url",
          orElse: () => null,
        );
        if (approvalItem != null) {
          approvalUrl = approvalItem["href"];
        }

        final executeItem = links.firstWhere(
          (o) => o["rel"] == "execute",
          orElse: () => null,
        );
        if (executeItem != null) {
          executeUrl = executeItem["href"];
        }

        if (approvalUrl.isEmpty || executeUrl.isEmpty) {
          // Missing expected links → treat as error
          return Left(
            PayPalErrorModel(
              error: body,
              message: "Invalid PayPal response: missing links.",
              key: "PAYMENT_MISSING_LINKS",
              code: 500,
            ),
          );
        }

        return Right(
          PaypalPaymentModelV1(
            approvalUrl: approvalUrl,
            executeUrl: executeUrl,
            message: "Payment created successfully.",
            key: "PAYMENT_CREATE_SUCCESS",
            code: 200,
            accessToken: accessToken,
          ),
        );
      }

      // No links at all
      return Left(
        PayPalErrorModel(
          error: body,
          message: "Invalid PayPal response: no links.",
          key: "PAYMENT_NO_LINKS",
          code: 500,
        ),
      );
    } on DioException catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.response?.data,
          message: "Payment Failed.",
          key: "PAYMENT_FAILED",
          code: e.response?.statusCode ?? 400,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Unexpected error while creating payment.",
          key: "PAYMENT_UNKNOWN_ERROR",
          code: 500,
        ),
      );
    }
  }

  Future<Either<PayPalErrorModel, PayPalExecutePaymentModelV1>> executePayment(
    String url,
    String payerId,
    String accessToken,
  ) async {
    try {
      final response = await Dio().post(
        url,
        data: convert.jsonEncode({"payer_id": payerId}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = response.data;

      return Right(
        PayPalExecutePaymentModelV1(
          data: body,
          message: "Success",
          key: "PAYMENT_EXECUTE_SUCCESS",
          code: 200,
        ),
      );
    } on DioException catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.response?.data,
          message: "Payment Failed.",
          key: "PAYMENT_EXECUTE_FAILED",
          code: e.response?.statusCode ?? 400,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Unexpected error while executing payment.",
          key: "PAYMENT_EXECUTE_UNKNOWN_ERROR",
          code: 500,
        ),
      );
    }
  }
}
