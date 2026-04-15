import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/internship_models.dart';
import '../data/repositories/internship_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class InternshipEvent extends Equatable {
  const InternshipEvent();
  @override
  List<Object?> get props => [];
}

class InternshipDetailRequested extends InternshipEvent {
  final String id;
  const InternshipDetailRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

class InternshipAddToCart extends InternshipEvent {
  final String id;
  final String priceOptionId;
  const InternshipAddToCart({required this.id, required this.priceOptionId});
  @override
  List<Object?> get props => [id, priceOptionId];
}

class InternshipAddToWishlist extends InternshipEvent {
  final String id;
  const InternshipAddToWishlist({required this.id});
  @override
  List<Object?> get props => [id];
}

class InternshipEnroll extends InternshipEvent {
  final String id;
  final String priceOptionId;
  final String paymentMethod;
  final String transactionId;
  const InternshipEnroll({
    required this.id,
    required this.priceOptionId,
    required this.paymentMethod,
    required this.transactionId,
  });
  @override
  List<Object?> get props => [id, priceOptionId, paymentMethod, transactionId];
}

abstract class InternshipState extends Equatable {
  const InternshipState();
  @override
  List<Object?> get props => [];
}

class InternshipInitial extends InternshipState {}
class InternshipLoading extends InternshipState {}

class InternshipDetailLoaded extends InternshipState {
  final InternshipDetailModel internship;
  const InternshipDetailLoaded({required this.internship});
  @override
  List<Object?> get props => [internship];
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  const InternshipActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class InternshipError extends InternshipState {
  final String message;
  const InternshipError({required this.message});
  @override
  List<Object?> get props => [message];
}

class InternshipBloc extends Bloc<InternshipEvent, InternshipState> {
  final InternshipRepository _repository;

  InternshipBloc({required InternshipRepository repository})
      : _repository = repository,
        super(InternshipInitial()) {
    on<InternshipDetailRequested>(_onDetailLoaded);
    on<InternshipAddToCart>(_onAddToCart);
    on<InternshipAddToWishlist>(_onAddToWishlist);
    on<InternshipEnroll>(_onEnroll);
  }

  Future<void> _onDetailLoaded(
      InternshipDetailRequested event, Emitter<InternshipState> emit) async {
    emit(InternshipLoading());
    try {
      final internship = await _repository.getDetail(event.id);
      emit(InternshipDetailLoaded(internship: internship));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onAddToCart(
      InternshipAddToCart event, Emitter<InternshipState> emit) async {
    try {
      await _repository.addToCart(event.id, event.priceOptionId);
      emit(const InternshipActionSuccess(message: 'Added to cart'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onAddToWishlist(
      InternshipAddToWishlist event, Emitter<InternshipState> emit) async {
    try {
      await _repository.addToWishlist(event.id);
      emit(const InternshipActionSuccess(message: 'Added to wishlist'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onEnroll(
      InternshipEnroll event, Emitter<InternshipState> emit) async {
    try {
      await _repository.enroll(
        event.id,
        event.priceOptionId,
        event.paymentMethod,
        event.transactionId,
      );
      emit(const InternshipActionSuccess(message: 'Enrolled successfully'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }
}
