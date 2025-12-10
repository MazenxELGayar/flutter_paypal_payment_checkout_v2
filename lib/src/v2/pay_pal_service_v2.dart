library paypal_v2;

import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/functions/safe_api_call.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

import 'models/pay_pal_order_request_v2.dart';

class PaypalServicesV2 extends PaypalServicesBase {
  PaypalServicesV2({
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
    payPalOrder as PayPalOrderRequestV2;

    final result = await safeApiCall(
      () => Dio().post(
        '$baseUrl/v2/checkout/orders',
        data: jsonEncode(payPalOrder.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      ),
      networkErrorKey: "NETWORK_ORDER_CREATE_FAILED",
      networkErrorMessage: "Network error: Failed to create order",
      unknownErrorKey: "ORDER_CREATE_FAILED",
      unknownErrorMessage: "Failed to create order",
    );

    return result.fold(
      (error) => Left(error),
      (response) {
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

        final orderId = body['id'] as String?;
        final status = body['status'] as String?;

        return Right(
          PaypalPaymentModel(
            orderId: orderId,
            approvalUrl: href,
            message: "Order created successfully",
            key: "ORDER_CREATE_SUCCESS",
            accessToken: accessToken,
            code: response.statusCode ?? 200,
            status: status,
            executeUrl: null,
            // adjust depending on your model shape:
            // e.g. paymentSource.paypal.experienceContext.returnUrl
            returnURL: payPalOrder.paymentSource.returnUrl,
            cancelURL: payPalOrder.paymentSource.cancelUrl,
          ),
        );
      },
    );
  }

  Future<Either<PayPalErrorModel, PayPalSuccessPaymentModel>> captureOrder(
    String orderId,
    String accessToken,
  ) async {
    final result = await safeApiCall(
      () => Dio().post(
        '$baseUrl/v2/checkout/orders/$orderId/capture',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      ),
      networkErrorKey: "NETWORK_ORDER_CAPTURE_FAILED",
      networkErrorMessage: "Network error: Failed to capture order",
      unknownErrorKey: "ORDER_CAPTURE_FAILED",
      unknownErrorMessage: "Failed to capture order",
    );

    return result.fold(
      (error) => Left(error),
      (response) {
        return Right(
          PayPalSuccessPaymentModel(
            code: response.statusCode ?? 200,
            key: "ORDER_CAPTURE_SUCCESS",
            message: "Order captured successfully",
            data: response.data,
          ),
        );
      },
    );
  }
}
