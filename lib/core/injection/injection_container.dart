import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';

import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/data/repositories/focus_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/repositories/focus_repository.dart';
import '../../features/todo/domain/usecases/todo_usecases.dart';
import '../../features/todo/presentation/bloc/todos_overview_bloc.dart';
import '../../features/todo/presentation/bloc/focus_timer_cubit.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/domain/usecases/note_usecases.dart';
import '../../features/notes/presentation/bloc/note_bloc.dart';
import '../../features/notes/presentation/bloc/note_editor_cubit.dart';
import '../../features/milestone/data/repositories/milestone_repository_impl.dart';
import '../../features/milestone/domain/repositories/milestone_repository.dart';
import '../../features/milestone/domain/usecases/milestone_usecases.dart';
import '../../features/milestone/presentation/bloc/goal_list_bloc.dart';
import '../../features/milestone/presentation/bloc/milestone_detail_bloc.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/image_upload_service.dart';
import '../../core/services/timezone_service.dart';
import '../properties/properties.dart';

// Folder Feature
import '../../features/folder/data/repositories/folder_repository_impl.dart';
import '../../features/folder/domain/repositories/folder_repository.dart';
import '../../features/folder/domain/usecases/folder_usecases.dart';
import '../../features/folder/presentation/bloc/folder_bloc.dart';

// Profile Feature
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(getAuthStream: sl(), signOut: sl()));

  sl.registerFactory(
    () => LoginCubit(
      signInWithGoogle: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      verifyEmailOtp: sl(),
      resendConfirmationEmail: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAuthStream(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => VerifyEmailOtp(sl()));
  sl.registerLazySingleton(() => ResendConfirmationEmail(sl()));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  //! Features - Todo
  // Bloc
  sl.registerFactory(
    () => TodosOverviewBloc(
      getTodosStream: sl(),
      saveTodo: sl(),
      deleteTodo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodosStream(sl()));
  sl.registerLazySingleton(() => SaveTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));

  // Repository
  sl.registerLazySingleton<TodoRepository>(() => TodoRepositoryImpl());

  // Focus Sessions
  sl.registerLazySingleton<FocusRepository>(
    () => FocusRepositoryImpl(supabase: sl()),
  );

  // Focus Timer - Global singleton for background timer
  sl.registerLazySingleton(() => FocusTimerCubit(focusRepository: sl()));

  //! Core
  // Add core dependencies here

  //! External
  // Add external dependencies here
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  // Notes
  sl.registerFactory(() => NoteBloc(getNotesStream: sl(), deleteNote: sl()));
  sl.registerFactory(
    () => NoteEditorCubit(saveNote: sl(), getNote: sl(), searchMentions: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNotesStream(sl()));
  sl.registerLazySingleton(() => SaveNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => GetNote(sl()));
  sl.registerLazySingleton(() => SearchMentions(sl()));

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(supabase: sl()),
  );

  // Milestones
  sl.registerFactory(
    () =>
        GoalListBloc(getGoalsStream: sl(), createGoal: sl(), repository: sl()),
  );
  sl.registerFactory(() => MilestoneDetailBloc(repository: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetGoalsStream(sl()));
  sl.registerLazySingleton(() => GetGoal(sl()));
  sl.registerLazySingleton(() => CreateGoal(sl()));
  sl.registerLazySingleton(() => GetMilestonesStream(sl()));
  sl.registerLazySingleton(() => CreateMilestone(sl()));
  sl.registerLazySingleton(() => UpdateMilestone(sl()));
  sl.registerLazySingleton(() => DeleteMilestone(sl()));

  // Repository
  sl.registerLazySingleton<MilestoneRepository>(
    () => MilestoneRepositoryImpl(supabase: sl()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(supabase: sl()),
  );
  sl.registerLazySingleton(() => NotificationService(sl()));

  // Core Services
  sl.registerLazySingleton(() => ImageUploadService(supabaseClient: sl()));

  // Property System
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(supabaseClient: sl()),
  );

  // Session Management
  sl.registerLazySingleton(() => SessionService(sl<SupabaseClient>()));

  // Timezone Management
  sl.registerLazySingleton(() => TimezoneService());

  //! Features - Folder
  // Bloc
  sl.registerFactory(
    () => FolderBloc(
      getFoldersStream: sl(),
      getFolderContents: sl(),
      getInboxContents: sl(),
      createFolder: sl(),
      updateFolder: sl(),
      deleteFolder: sl(),
      addItemToFolder: sl(),
      removeItemFromFolder: sl(),
      moveFolder: sl(),
      getNoteIdsInFolders: sl(),
      getFolderNoteCounts: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetFoldersStream(sl()));
  sl.registerLazySingleton(() => GetFolderContents(sl()));
  sl.registerLazySingleton(() => GetInboxContents(sl()));
  sl.registerLazySingleton(() => CreateFolder(sl()));
  sl.registerLazySingleton(() => UpdateFolder(sl()));
  sl.registerLazySingleton(() => DeleteFolder(sl()));
  sl.registerLazySingleton(() => AddItemToFolder(sl()));
  sl.registerLazySingleton(() => RemoveItemFromFolder(sl()));
  sl.registerLazySingleton(() => MoveFolder(sl()));
  sl.registerLazySingleton(() => GetNoteIdsInFolders(sl()));
  sl.registerLazySingleton(() => GetFolderNoteCounts(sl()));

  // Repository
  sl.registerLazySingleton<FolderRepository>(
    () => FolderRepositoryImpl(supabase: sl()),
  );

  //! Features - Profile
  // Repository
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
}
