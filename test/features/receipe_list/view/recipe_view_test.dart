// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_app/model/recipe.dart';
import 'package:recipe_app/modules/recipe_list/cubit/recipe_cubit.dart';
import 'package:recipe_app/modules/recipe_list/cubit/recipe_state.dart';
import 'package:recipe_app/modules/recipe_list/cubit/recipe_status.dart';
import 'package:recipe_app/modules/recipe_list/view/recipe_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:recipe_app/modules/recipe_list/view/widgets/recipe_error.dart';
import 'package:recipe_app/modules/recipe_list/view/widgets/recipe_item.dart';

class MockReceipCubit extends MockCubit<RecipeState> implements RecipeCubit {}

void main() {
  group('RecipeView', () {
    late RecipeCubit cubit;
    setUp(() {
      cubit = MockReceipCubit();
    });

    testWidgets('RecipeView in loading state', (tester) async {
      // create initial state
      when(() => cubit.state).thenReturn(
        const RecipeState(
          status: RecipeStatus.loading,
          recipes: [],
        ),
      );

      // fake request fetchRecipe in RecipeView's initState
      when(() => cubit.fetchRecipes()).thenAnswer((_) => Future.value());

      // load RecipeView
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: RecipeView(),
          ),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('RecipeView for success state', (tester) async {
      final recipes = [
        Recipe.fromJson(const {'calories': 'meat'}),
      ];

      when(() => cubit.state).thenReturn(
        RecipeState(
          status: RecipeStatus.success,
          recipes: recipes,
        ),
      );

      // fake request fetchRecipe in RecipeView's initState
      when(() => cubit.fetchRecipes()).thenAnswer((_) => Future.value());

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(home: RecipeView()),
        ),
      );

      expect(find.byType(RecipeItem), findsOneWidget);
    });

    testWidgets('RecipeView for failure state', (tester) async {
      when(() => cubit.state).thenReturn(
        RecipeState(
          status: RecipeStatus.failure,
          error: Exception(),
          recipes: [],
        ),
      );

      // fake request fetchRecipe in RecipeView's initState
      when(() => cubit.fetchRecipes()).thenAnswer((_) => Future.value());

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(home: RecipeView()),
        ),
      );

      expect(find.byType(RecipeError), findsOneWidget);
    });
  });
}
