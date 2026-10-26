import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/feed_item_entity.dart';
import '../repositories/transactions_repository.dart';

class WatchFeedUseCase {
  final TransactionsRepository repository;
  WatchFeedUseCase(this.repository);

  Stream<Either<Failure, List<FeedItemEntity>>> call() =>
      repository.watchFeed();
}

class AddTransactionParams extends Equatable {
  final String walletId;
  final String? categoryId;

  /// Hanya income atau expense.
  final FeedKind kind;
  final double amount;
  final String? note;
  final DateTime? date;

  const AddTransactionParams({
    required this.walletId,
    this.categoryId,
    required this.kind,
    required this.amount,
    this.note,
    this.date,
  });

  @override
  List<Object?> get props => [walletId, categoryId, kind, amount, note, date];
}

class AddTransactionUseCase implements UseCase<void, AddTransactionParams> {
  final TransactionsRepository repository;
  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams p) async {
    if (p.kind == FeedKind.transfer) {
      return const Left(
          ValidationFailure(message: 'Gunakan fitur pindah uang untuk transfer'));
    }
    if (p.walletId.isEmpty) {
      return const Left(ValidationFailure(message: 'Pilih dompet dulu'));
    }
    if (p.amount.isNaN || p.amount.isInfinite || p.amount <= 0) {
      return const Left(
          ValidationFailure(message: 'Nominal harus lebih dari 0'));
    }
    return repository.addTransaction(
      walletId: p.walletId,
      categoryId: p.categoryId,
      kind: p.kind,
      amount: p.amount,
      note: p.note,
      date: p.date,
    );
  }
}

class DeleteFeedItemParams extends Equatable {
  final String id;
  final bool isTransfer;
  const DeleteFeedItemParams(this.id, {required this.isTransfer});

  @override
  List<Object?> get props => [id, isTransfer];
}

class DeleteFeedItemUseCase implements UseCase<void, DeleteFeedItemParams> {
  final TransactionsRepository repository;
  DeleteFeedItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteFeedItemParams p) => p.isTransfer
      ? repository.deleteTransfer(p.id)
      : repository.deleteTransaction(p.id);
}
