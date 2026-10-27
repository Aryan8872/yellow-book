import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/map/presentation/bloc/map_bloc.dart';
import 'package:entertainer/features/map/presentation/bloc/map_event.dart';
import 'package:entertainer/features/map/presentation/bloc/map_state.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/data/model/offer_model.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_usecase.dart';

class _MockGetPaginatedOffersUsecase extends Mock
    implements GetPaginatedOffersUsecase {}

class _FakeGetPaginatedOffersParams extends Fake
    implements GetPaginatedOffersParams {}

class _NoLocationGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GeolocatorPlatform originalLocationPlatform;

  setUpAll(() {
    registerFallbackValue(_FakeGetPaginatedOffersParams());
  });

  setUp(() {
    originalLocationPlatform = GeolocatorPlatform.instance;
    GeolocatorPlatform.instance = _NoLocationGeolocatorPlatform();
  });

  tearDown(() {
    GeolocatorPlatform.instance = originalLocationPlatform;
  });

  group('map offer data', () {
    test('preserves the backend category id when converting the offer model', () {
      final entity = OfferModel(
        title: 'Pizza deal',
        description: 'Pizza',
        terms: 'Terms',
        categoryId: 'category-dining',
        categoryName: 'Dining',
      ).toEntity();

      expect(entity.categoryId, 'category-dining');
    });

    test('maps exact coordinates and preserves offer and category identity', () {
      final offer = _offer(
        id: 'offer-1',
        category: OfferCategory.dining,
        categoryId: 'category-dining',
      );

      final pin = MapBloc.offerToMapPin(offer);

      expect(pin, isNotNull);
      expect(pin!['lat'], 27.72);
      expect(pin['lng'], 85.33);
      expect(pin['categoryId'], 'category-dining');
      expect(pin['categorySlug'], 'DINING');
      expect(pin['offer'], same(offer));
    });

    test('omits offers without usable branch coordinates', () {
      expect(MapBloc.offerToMapPin(_offer(branches: const [])), isNull);
      expect(
        MapBloc.offerToMapPin(
          _offer(branches: [_branch(lat: double.nan)]),
        ),
        isNull,
      );
    });
  });

  group('map viewport offer queries', () {
    late _MockGetPaginatedOffersUsecase usecase;

    setUp(() {
      usecase = _MockGetPaginatedOffersUsecase();
    });

    test('only an explicit filter apply sends a bounded geo query', () async {
      final requests = <GetPaginatedOffersParams>[];
      when(() => usecase.call(any())).thenAnswer((invocation) async {
        requests.add(
          invocation.positionalArguments.single as GetPaginatedOffersParams,
        );
        return Right(
          PaginatedOfferEntity(offers: const [], count: 0, total: 0),
        );
      });
      final bloc = MapBloc(usecase);
      addTearDown(bloc.close);

      await _load(bloc);
      bloc.add(const MapQueryChanged('pizza'));
      bloc.add(const MapCategoryChanged('Dining'));
      await _waitFor(
        bloc,
        (state) =>
            state is MapLoadedState &&
            state.query == 'pizza' &&
            state.activeCategory == 'Dining',
      );

      expect(requests, hasLength(1));
      bloc.add(const MapFiltersApplied(
        lat: 28.2,
        lng: 83.9,
        radiusKm: 20,
        category: 'Dining',
        minimumRating: 4,
      ));
      await _waitFor(
        bloc,
        (state) =>
            state is MapLoadedState &&
            !state.isLoadingOffers &&
            state.browseLocation?.latitude == 28.2,
      );

      expect(requests, hasLength(2));
      final viewportRequest = requests.last;
      expect(viewportRequest.lat, 28.2);
      expect(viewportRequest.lng, 83.9);
      expect(viewportRequest.radiusKm, 20);
      expect(viewportRequest.q, 'pizza');
      expect(viewportRequest.category, 'DINING');
      expect(viewportRequest.limit, lessThanOrEqualTo(100));
      expect(viewportRequest.toQueryParameters(), {
        'page': 1,
        'limit': 100,
        'q': 'pizza',
        'category': 'DINING',
        'lat': 28.2,
        'lng': 83.9,
        'radiusKm': 20,
      });
      expect((bloc.state as MapLoadedState).minimumRating, 4);
    });

    test('does not let an older explicit filter response replace the latest results', () async {
      final olderRequest = Completer<Either<Failure, PaginatedOfferEntity>>();
      final latestRequest = Completer<Either<Failure, PaginatedOfferEntity>>();
      when(() => usecase.call(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single as GetPaginatedOffersParams;
        if (params.lat == 27.7) return olderRequest.future;
        if (params.lat == 28.2) return latestRequest.future;
        return Future.value(
          Right(PaginatedOfferEntity(offers: const [], count: 0, total: 0)),
        );
      });
      final bloc = MapBloc(usecase);
      addTearDown(bloc.close);

      await _load(bloc);
      bloc.add(const MapFiltersApplied(
        lat: 27.7,
        lng: 85.3,
        radiusKm: 12,
        category: 'All',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const MapFiltersApplied(
        lat: 28.2,
        lng: 83.9,
        radiusKm: 20,
        category: 'All',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      olderRequest.complete(
        Right(
          PaginatedOfferEntity(
            offers: [_offer(id: 'stale-offer')],
            count: 1,
            total: 1,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((bloc.state as MapLoadedState).merchants, isEmpty);

      latestRequest.complete(
        Right(
          PaginatedOfferEntity(
            offers: [_offer(id: 'latest-offer')],
            count: 1,
            total: 1,
          ),
        ),
      );
      await _waitFor(
        bloc,
        (state) =>
            state is MapLoadedState &&
            state.merchants.any((merchant) => merchant['id'] == 'latest-offer'),
      );
      expect(
        (bloc.state as MapLoadedState).merchants
            .map((merchant) => merchant['id']),
        ['latest-offer'],
      );
    });

    test('exposes API failures without substituting demo merchants', () async {
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Offer service unavailable')),
      );
      final bloc = MapBloc(usecase);
      addTearDown(bloc.close);

      final state = await _load(bloc);

      expect(state.merchants, isEmpty);
      expect(state.offersError, 'Offer service unavailable');
    });
  });
}

Future<MapLoadedState> _load(MapBloc bloc) async {
  final loaded = _waitFor(bloc, (state) => state is MapLoadedState);
  bloc.add(const MapInitialLoadRequested());
  return loaded;
}

Future<MapLoadedState> _waitFor(
  MapBloc bloc,
  bool Function(MapState state) predicate,
) async {
  final state = await bloc.stream.firstWhere(predicate);
  return state as MapLoadedState;
}

OfferEntity _offer({
  String? id = 'offer-1',
  OfferCategory category = OfferCategory.dining,
  String? categoryId = 'category-1',
  List<MerchantBranchEntity>? branches,
}) {
  return OfferEntity(
    id: id,
    title: 'Pizza deal',
    description: 'Pizza',
    terms: 'Terms',
    category: category,
    categoryId: categoryId,
    merchantName: 'Pizza Place',
    merchant: MerchantDetailEntity(
      id: 'merchant-1',
      name: 'Pizza Place',
      branches: branches ?? [_branch()],
    ),
  );
}

MerchantBranchEntity _branch({double lat = 27.72, double lng = 85.33}) {
  return MerchantBranchEntity(
    id: 'branch-1',
    name: 'Main branch',
    address: 'Thamel',
    city: 'Kathmandu',
    lat: lat,
    lng: lng,
  );
}
