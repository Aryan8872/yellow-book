// Phase 30 plan 30-03 — envelope unwrap regression suite (RED first).
//
// Guards the P6 unwrap idiom for the favourites + category datasources:
// the NestJS TransformResponseInterceptor wraps every controller return in
// { success, data: ... }, so datasources MUST read inside `data` (or fall back
// to the whole raw map when no `data` key exists), never cast the envelope.
import 'package:dio/dio.dart';
import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';
import 'package:entertainer/features/offer/data/datasource/favourites_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('FavouritesRemoteDataSource envelope parsing', () {
    late _MockDio dio;
    late FavouritesRemoteDataSource dataSource;

    setUp(() {
      dio = _MockDio();
      dataSource = FavouritesRemoteDataSource(dio);
    });

    Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
        Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/x'),
          data: data,
        );

    test('toggleFavourite parses isFavourite from inside the envelope payload',
        () async {
      when(() => dio.post(any())).thenAnswer(
        (_) async => resp(
          {'success': true, 'data': {'isFavourite': true}},
        ),
      );

      final result = await dataSource.toggleFavourite('offer-1');

      expect(result, isTrue);
    });

    test('getFavourites parses the offers list from inside the envelope payload',
        () async {
      when(() => dio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => resp(
          {
            'success': true,
            'data': {
              'offers': [
                {'id': 'offer-1', 'title': 'Half off breakfast'},
                {'id': 'offer-2', 'title': 'Two for one lattes'},
              ],
              'count': 2,
              'total': 2,
            },
          },
        ),
      );

      final result = await dataSource.getFavourites();

      expect(result, hasLength(2));
      expect(result.first.id, 'offer-1');
      expect(result[1].title, 'Two for one lattes');
    });

    test('toggleFavourite falls back to the whole raw map when no data key',
        () async {
      when(() => dio.post(any())).thenAnswer(
        (_) async => resp({'isFavourite': true}),
      );

      final result = await dataSource.toggleFavourite('offer-1');

      expect(result, isTrue);
    });
  });

  group('CategoryRemoteDataSource envelope parsing', () {
    late _MockDio dio;
    late CategoryRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = _MockDio();
      dataSource = CategoryRemoteDataSourceImpl(dio);
    });

    Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
        Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/x'),
          data: data,
        );

    test('getCategories unwraps the data list from the envelope', () async {
      when(() => dio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => resp(
          {
            'success': true,
            'data': [
              {'id': 'c1', 'name': 'Dining', 'slug': 'dining'},
              {'id': 'c2', 'name': 'Wellness', 'slug': 'wellness'},
            ],
          },
        ),
      );

      final result = await dataSource.getCategories();

      expect(result, hasLength(2));
      expect(result.first.id, 'c1');
      expect(result[1].slug, 'wellness');
    });

    test('getCategories degrades to [] on a malformed envelope (no TypeError)',
        () async {
      when(() => dio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => resp(
          {'success': true, 'data': {'unexpected': 'object'}},
        ),
      );

      final result = await dataSource.getCategories();

      expect(result, isEmpty);
    });
  });
}
