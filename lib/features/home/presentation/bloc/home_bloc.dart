import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../../../../core/usecase/usecase.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeFeedUseCase getHomeFeedUseCase;

  HomeBloc(this.getHomeFeedUseCase) : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<OfferCardSelected>(_onOfferCardSelected);
    on<CategorySelected>(_onCategorySelected);
  }

  Future<void> _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final result = await getHomeFeedUseCase(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (feedData) => emit(HomeLoaded(feedData: feedData)),
    );
  }

  Future<void> _onOfferCardSelected(OfferCardSelected event, Emitter<HomeState> emit) async {
    emit(NavigateToOfferDetail(event.offer));
  }

  Future<void> _onCategorySelected(CategorySelected event, Emitter<HomeState> emit) async {
    emit(NavigateToCategoryOffers(event.categoryName));
  }
}
