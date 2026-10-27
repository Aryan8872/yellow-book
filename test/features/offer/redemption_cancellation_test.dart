import 'package:dartz/dartz.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/domain/usecases/redemption_usecase.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/pages/redemption_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockInitRedemptionUsecase extends Mock
    implements InitRedemptionUsecase {}

class _MockGetMyRedemptionsUsecase extends Mock
    implements GetMyRedemptionsUsecase {}

class _MockCancelRedemptionUsecase extends Mock
    implements CancelRedemptionUsecase {}

void main() {
  late _MockInitRedemptionUsecase initUsecase;
  late _MockGetMyRedemptionsUsecase historyUsecase;
  late _MockCancelRedemptionUsecase cancelUsecase;

  setUp(() async {
    await getIt.reset();
    initUsecase = _MockInitRedemptionUsecase();
    historyUsecase = _MockGetMyRedemptionsUsecase();
    cancelUsecase = _MockCancelRedemptionUsecase();
  });

  tearDown(() async {
    await getIt.reset();
  });

  RedemptionBloc registerPageBloc() {
    final bloc = RedemptionBloc(initUsecase, historyUsecase, cancelUsecase);
    getIt.registerFactory<RedemptionBloc>(() => bloc);
    return bloc;
  }

  Future<void> pumpDetailPage(
    WidgetTester tester, {
    String status = 'INIT',
  }) async {
    registerPageBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: RedemptionDetailPage(
          redemption: RedemptionEntity(
            id: 'session-1',
            offerId: 'offer-1',
            offerTitle: 'Lunch special',
            status: status,
            redemptionCode: 'NF-ABCD12',
            redeemedAt: DateTime.utc(2026, 1, 1),
            expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('requires confirmation and dispatches the redemption id', (
    tester,
  ) async {
    when(() => cancelUsecase.call('session-1'))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    when(
      () => historyUsecase.call(),
    ).thenAnswer((_) async => const Right<Failure, List<RedemptionEntity>>([]));
    await pumpDetailPage(tester);

    await tester.tap(find.text('Cancel Redemption'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this redemption?'), findsOneWidget);
    verifyNever(() => cancelUsecase.call(any()));

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    verifyNever(() => cancelUsecase.call(any()));

    await tester.tap(find.text('Cancel Redemption'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, cancel it'));
    await tester.pumpAndSettle();

    verify(() => cancelUsecase.call('session-1')).called(1);
  });

  testWidgets('shows failure and keeps cancellation available for retry', (
    tester,
  ) async {
    var attempts = 0;
    when(() => cancelUsecase.call('session-1')).thenAnswer((_) async {
      attempts += 1;
      if (attempts == 1) {
        return const Left<Failure, void>(
          ServerFailure.withDetails('Network unavailable'),
        );
      }
      return const Right<Failure, void>(null);
    });
    when(
      () => historyUsecase.call(),
    ).thenAnswer((_) async => const Right<Failure, List<RedemptionEntity>>([]));
    await pumpDetailPage(tester);

    await tester.tap(find.text('Cancel Redemption'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, cancel it'));
    await tester.pumpAndSettle();

    expect(find.text('Network unavailable'), findsOneWidget);
    expect(find.text('Cancel Redemption'), findsOneWidget);

    await tester.tap(find.text('Cancel Redemption'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, cancel it'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsOneWidget);
    verify(() => cancelUsecase.call('session-1')).called(2);
  });

  testWidgets('keeps the detail open and displays Cancelled after success', (
    tester,
  ) async {
    when(() => cancelUsecase.call('session-1'))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    when(
      () => historyUsecase.call(),
    ).thenAnswer((_) async => const Right<Failure, List<RedemptionEntity>>([]));
    await pumpDetailPage(tester);

    await tester.tap(find.text('Cancel Redemption'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, cancel it'));
    await tester.pumpAndSettle();

    expect(find.byType(RedemptionDetailPage), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Redemption cancelled successfully'), findsOneWidget);
    verify(() => historyUsecase.call()).called(1);
  });

  testWidgets('hides cancellation for terminal redemptions', (tester) async {
    await pumpDetailPage(tester, status: 'REDEEMED');

    expect(find.text('Cancel Redemption'), findsNothing);
  });

  testWidgets('allows cancellation for PENDING_SYNC redemptions', (
    tester,
  ) async {
    await pumpDetailPage(tester, status: 'PENDING_SYNC');

    expect(find.text('Cancel Redemption'), findsOneWidget);
  });
}
