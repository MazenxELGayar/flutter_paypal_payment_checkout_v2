import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/functions/paypal_safe_api_call.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_shared_models.dart';

import 'models/paypal_order_request_v1.dart';

/// PayPal Payments API V1 integration layer.
///
/// This library provides a concrete implementation of [PaypalServicesBase]
/// that talks to the legacy **PayPal Payments V1 API**:
/// - `POST /v1/payments/payment`  → create payment
/// - `POST {executeUrl}`          → execute an approved payment

/// Concrete PayPal service for the **Payments API V1**.
///
/// Extends [PaypalServicesBase] and implements:
/// - [createPaypalPayment] to create a V1 payment
/// - [executePayment] to execute a previously approved payment
///
/// This implementation:
/// - Uses the shared [payPalSafeApiCall] wrapper for network safety.
/// - Extracts `approval_url` and `execute` links from the PayPal response.
/// - Validates links and local return/cancel URLs.
/// - Wraps results into [PaypalPaymentModel] and [PayPalSuccessPaymentModel].
class PaypalServicesV1 extends PaypalServicesBase {
  PaypalServicesV1({
    required String? clientId,
    required String? secretKey,
    required bool sandboxMode,
    required PayPalGetAccessToken? getAccessTokenFunction,
    bool overrideInsecureClientCredentials = false,
  }) : super(
          clientId: clientId,
          secretKey: secretKey,
          sandboxMode: sandboxMode,
          getAccessTokenFunction: getAccessTokenFunction,
          overrideInsecureClientCredentials: overrideInsecureClientCredentials,
        );

  /// Creates a PayPal **V1 payment** using:
  /// `POST /v1/payments/payment`
  ///
  /// Steps:
  /// 1. Casts [payPalOrder] to [PayPalOrderRequestV1].
  /// 2. Sends the order JSON to the V1 `/v1/payments/payment` endpoint.
  /// 3. Parses the `links` array to extract:
  ///    - `approval_url` → where the user is redirected.
  ///    - `execute`      → URL used to finalize payment after approval.
  /// 4. Validates:
  ///    - `approval_url` and `execute` exist.
  ///    - Local `returnUrl` and `cancelUrl` are not empty.
  /// 5. Returns:
  ///    - `Right(PaypalPaymentModel)` on success.
  ///    - `Left(PayPalErrorModel)`   on any error.
  @override
  Future<Either<PayPalErrorModel, PaypalPaymentModel>> createPaypalPayment({
    required PayPalOrderRequestBase payPalOrder,
    required String accessToken,
  }) async {
    payPalOrder as PayPalOrderRequestV1;

    final result = await payPalSafeApiCall(
      () => Dio().post(
        '$baseUrl/v1/payments/payment',
        data: jsonEncode(payPalOrder.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      ),
      networkErrorKey: "NETWORK_PAYMENT_FAILED",
      networkErrorMessage: "Network error: Payment Failed.",
      unknownErrorKey: "PAYMENT_UNKNOWN_ERROR",
      unknownErrorMessage: "Unexpected error while creating payment.",
    );

    return result.fold(
      (error) => Left(error),
      (response) {
        final body = response.data;

        if (body["links"] != null && body["links"].length > 0) {
          final List links = body["links"];

          String executeUrl = "";
          String approvalUrl = "";

          // Extract approval_url link
          final approvalItem = links.firstWhere(
            (o) => o["rel"] == "approval_url",
            orElse: () => null,
          );
          if (approvalItem != null) {
            approvalUrl = approvalItem["href"];
          }

          // Extract execute link
          final executeItem = links.firstWhere(
            (o) => o["rel"] == "execute",
            orElse: () => null,
          );
          if (executeItem != null) {
            executeUrl = executeItem["href"];
          }

          /// Check PayPal response links
          if (approvalUrl.isEmpty) {
            return Left(
              PayPalErrorModel(
                error: body,
                message:
                    "Missing approval link: PayPal did not return `approval_url`.",
                key: "MISSING_APPROVAL_URL",
                code: 500,
              ),
            );
          }

          if (executeUrl.isEmpty) {
            return Left(
              PayPalErrorModel(
                error: body,
                message:
                    "Missing execute link: PayPal did not return `execute` URL.",
                key: "MISSING_EXECUTE_URL",
                code: 500,
              ),
            );
          }

          /// Check your local order model (returnUrl & cancelUrl)
          if (payPalOrder.returnUrl.isEmpty) {
            return Left(
              PayPalErrorModel(
                error: body,
                message: "Missing returnUrl in PayPalOrderRequestV1.",
                key: "MISSING_RETURN_URL",
                code: 400,
              ),
            );
          }

          if (payPalOrder.cancelUrl.isEmpty) {
            return Left(
              PayPalErrorModel(
                error: body,
                message: "Missing cancelUrl in PayPalOrderRequestV1.",
                key: "MISSING_CANCEL_URL",
                code: 400,
              ),
            );
          }

          final orderId = body['id'] as String?;

          return Right(
            PaypalPaymentModel(
              approvalUrl: approvalUrl,
              executeUrl: executeUrl,
              returnURL: payPalOrder.returnUrl,
              cancelURL: payPalOrder.cancelUrl,
              message: "Payment created successfully.",
              key: "PAYMENT_CREATE_SUCCESS",
              code: 200,
              accessToken: accessToken,
              status: 'created',
              orderId: orderId,
            ),
          );
        }

        return Left(
          PayPalErrorModel(
            error: body,
            message: "Invalid PayPal response: no links.",
            key: "PAYMENT_NO_LINKS",
            code: 500,
          ),
        );
      },
    );
  }

  /// Executes a previously created PayPal **V1 payment**.
  ///
  /// This should be called after the user approves the payment in the browser,
  /// using the `execute` URL returned from [createPaypalPayment].
  ///
  /// It calls:
  /// ```http
  /// POST {url}
  /// {
  ///   "payer_id": "{payerId}"
  /// }
  /// ```
  ///
  /// Returns:
  /// - `Right(PayPalSuccessPaymentModel)` on success.
  /// - `Left(PayPalErrorModel)` on any failure.
  Future<Either<PayPalErrorModel, PayPalSuccessPaymentModel>> executePayment(
    String url,
    String payerId,
    String accessToken,
  ) async {
    final result = await payPalSafeApiCall(
      () => Dio().post(
        url,
        data: jsonEncode({"payer_id": payerId}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      ),
      networkErrorKey: "NETWORK_PAYMENT_EXECUTE_FAILED",
      networkErrorMessage: "Payment Failed.",
      unknownErrorKey: "PAYMENT_EXECUTE_UNKNOWN_ERROR",
      unknownErrorMessage: "Unexpected error while executing payment.",
    );

    return result.fold(
      (error) => Left(error),
      (response) {
        final body = response.data;

        return Right(
          PayPalSuccessPaymentModel(
            data: body,
            message: "Success",
            key: "PAYMENT_EXECUTE_SUCCESS",
            code: 200,
          ),
        );
      },
    );
  }
}
