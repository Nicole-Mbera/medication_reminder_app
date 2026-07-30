import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/education_content_model.dart';
import '../../data/repositories/education_repository.dart';

abstract class EducationState extends Equatable {
  const EducationState();

  @override
  List<Object?> get props => [];
}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoaded extends EducationState {
  final List<EducationContentModel> articles;

  const EducationLoaded({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class EducationError extends EducationState {
  final String message;

  const EducationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class EducationCubit extends Cubit<EducationState> {
  final EducationRepository _educationRepository;

  EducationCubit({required EducationRepository educationRepository})
    : _educationRepository = educationRepository,
      super(EducationInitial());

  Future<void> loadArticles() async {
    emit(EducationLoading());
    try {
      final articles = await _educationRepository.getArticles();
      emit(EducationLoaded(articles: articles));
    } catch (e) {
      emit(EducationError(message: e.toString()));
    }
  }
}
