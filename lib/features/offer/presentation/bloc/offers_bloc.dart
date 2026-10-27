import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_usecase.dart';

import 'offers_event.dart';
import 'offers_state.dart';

@Injectable()
class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final GetPaginatedOffersUsecase _getPaginatedOffersUsecase;
  final GetOfferByIdUsecase _getOfferByIdUsecase;

  String? _currentQuery;
  String? _currentCategory;
  String? _currentLocation;
  String? _currentSortBy;
  double? _currentLat;
  double? _currentLng;
  double? _currentRadiusKm;
  int _currentPage = 1;
  final int _limit = 20;

  OffersBloc(this._getPaginatedOffersUsecase, this._getOfferByIdUsecase)
    : super(const OffersInitial()) {
    on<FetchOffersRequested>(_onFetchOffersRequested);
    on<LoadMoreOffersRequested>(_onLoadMoreOffersRequested);
    on<OfferSearchQueryChanged>(_onOfferSearchQueryChanged);
    on<OfferCategoryFilterChanged>(_onOfferCategoryFilterChanged);
    on<FetchOfferDetailRequested>(_onFetchOfferDetailRequested);
  }

  Future<void> _onFetchOffersRequested(
    FetchOffersRequested event,
    Emitter<OffersState> emit,
  ) async {
    _currentQuery = event.q ?? _currentQuery;
    _currentCategory = event.category ?? _currentCategory;
    _currentLocation = event.location ?? _currentLocation;
    _currentSortBy = event.sortBy ?? _currentSortBy;
    _currentLat = event.lat;
    _currentLng = event.lng;
    _currentRadiusKm = event.radiusKm ?? (event.lat != null ? 50.0 : null);
    _currentPage = event.page;

    if (event.refresh || state is! OffersLoaded) {
      emit(const OffersLoading());
    }

    final result = await _getPaginatedOffersUsecase.call(
      GetPaginatedOffersParams(
        page: _currentPage,
        limit: event.limit,
        q: _currentQuery,
        category: _currentCategory,
        lat: _currentLat,
        lng: _currentLng,
        radiusKm: _currentRadiusKm,
        location: _currentLocation,
        sortBy: _currentSortBy,
        merchantId: event.merchantId,
      ),
    );

    result.fold((failure) => emit(OffersError(failure.message)), (
      paginatedEntity,
    ) {
      final hasMore =
          paginatedEntity.offers.length >= event.limit &&
          paginatedEntity.offers.length < paginatedEntity.total;
      emit(
        OffersLoaded(
          offers: paginatedEntity.offers,
          page: _currentPage,
          total: paginatedEntity.total,
          count: paginatedEntity.count,
          hasMore: hasMore,
          searchQuery: _currentQuery,
          selectedCategory: _currentCategory,
          selectedLocation: _currentLocation,
        ),
      );
    });
  }

  Future<void> _onLoadMoreOffersRequested(
    LoadMoreOffersRequested event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    if (currentState is OffersLoaded &&
        currentState.hasMore &&
        !currentState.isLoadingMore) {
      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++;
      final result = await _getPaginatedOffersUsecase.call(
        GetPaginatedOffersParams(
          page: _currentPage,
          limit: _limit,
          q: _currentQuery,
          category: _currentCategory,
          lat: _currentLat,
          lng: _currentLng,
          radiusKm: _currentRadiusKm,
          location: _currentLocation,
          sortBy: _currentSortBy,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (paginatedEntity) {
          final updatedOffers = List.of(currentState.offers)
            ..addAll(paginatedEntity.offers);
          final hasMore = updatedOffers.length < paginatedEntity.total;
          emit(
            OffersLoaded(
              offers: updatedOffers,
              page: _currentPage,
              total: paginatedEntity.total,
              count: paginatedEntity.count,
              hasMore: hasMore,
              isLoadingMore: false,
              searchQuery: _currentQuery,
              selectedCategory: _currentCategory,
              selectedLocation: _currentLocation,
            ),
          );
        },
      );
    }
  }

  Future<void> _onOfferSearchQueryChanged(
    OfferSearchQueryChanged event,
    Emitter<OffersState> emit,
  ) async {
    add(
      FetchOffersRequested(
        q: event.query.isEmpty ? null : event.query,
        category: _currentCategory,
        lat: _currentLat,
        lng: _currentLng,
        radiusKm: _currentRadiusKm,
        location: _currentLocation,
        page: 1,
        refresh: true,
      ),
    );
  }

  Future<void> _onOfferCategoryFilterChanged(
    OfferCategoryFilterChanged event,
    Emitter<OffersState> emit,
  ) async {
    add(
      FetchOffersRequested(
        q: _currentQuery,
        category: event.category,
        lat: _currentLat,
        lng: _currentLng,
        radiusKm: _currentRadiusKm,
        location: _currentLocation,
        page: 1,
        refresh: true,
      ),
    );
  }

  Future<void> _onFetchOfferDetailRequested(
    FetchOfferDetailRequested event,
    Emitter<OffersState> emit,
  ) async {
    emit(const OfferDetailLoading());
    final result = await _getOfferByIdUsecase.call(
      GetOfferByIdParams(id: event.id),
    );
    result.fold(
      (failure) => emit(OfferDetailError(failure.message)),
      (offer) => emit(OfferDetailLoaded(offer)),
    );
  }
}
