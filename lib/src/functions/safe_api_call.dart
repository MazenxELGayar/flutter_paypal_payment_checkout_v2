import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

// 🔹 Shared Dio error wrapper
Future<Either<PayPalErrorModel, Response>> safeApiCall(
  Future<Response> Function() request, {
  required String networkErrorKey,
  required String networkErrorMessage,
  required String unknownErrorKey,
  required String unknownErrorMessage,
}) async {
  try {
    final response = await request();
    return Right(response);
  } on DioException catch (e) {
    return Left(
      PayPalErrorModel(
        error: e.response?.data ?? e.toString(),
        message: networkErrorMessage,
        key: networkErrorKey,
        code: e.response?.statusCode ?? 400,
      ),
    );
  } catch (e) {
    return Left(
      PayPalErrorModel(
        error: e.toString(),
        message: unknownErrorMessage,
        key: unknownErrorKey,
        code: 500,
      ),
    );
  }
}
