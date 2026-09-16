import 'package:equatable/equatable.dart';

/// Domain/presentation-facing error type. Every repository method returns
/// either the requested data or throws one of these via a Result-style
/// pattern implemented per-repository (see RepositoryResult).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Showing cached data if available.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available offline.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Simple Either-like result wrapper so repositories don't need to throw
/// across layer boundaries. `data` is set on success, `failure` on error.
class RepositoryResult<T> {
  final T? data;
  final Failure? failure;
  final bool isFromCache;

  const RepositoryResult.success(this.data, {this.isFromCache = false}) : failure = null;
  const RepositoryResult.error(this.failure) : data = null, isFromCache = false;

  bool get isSuccess => failure == null;
}
