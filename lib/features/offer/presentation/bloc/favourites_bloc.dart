import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/offer/data/datasource/favourites_remote_datasource.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class FavouritesEvent {
  const FavouritesEvent();
}

final class FavouritesLoadRequested extends FavouritesEvent {
  const FavouritesLoadRequested();
}

final class FavouriteToggled extends FavouritesEvent {
  final String offerId;
  const FavouriteToggled(this.offerId);
}

// ── State ─────────────────────────────────────────────────────────────────────

class FavouritesState {
  final Set<String> favouriteIds;
  final List<OfferEntity> favourites;
  final bool isLoading;
  final String? error;

  const FavouritesState({
    this.favouriteIds = const {},
    this.favourites = const [],
    this.isLoading = false,
    this.error,
  });

  FavouritesState copyWith({
    Set<String>? favouriteIds,
    List<OfferEntity>? favourites,
    bool? isLoading,
    String? error,
  }) {
    return FavouritesState(
      favouriteIds: favouriteIds ?? this.favouriteIds,
      favourites: favourites ?? this.favourites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool isFavourite(String offerId) => favouriteIds.contains(offerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritesState &&
          runtimeType == other.runtimeType &&
          setEquals(favouriteIds, other.favouriteIds) &&
          listEquals(favourites, other.favourites) &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      favouriteIds.hashCode ^
      favourites.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final FavouritesRemoteDataSource _dataSource;

  FavouritesBloc(this._dataSource) : super(const FavouritesState()) {
    on<FavouritesLoadRequested>(_onLoad);
    on<FavouriteToggled>(_onToggle);
  }

  Future<void> _onLoad(
    FavouritesLoadRequested event,
    Emitter<FavouritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final offers = await _dataSource.getFavourites();
      final ids = offers.map((o) => o.id ?? '').where((id) => id.isNotEmpty).toSet();
      emit(state.copyWith(favourites: offers, favouriteIds: ids, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggle(
    FavouriteToggled event,
    Emitter<FavouritesState> emit,
  ) async {
    final wasLiked = state.favouriteIds.contains(event.offerId);
    // Optimistic update
    final optimisticIds = Set<String>.from(state.favouriteIds);
    final optimisticFavourites = List<OfferEntity>.from(state.favourites);
    if (wasLiked) {
      optimisticIds.remove(event.offerId);
      optimisticFavourites.removeWhere((o) => o.id == event.offerId);
    } else {
      optimisticIds.add(event.offerId);
    }
    emit(state.copyWith(favouriteIds: optimisticIds, favourites: optimisticFavourites));

    try {
      final isNowFavourite = await _dataSource.toggleFavourite(event.offerId);
      // Reconcile with server response
      final reconciledIds = Set<String>.from(state.favouriteIds);
      if (isNowFavourite) {
        reconciledIds.add(event.offerId);
      } else {
        reconciledIds.remove(event.offerId);
      }
      emit(state.copyWith(favouriteIds: reconciledIds));
    } catch (_) {
      // Revert optimistic update on error
      emit(state.copyWith(favouriteIds: Set<String>.from(state.favouriteIds)));
    }
  }
}
