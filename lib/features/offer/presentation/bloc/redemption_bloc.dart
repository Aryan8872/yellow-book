import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/offer/domain/usecases/redemption_usecase.dart';

import 'redemption_event.dart';
import 'redemption_state.dart';

@Injectable()
class RedemptionBloc extends Bloc<RedemptionEvent, RedemptionState> {
  final InitRedemptionUsecase _initRedemption;
  final GetMyRedemptionsUsecase _getMyRedemptions;
  final CancelRedemptionUsecase _cancelRedemption;

  RedemptionBloc(
    this._initRedemption,
    this._getMyRedemptions,
    this._cancelRedemption,
  ) : super(const RedemptionInitial()) {
    on<InitRedemptionRequested>(_onInitRedemption);
    on<FetchMyRedemptionsRequested>(_onFetchHistory);
    on<CancelRedemptionRequested>(_onCancelRedemption);
    on<RedemptionReset>((_, emit) => emit(const RedemptionInitial()));
  }

  Future<void> _onInitRedemption(
    InitRedemptionRequested event,
    Emitter<RedemptionState> emit,
  ) async {
    emit(const RedemptionLoading());
    final result = await _initRedemption.call(
      event.offerId,
      branchId: event.branchId,
    );
    result.fold(
      (failure) => emit(RedemptionError(failure.message)),
      (redemption) => emit(RedemptionSuccess(redemption)),
    );
  }

  Future<void> _onFetchHistory(
    FetchMyRedemptionsRequested event,
    Emitter<RedemptionState> emit,
  ) async {
    emit(const RedemptionLoading());
    final result = await _getMyRedemptions.call(offerId: event.offerId);
    result.fold(
      (failure) => emit(RedemptionError(failure.message)),
      (list) => emit(RedemptionHistoryLoaded(list)),
    );
  }

  Future<void> _onCancelRedemption(
    CancelRedemptionRequested event,
    Emitter<RedemptionState> emit,
  ) async {
    emit(const RedemptionLoading());
    final result = await _cancelRedemption.call(event.sessionId);
    final cancelled = result.fold(
      (failure) {
        emit(RedemptionError(failure.message));
        return false;
      },
      (_) {
        emit(
          RedemptionCancelSuccess(
            sessionId: event.sessionId,
            status: 'REJECTED',
          ),
        );
        return true;
      },
    );
    if (!cancelled) return;

    final historyResult = await _getMyRedemptions.call();
    historyResult.fold(
      (failure) => emit(
        RedemptionError(
          'Cancellation succeeded, but redemption history could not be refreshed: ${failure.message}',
        ),
      ),
      (redemptions) => emit(RedemptionHistoryLoaded(redemptions)),
    );
  }
}
