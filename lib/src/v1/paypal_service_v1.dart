library paypal_v1;

import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/functions/safe_api_call.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

part 'enums/pay_pal_allowed_payment_method_v1.dart';
part 'enums/pay_pal_order_intent_v1.dart';
part 'models/pay_pal_order_request_v1.dart';
part 'models/pay_pal_shipping_address_v1.dart';
part 'models/paypal_transaction_v1.dart';
part 'models/paypal_transaction_v1_amount.dart';
part 'models/paypal_transaction_v1_item.dart';

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

  @override
  Future<Either<PayPalErrorModel, PaypalPaymentModel>> createPaypalPayment({
    required PayPalOrderRequestBase payPalOrder,
    required String accessToken,
  }) async {
    payPalOrder as PayPalOrderRequestV1;

    final result = await safeApiCall(
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

  Future<Either<PayPalErrorModel, PayPalSuccessPaymentModel>> executePayment(
    String url,
    String payerId,
    String accessToken,
  ) async {
    final result = await safeApiCall(
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
