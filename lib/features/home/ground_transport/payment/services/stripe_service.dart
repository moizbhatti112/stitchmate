import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stitchmate/core/constants/stripe_keys.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment({
    required int amount,
    required Function onPaymentSuccess,
  }) async {
    try {
      // Ensure minimum amount for PKR (150 PKR ≈ $0.50 USD)
      // This ensures we meet Stripe's minimum charge requirement
      int adjustedAmount = amount;
      if (amount < 150) {
        debugPrint(
          "Warning: Amount $amount PKR is below Stripe minimum. Adjusting to 150 PKR.",
        );
        adjustedAmount = 150;
      }

      String? paymentIntentClientSecret = await _createPaymentIntent(
        adjustedAmount,
        "PKR",
      );

      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Stitchmate",
        ),
      );
      await _processPayment(onPaymentSuccess);
    } catch (e) {
      debugPrint("Payment error: ${e.toString()}");
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> body = {
        "amount": _calculateAmount(amount),
        "currency": currency.toLowerCase(), // Ensure currency is lowercase
      };

      debugPrint("Creating payment intent with: $body");

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );

      debugPrint("Payment intent response: ${response.data}");

      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      // Enhanced error logging
      if (e is DioException) {
        debugPrint("Create payment intent error: ${e.toString()}");
        if (e.response != null) {
          debugPrint("Response data: ${e.response?.data}");
          debugPrint("Response status: ${e.response?.statusCode}");

          // Check for specific Stripe errors
          if (e.response?.data is Map &&
              e.response?.data['error'] != null &&
              e.response?.data['error']['message'] != null) {
            debugPrint(
              "Stripe error message: ${e.response?.data['error']['message']}",
            );
          }
        }
      } else {
        debugPrint("Create payment intent error: ${e.toString()}");
      }
      return null;
    }
  }

  Future<void> _processPayment(Function onPaymentSuccess) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // await Stripe.instance.confirmPaymentSheetPayment();
      // Payment was successful, call the success callback
      onPaymentSuccess();
    } catch (e) {
      debugPrint("Payment processing error: ${e.toString()}");
    }
  }

  String _calculateAmount(int amount) {
    // Stripe requires amount in the smallest currency unit
    // For PKR, this is paisa (1 PKR = 100 paisa)
    final calculatedAmount = amount * 100;
    debugPrint(
      "Calculated amount for Stripe: $calculatedAmount (from $amount PKR)",
    );
    return calculatedAmount.toString();
  }
}
