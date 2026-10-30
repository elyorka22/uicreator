class AppFailure implements Exception {
  AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class ValidationFailure extends AppFailure {
  ValidationFailure(super.message, {super.cause});
}

class NetworkFailure extends AppFailure {
  NetworkFailure(super.message, {super.cause});
}

class ProviderFailure extends AppFailure {
  ProviderFailure(super.message, {super.cause});
}

class StorageFailure extends AppFailure {
  StorageFailure(super.message, {super.cause});
}
