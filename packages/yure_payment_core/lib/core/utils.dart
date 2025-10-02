// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Utility class to wrap paymentResult data
///
/// Evaluate the paymentResult using a switch statement:
/// ```dart
/// switch (paymentResult) {
///   case Ok(): {
///     print(paymentResult.value);
///   }
///   case Error(): {
///     print(paymentResult.error);
///   }
/// }
/// ```
sealed class PaymentResult<T> {
  const PaymentResult();

  /// Creates a successful [PaymentResult], completed with the specified [value].
  const factory PaymentResult.ok(T value) = Ok._;

  /// Creates an error [PaymentResult], completed with the specified [error].
  const factory PaymentResult.error(Exception error) = Error._;
}

/// Subclass of PaymentResult for values
final class Ok<T> extends PaymentResult<T> {
  const Ok._(this.value);

  /// Returned value in paymentResult
  final T value;

  @override
  String toString() => 'PaymentResult<$T>.ok($value)';
}

/// Subclass of PaymentResult for errors
final class Error<T> extends PaymentResult<T> {
  const Error._(this.error);

  /// Returned error in paymentResult
  final Exception error;

  @override
  String toString() => 'PaymentResult<$T>.error($error)';
}
