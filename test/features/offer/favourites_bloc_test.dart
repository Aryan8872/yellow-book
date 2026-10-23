// Phase 30 plan 30-03 Task 2 — FavouritesBloc rollback (D3) RED tests.
//
// The catch branch must restore the EXACT pre-toggle favourites snapshot (ids
// and list) captured BEFORE the optimistic emit — never read the live
// post-optimistic state (the current no-op revert bug).
import 'package:entertainer/features/offer/data/datasource/favourites_remote_datasource.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/favourites_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFavouritesDataSource extends Mock implements FavouritesRemoteDataSource {}

OfferEntity _offer(String id) => OfferEntity(
      id: id,
      title: 'Offer $id',
      description: '',
      terms: '',
      category: OfferCategory.dining,
    );

void main() {
  group('FavouritesBloc', () {
    late _MockFavouritesDataSource dataSource;

    // Shared single instances — OfferEntity has no == override, so seed and
    // expect must reference the SAME objects for listEquals to pass.
    final offerA = _offer('a');
    final offerB = _offer('b');
    final offerC = _offer('c');

    setUp(() {
      dataSource = _MockFavouritesDataSource();
    });

    blocTest<FavouritesBloc, FavouritesState>(
      'toggle success applies optimistic ids then reconciles with server truth',
      build: () => FavouritesBloc(dataSource),
      seed: () => FavouritesState(
        favouriteIds: {'a', 'b'},
        favourites: [offerA, offerB],
      ),
      act: (bloc) {
        when(() => dataSource.toggleFavourite(any())).thenAnswer((_) async => true);
        bloc.add(const FavouriteToggled('c'));
      },
      expect: () => [
        // bloc 8 dedupes ==-equal consecutive emissions: the reconcile of
        // {a,b,c} with server truth "true" is ==-equal to the optimistic
        // state, so exactly ONE visible emission carries both steps.
        FavouritesState(
          favouriteIds: {'a', 'b', 'c'},
          favourites: [offerA, offerB],
        ),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'toggle failure restores the EXACT pre-toggle favourite set (no shared mutable reference)',
      build: () => FavouritesBloc(dataSource),
      seed: () => FavouritesState(
        favouriteIds: {'a', 'b'},
        favourites: [offerA, offerB],
      ),
      act: (bloc) {
        when(() => dataSource.toggleFavourite(any()))
            .thenThrow(Exception('network down'));
        bloc.add(const FavouriteToggled('c'));
      },
      expect: () => [
        FavouritesState(
          favouriteIds: {'a', 'b', 'c'},
          favourites: [offerA, offerB],
        ),
        FavouritesState(
          favouriteIds: {'a', 'b'},
          favourites: [offerA, offerB],
        ),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'un-toggle failure returns the previously-liked offer to liked',
      build: () => FavouritesBloc(dataSource),
      seed: () => FavouritesState(
        favouriteIds: {'a', 'b', 'c'},
        favourites: [offerA, offerB, offerC],
      ),
      act: (bloc) {
        when(() => dataSource.toggleFavourite(any()))
            .thenThrow(Exception('network down'));
        bloc.add(const FavouriteToggled('a'));
      },
      expect: () => [
        FavouritesState(
          favouriteIds: {'b', 'c'},
          favourites: [offerB, offerC],
        ),
        FavouritesState(
          favouriteIds: {'a', 'b', 'c'},
          favourites: [offerA, offerB, offerC],
        ),
      ],
    );
  });
}
