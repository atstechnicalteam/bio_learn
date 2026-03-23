import 'package:bio_xplora_portal/features/home/data/models/home_models.dart';
import 'package:bio_xplora_portal/features/home/data/repositories/home_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/user_session_store.dart';


// ─── Events ───────────────────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeDataLoaded extends HomeEvent {
  final String tab; // 'internships' or 'courses'
  const HomeDataLoaded({this.tab = 'internships'});
  @override
  List<Object?> get props => [tab];
}

class HomeTabChanged extends HomeEvent {
  final String tab;
  const HomeTabChanged({required this.tab});
  @override
  List<Object?> get props => [tab];
}

class HomeSearchChanged extends HomeEvent {
  final String query;
  final String type;
  const HomeSearchChanged({required this.query, required this.type});
  @override
  List<Object?> get props => [query, type];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<InternshipModel> items;
  final List<CareerPathModel> careerPaths;
  final ContinueLearningModel? continueLearning;
  final String activeTab;
  final String userName;

  const HomeLoaded({
    required this.items,
    required this.careerPaths,
    this.continueLearning,
    required this.activeTab,
    required this.userName,
  });

  @override
  List<Object?> get props =>
      [items, careerPaths, continueLearning, activeTab, userName];

  HomeLoaded copyWith({
    List<InternshipModel>? items,
    List<CareerPathModel>? careerPaths,
    ContinueLearningModel? continueLearning,
    String? activeTab,
    String? userName,
  }) {
    return HomeLoaded(
      items: items ?? this.items,
      careerPaths: careerPaths ?? this.careerPaths,
      continueLearning: continueLearning ?? this.continueLearning,
      activeTab: activeTab ?? this.activeTab,
      userName: userName ?? this.userName,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeInitial()) {
    on<HomeDataLoaded>(_onHomeDataLoaded);
    on<HomeTabChanged>(_onHomeTabChanged);
    on<HomeSearchChanged>(_onHomeSearchChanged);
  }

  Future<void> _onHomeDataLoaded(
      HomeDataLoaded event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      await UserSessionStore.instance.ensureInitialized();
      final results = await Future.wait([
        event.tab == 'internships'
            ? _homeRepository.getInternships()
            : _homeRepository.getCourses(),
        _homeRepository.getCareerPaths(),
        _homeRepository.getContinueLearning(),
      ]);

      emit(HomeLoaded(
        items: results[0] as List<InternshipModel>,
        careerPaths: results[1] as List<CareerPathModel>,
        continueLearning: results[2] as ContinueLearningModel?,
        activeTab: event.tab,
        userName: UserSessionStore.instance.state.value.displayName,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onHomeTabChanged(
      HomeTabChanged event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      try {
        final items = event.tab == 'internships'
            ? await _homeRepository.getInternships()
            : await _homeRepository.getCourses();
        emit(current.copyWith(items: items, activeTab: event.tab));
      } catch (e) {
        emit(HomeError(message: e.toString().replaceAll('ApiException: ', '')));
      }
    }
  }

  Future<void> _onHomeSearchChanged(
      HomeSearchChanged event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      if (state is HomeLoaded) {
        try {
          final items = event.type == 'courses'
              ? await _homeRepository.getCourses()
              : await _homeRepository.getInternships();
          emit((state as HomeLoaded).copyWith(items: items, activeTab: event.type));
        } catch (_) {}
      }
      return;
    }
    try {
      final items = await _homeRepository.search(event.query, event.type);
      if (state is HomeLoaded) {
        emit((state as HomeLoaded).copyWith(items: items));
      }
    } catch (_) {}
  }
}
