import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OfferDetailEvent {
  const OfferDetailEvent();
}

final class ImageChanged extends OfferDetailEvent {
  final int index;
  const ImageChanged(this.index);
}

final class OpenStory extends OfferDetailEvent {
  final String videoUrl;
  const OpenStory(this.videoUrl);
}

final class CloseStory extends OfferDetailEvent {
  const CloseStory();
}

sealed class OfferDetailState {
  const OfferDetailState();
}

final class OfferDetailInitial extends OfferDetailState {
  final int currentImageIndex;
  final bool isStoryActive;
  final String? activeVideoUrl;

  const OfferDetailInitial({
    this.currentImageIndex = 0,
    this.isStoryActive = false,
    this.activeVideoUrl,
  });

  OfferDetailInitial copyWith({
    int? currentImageIndex,
    bool? isStoryActive,
    String? activeVideoUrl,
  }) {
    return OfferDetailInitial(
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      isStoryActive: isStoryActive ?? this.isStoryActive,
      activeVideoUrl: activeVideoUrl ?? this.activeVideoUrl,
    );
  }
}

class OfferDetailBloc extends Bloc<OfferDetailEvent, OfferDetailState> {
  OfferDetailBloc() : super(const OfferDetailInitial()) {
    on<ImageChanged>(_onImageChanged);
    on<OpenStory>(_onOpenStory);
    on<CloseStory>(_onCloseStory);
  }

  void _onImageChanged(ImageChanged event, Emitter<OfferDetailState> emit) {
    if (state is OfferDetailInitial) {
      emit((state as OfferDetailInitial).copyWith(currentImageIndex: event.index));
    }
  }

  void _onOpenStory(OpenStory event, Emitter<OfferDetailState> emit) {
    if (state is OfferDetailInitial) {
      emit((state as OfferDetailInitial).copyWith(isStoryActive: true, activeVideoUrl: event.videoUrl));
    }
  }

  void _onCloseStory(CloseStory event, Emitter<OfferDetailState> emit) {
    if (state is OfferDetailInitial) {
      emit((state as OfferDetailInitial).copyWith(isStoryActive: false, activeVideoUrl: null));
    }
  }
}
