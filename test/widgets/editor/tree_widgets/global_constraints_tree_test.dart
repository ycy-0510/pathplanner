import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/path/path_constraints.dart';
import 'package:pathplanner/path/pathplanner_path.dart';
import 'package:pathplanner/widgets/editor/tree_widgets/global_constraints_tree.dart';
import 'package:pathplanner/widgets/number_text_field.dart';
import 'package:undo/undo.dart';

void main() {
  late ChangeStack undoStack;
  late PathPlannerPath path;
  late bool pathChanged;

  setUp(() {
    undoStack = ChangeStack();
    path = PathPlannerPath.defaultPath(
      pathDir: '/paths',
      fs: MemoryFileSystem(),
    );
    path.useDefaultConstraints = false;
    path.globalConstraintsExpanded = true;
    path.globalConstraints = PathConstraints(
      maxVelocityMPS: 1.0,
      maxAccelerationMPSSq: 1.0,
      maxAngularVelocityDeg: 1.0,
      maxAngularAccelerationDeg: 1.0,
    );
    pathChanged = false;
  });

  testWidgets('tapping expands/collapses tree', (widgetTester) async {
    path.globalConstraintsExpanded = false;
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    // Tree initially collapsed, expect to find nothing
    expect(find.byType(NumberTextField), findsNothing);

    await widgetTester.tap(find.byType(GlobalConstraintsTree));
    await widgetTester.pumpAndSettle();

    expect(path.globalConstraintsExpanded, true);

    await widgetTester.tap(find.text(
        'Global Constraints')); // Use text so it doesn't tap middle of expanded card
    await widgetTester.pumpAndSettle();
    expect(path.globalConstraintsExpanded, false);
  });

  testWidgets('max vel text field', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    final textField =
        find.widgetWithText(NumberTextField, 'Max Velocity (M/S)');

    expect(textField, findsOneWidget);

    await widgetTester.enterText(textField, '2.0');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(pathChanged, true);
    expect(path.globalConstraints.maxVelocityMPS, 2.0);

    undoStack.undo();
    await widgetTester.pump();
    expect(path.globalConstraints.maxVelocityMPS, 1.0);
  });

  testWidgets('max accel text field', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    final textField =
        find.widgetWithText(NumberTextField, 'Max Acceleration (M/S²)');

    expect(textField, findsOneWidget);

    await widgetTester.enterText(textField, '2.0');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(pathChanged, true);
    expect(path.globalConstraints.maxAccelerationMPSSq, 2.0);

    undoStack.undo();
    await widgetTester.pump();
    expect(path.globalConstraints.maxAccelerationMPSSq, 1.0);
  });

  testWidgets('max ang vel text field', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    final textField =
        find.widgetWithText(NumberTextField, 'Max Angular Velocity (Deg/S)');

    expect(textField, findsOneWidget);

    await widgetTester.enterText(textField, '2.0');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(pathChanged, true);
    expect(path.globalConstraints.maxAngularVelocityDeg, 2.0);

    undoStack.undo();
    await widgetTester.pump();
    expect(path.globalConstraints.maxAngularVelocityDeg, 1.0);
  });

  testWidgets('max ang accel text field', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    final textField = find.widgetWithText(
        NumberTextField, 'Max Angular Acceleration (Deg/S²)');

    expect(textField, findsOneWidget);

    await widgetTester.enterText(textField, '2.0');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(pathChanged, true);
    expect(path.globalConstraints.maxAngularAccelerationDeg, 2.0);

    undoStack.undo();
    await widgetTester.pump();
    expect(path.globalConstraints.maxAngularAccelerationDeg, 1.0);
  });

  testWidgets('use defaults checkbox', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlobalConstraintsTree(
          path: path,
          onPathChanged: () => pathChanged = true,
          undoStack: undoStack,
          defaultConstraints: PathConstraints(),
        ),
      ),
    ));

    final check = find.byType(Checkbox);

    expect(check, findsOneWidget);

    await widgetTester.tap(check);
    await widgetTester.pump();

    expect(pathChanged, true);
    expect(path.globalConstraints, PathConstraints());

    undoStack.undo();
    await widgetTester.pump();
    expect(
        path.globalConstraints,
        PathConstraints(
          maxVelocityMPS: 1.0,
          maxAccelerationMPSSq: 1.0,
          maxAngularVelocityDeg: 1.0,
          maxAngularAccelerationDeg: 1.0,
        ));
  });
}
