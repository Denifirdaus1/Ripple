import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'core/theme/app_theme.dart';
import 'core/injection/injection_container.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/todo/presentation/bloc/todos_overview_bloc.dart';
import 'features/notes/presentation/bloc/note_bloc.dart';

class RippleApp extends StatelessWidget {
  const RippleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthSubscriptionRequested()),
        ),
        BlocProvider<TodosOverviewBloc>(
          create: (_) => sl<TodosOverviewBloc>()..add(TodosOverviewSubscriptionRequested()),
        ),
        BlocProvider<NoteBloc>(
          create: (_) => sl<NoteBloc>()..add(NoteSubscriptionRequested()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // We need Builder here to access the Bloc provided above for the router refresh listener
          return MaterialApp.router(
            title: 'Ripple',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router(context),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('id', 'ID'),
            ],
          );
        }
      ),
    );
  }
}
