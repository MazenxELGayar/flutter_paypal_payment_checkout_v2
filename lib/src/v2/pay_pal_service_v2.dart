import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment/src/models/shared_models.dart';
import 'package:flutter_paypal_payment/src/v2/models/pay_pal_capture_order_response_v2.dart';

part 'enums/pay_pal_item_category_v2.dart';
part 'enums/pay_pal_landing_page_v2.dart';
part 'enums/pay_pal_order_intent_v2.dart';
part 'enums/pay_pal_payment_method_preference_v2.dart';
part 'enums/pay_pal_shipping_preference_v2.dart';
part 'enums/pay_pal_user_action_v2.dart';
part 'models/pay_pal_experience_context_v2.dart';
part 'models/pay_pal_order_request_v2.dart';
part 'models/pay_pal_payment_model_v2.dart';
part 'models/pay_pal_purchase_unit_v2.dart';

class PaypalServicesV2 {
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

  String get baseUrl => sandboxMode
      ? "https://api-m.sandbox.paypal.com"
      : "https://api-m.paypal.com";

  PaypalServicesV2({
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    required this.getAccessTokenFunction,
    this.overrideInsecureClientCredentials = false,
  });

  Future<Either<PayPalErrorModel, PaypalPaymentModelV2>> initialize({
    required PayPalGetApprovalUrlV2? getApprovalUrl,
    required PayPalTransactionsFunction? transactionsFunction,
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
          final createPaypalPaymentResponse = await createPaypalPaymentV2(
            request: transactions!,
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

  Future<Either<PayPalErrorModel, PaypalPaymentModelV2>> createPaypalPaymentV2({
    required Map<String, dynamic> request,
    required String accessToken,
  }) async {
    try {
      final response = await Dio().post(
        '$baseUrl/v2/checkout/orders',
        data: jsonEncode(request),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = response.data;

      // Links is a List<dynamic>, each is Map<String, dynamic>
      final List<dynamic> linksRaw = body['links'] ?? [];
      Map<String, dynamic>? approvalLink;

      for (final raw in linksRaw) {
        final link = raw as Map<String, dynamic>;
        final rel = link['rel'] as String?;
        if (rel == 'approve' || rel == 'payer-action') {
          approvalLink = link;
          break;
        }
      }

      final href = approvalLink?['href'] as String?;

      if (href == null || href.isEmpty) {
        return Left(
          PayPalErrorModel(
            error: body,
            message:
                "Missing approval link (no 'approve' or 'payer-action' link found)",
            key: "ORDER_CREATE_NO_APPROVE_LINK",
            code: response.statusCode ?? 500,
          ),
        );
      }

      final orderId = body['id'] as String? ?? '';
      final status = body['status'] as String?;

      return Right(
        PaypalPaymentModelV2(
          orderId: orderId,
          approvalUrl: href,
          message: "Order created successfully",
          key: "ORDER_CREATE_SUCCESS",
          accessToken: accessToken,
          code: response.statusCode ?? 200,
          status: status,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Failed to create order",
          key: "ORDER_CREATE_FAILED",
          code: 500,
        ),
      );
    }
  }

  Future<Either<PayPalErrorModel, PayPalCaptureOrderResponse>> captureOrder(
    String orderId,
    String accessToken,
  ) async {
    try {
      final response = await Dio().post(
        '$baseUrl/v2/checkout/orders/$orderId/capture',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return Right(
        PayPalCaptureOrderResponse.fromJson(
          response.data,
        ),
      );
    } catch (e) {
      return Left(PayPalErrorModel(
        error: e.toString(),
        message: "Failed to capture order",
        key: "ORDER_CAPTURE_FAILED",
        code: 500,
      ));
    }
  }
}
