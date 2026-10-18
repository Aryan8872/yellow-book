import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/offer/domain/usecases/redemption_usecase.dart';
import 'redemption_event.dart';
import 'redemption_state.dart';

@Injectable()
class RedemptionBloc extends Bloc<RedemptionEvent, RedemptionState> {
  final InitRedemptionUsecase _initRedemption;
  final GetMyRedemptionsUsecase _getMyRedemptions;

  RedemptionBloc(this._initRedemption, this._getMyRedemptions)
      : super(const RedemptionInitial()) {
    on<InitRedemptionRequested>(_onInitRedemption);
    on<FetchMyRedemptionsRequested>(_onFetchHistory);
    on<RedemptionReset>((_, emit) => emit(const RedemptionInitial()));
  }

  Future<void> _onInitRedemption(
    InitRedemptionRequested event,
    Emitter<RedemptionState> emit,
  ) async {
    emit(const RedemptionLoading());
    final result = await _initRedemption.call(event.offerId);
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
    final result = await _getMyRedemptions.call();
    result.fold(
      (failure) => emit(RedemptionError(failure.message)),
      (list) => emit(RedemptionHistoryLoaded(list)),
    );
  }
}
