import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<TrendingOfferSelected>(_onTrendingOfferSelected);
    on<CategorySelected>(_onCategorySelected);
  }

  Future<void> _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const HomeLoaded());
  }

  Future<void> _onTrendingOfferSelected(TrendingOfferSelected event, Emitter<HomeState> emit) async {
    emit(NavigateToOfferDetail(event.offer));
  }

  Future<void> _onCategorySelected(CategorySelected event, Emitter<HomeState> emit) async {
    emit(NavigateToCategoryOffers(event.categoryName));
  }
}
