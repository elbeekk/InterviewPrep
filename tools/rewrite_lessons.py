from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTENT_PATH = ROOT / "InterviewPrep" / "content.json"


def topic(
    summary: str,
    detail_one: str,
    detail_two: str,
    practice: str,
    example_code: str,
    *,
    pitfalls: list[str],
    takeaways: list[str],
    section_code: str | None = None,
    example_language: str | None = None,
    example_title: str | None = None,
) -> dict:
    return {
        "summary": summary.strip(),
        "detail_one": detail_one.strip(),
        "detail_two": detail_two.strip(),
        "practice": practice.strip(),
        "section_code": section_code.strip() if section_code else None,
        "example_code": example_code.rstrip(),
        "example_language": example_language,
        "example_title": example_title,
        "pitfalls": [item.strip() for item in pitfalls],
        "takeaways": [item.strip() for item in takeaways],
    }


SPECS: dict[tuple[str, str], dict] = {
    (
        "flutter",
        "variables_constants_type_system",
    ): topic(
        summary="Dart declarations are really about mutability and clarity: `var` asks the compiler to infer the type, `final` freezes the binding after the first assignment, and `const` requires a compile-time value.",
        detail_one="Use `final` by default for values that should not be reassigned, especially widget configuration and dependencies. Reach for explicit types when the initializer hides intent or the value crosses an API boundary.",
        detail_two="The important distinction is that `final` protects the variable name, not the object behind it. A `final List<int>` can still be mutated, while `const` also makes the value deeply immutable when every nested value is constant.",
        practice="In Flutter code, immutable inputs make rebuilds predictable. If a constructor argument or service reference does not need to change, marking it `final` makes the data flow easier to trust during refactors.",
        example_code="final apiHost = 'api.example.com';\nconst maxRetries = 3;\nList<String> tags = ['flutter'];\nfinal cachedUsers = <String>[];\n\nvoid main() {\n  cachedUsers.add('Mila');\n  print('$apiHost / retries: $maxRetries / users: $cachedUsers');\n}",
        pitfalls=[
            "Using `var` everywhere forces readers to inspect the right-hand side before they know the type or mutability contract.",
            "Treating `final` and `const` as the same thing hides an important compile-time optimization and design difference.",
        ],
        takeaways=[
            "Choose declarations based on mutability and API clarity, not habit.",
            "Use `final` by default and reserve `const` for values known at compile time.",
            "Remember that `final` freezes the binding, while mutable objects can still change internally.",
        ],
    ),
    ("flutter", "null_safety"): topic(
        summary="Sound null safety makes absence explicit. A non-nullable type promises a value exists, while `?`, `??`, `?.`, `!`, `late`, and `required` each express a different strategy for dealing with missing state.",
        detail_one="`String?` means the value may be absent, so you must unwrap it safely before use. `??` provides a fallback, `?.` stops the chain when a null appears, and `required` keeps optionality out of APIs that should never accept missing input.",
        detail_two="The dangerous tools are `!` and careless `late` usage. They move the safety check from compile time to runtime, so you should only use them when some earlier invariant already guarantees the value exists.",
        practice="In Flutter, null safety is most visible around asynchronous data, navigation arguments, and form state. The best design usually models loading, empty, and error states explicitly instead of hiding them behind forced unwraps.",
        example_code="String? nickname;\n\nString buildLabel(String? rawName) {\n  final normalized = rawName?.trim();\n  return normalized?.isNotEmpty == true ? normalized! : 'Anonymous';\n}\n\nvoid main() {\n  print(buildLabel(nickname));\n}",
        pitfalls=[
            "Using `!` to silence the compiler usually means the API design did not model missing state properly.",
            "Adding `late` to avoid initialization errors can create a crash that happens much later and is harder to trace.",
        ],
        takeaways=[
            "Null safety is about making absence explicit and handling it deliberately.",
            "Prefer safe unwrapping and better state models over force-unwrapping values.",
            "Use `required`, defaults, and explicit nullable types to communicate intent in APIs.",
        ],
    ),
    ("flutter", "functions"): topic(
        summary="Functions in Dart are first-class values, so their shape affects readability at the call site, testability, and how easily logic can be reused.",
        detail_one="Named parameters are one of Dart's best readability tools because they make configuration-heavy APIs self-documenting. Optional parameters and default values help when there is a sensible baseline without multiplying overloads.",
        detail_two="Closures capture variables from the surrounding scope, which is powerful for callbacks but easy to misuse when a function quietly depends on hidden mutable state. `typedef` and clear signatures make callback-heavy code easier to reason about.",
        practice="Flutter code is full of small functions: validators, builders, callbacks, mappers, and reducers. Short, explicit functions are easier to test and much easier to scan than giant methods with many optional branches.",
        example_code="typedef PriceFormatter = String Function(double amount);\n\nString greet({required String name, String prefix = 'Hello'}) => '$prefix, $name';\n\nString describeOrder(double total, PriceFormatter formatter) {\n  return 'Total: ${formatter(total)}';\n}\n\nvoid main() {\n  print(greet(name: 'Mila'));\n  print(describeOrder(42, (amount) => '\\$${amount.toStringAsFixed(2)}'));\n}",
        pitfalls=[
            "Long parameter lists usually signal that a value object or a better abstraction is missing.",
            "Closures that depend on outer mutable state can make business logic hard to test and easy to break.",
        ],
        takeaways=[
            "Use named parameters to make Dart APIs obvious at the call site.",
            "Prefer small, focused functions with explicit dependencies over large multi-purpose methods.",
            "Treat captured state carefully because closures can hide coupling that is not visible in the function signature.",
        ],
    ),
    ("flutter", "control_flow"): topic(
        summary="Control flow decides how a program branches, repeats work, and models states. In modern Dart, `if`, loops, and `switch` expressions work best when they express intent instead of just avoiding syntax errors.",
        detail_one="A good `switch` groups related states and makes impossible cases visible. Pattern matching and switch expressions reduce boilerplate because you can destructure values and produce a result directly instead of mutating a temporary variable.",
        detail_two="Readable control flow is usually flat. Early returns, clear guards, and well-named booleans are easier to follow than deeply nested `if` blocks that mix validation, transformation, and side effects in one place.",
        practice="UI code often branches on loading, success, empty, and error states. If the state model is good, the rendering code becomes short and obvious instead of a maze of nullable checks and nested ternaries.",
        example_code="String labelForScore(int score) {\n  final bucket = switch (score) {\n    >= 90 => 'excellent',\n    >= 70 => 'good',\n    >= 50 => 'ok',\n    _ => 'needs work',\n  };\n\n  return bucket;\n}\n",
        pitfalls=[
            "Deeply nested branches make it hard to see which conditions are mutually exclusive and which ones can happen together.",
            "Using loops and switches without naming the underlying state often hides a missing domain model.",
        ],
        takeaways=[
            "Use control flow to express states clearly, not just to make the compiler happy.",
            "Prefer early exits and switch expressions when they make the happy path easier to read.",
            "When branching gets messy, the real fix is often a better state model instead of more syntax.",
        ],
    ),
    ("flutter", "collections"): topic(
        summary="Dart collections are the core tools for holding and transforming data. `List`, `Set`, `Map`, and `Iterable` methods matter because most Flutter screens are built by mapping collections into widgets.",
        detail_one="Choose the collection based on the guarantees you need: ordered items, unique items, or keyed lookup. Generic types are not decoration; they are what keep your transformations safe and your APIs predictable.",
        detail_two="Iterable methods such as `map`, `where`, `expand`, and `fold` let you describe data transformations declaratively. The spread operator and collection `if` or `for` syntax are especially useful in widget trees because they keep layout code concise without losing readability.",
        practice="A large part of day-to-day Flutter work is taking network or database data and turning it into view models. Clean collection pipelines make that step explicit and keep presentation code free of accidental mutation.",
        example_code="final users = [\n  {'name': 'Ari', 'active': true},\n  {'name': 'Mila', 'active': false},\n  {'name': 'Noah', 'active': true},\n];\n\nvoid main() {\n  final activeNames = users\n      .where((user) => user['active'] == true)\n      .map((user) => user['name'])\n      .toList();\n\n  print(activeNames);\n}",
        pitfalls=[
            "Mutating a collection while iterating over it is a fast route to subtle bugs and hard-to-trace state changes.",
            "Using the wrong collection type usually creates accidental complexity later, especially around lookup speed or duplicate handling.",
        ],
        takeaways=[
            "Pick collections based on guarantees like order, uniqueness, and keyed access.",
            "Use Iterable transforms to describe data flow clearly before you build widgets from it.",
            "Typed collections are part of your correctness story, not just a compiler preference.",
        ],
    ),
    ("flutter", "oop_in_dart"): topic(
        summary="Dart gives you classes, abstract classes, mixins, extensions, and sealed hierarchies so you can model behavior deliberately instead of stuffing everything into utility functions.",
        detail_one="Classes are useful when state and behavior belong together, but inheritance should not be your default. Mixins share behavior without forcing a deep parent-child tree, extensions add focused helpers to existing types, and sealed classes are ideal when the set of states must stay closed.",
        detail_two="Dart interfaces are implicit: every class defines one. That makes composition and testing easier because you can depend on capabilities instead of concrete implementations, while abstract classes help when multiple implementations should share a contract and some common behavior.",
        practice="In Flutter apps, sealed classes are a strong fit for UI state, extensions are handy for formatting and mapping, and mixins are best kept for narrowly scoped reusable behavior. Interview answers are strongest when you explain why you chose composition over inheritance in a specific example.",
        example_code="sealed class CheckoutState {}\nclass Idle extends CheckoutState {}\nclass Loading extends CheckoutState {}\nclass Success extends CheckoutState {\n  Success(this.orderId);\n  final String orderId;\n}\nclass Failure extends CheckoutState {\n  Failure(this.message);\n  final String message;\n}\n",
        pitfalls=[
            "Reaching for inheritance first often creates brittle hierarchies that are harder to change than simple composition.",
            "Putting unrelated helpers into broad extensions can make APIs feel magical and hard to discover.",
        ],
        takeaways=[
            "Use the Dart abstraction that matches the problem instead of defaulting to inheritance.",
            "Sealed classes are excellent when the valid states are finite and should be exhaustively handled.",
            "Interfaces and composition usually keep code more testable and flexible than deep class trees.",
        ],
    ),
    ("flutter", "async_programming"): topic(
        summary="Async programming is about coordinating work that finishes later without blocking the UI thread. Dart separates one-shot values with `Future` from many values over time with `Stream`.",
        detail_one="`async` and `await` make sequential asynchronous code readable, but they do not make it synchronous. You still need to think about ordering, cancellation, timeouts, and what happens if the widget that started the work is gone before the result returns.",
        detail_two="Use a `Stream` when values keep arriving over time, such as connectivity changes or database snapshots. `Completer` and `StreamController` are lower-level primitives and should only appear when the standard Future and Stream APIs do not express the workflow cleanly enough.",
        practice="Most Flutter bugs around async code are lifecycle bugs: updating disposed widgets, showing stale data after a later request has already won, or forgetting to close streams and controllers. Strong answers explain how you keep UI state aligned with asynchronous work.",
        example_code="Future<String> loadProfile() async {\n  await Future.delayed(const Duration(milliseconds: 300));\n  return 'Mila';\n}\n\nStream<int> ticker() async* {\n  for (var second = 1; second <= 3; second++) {\n    await Future.delayed(const Duration(seconds: 1));\n    yield second;\n  }\n}\n",
        pitfalls=[
            "Calling `setState` after an async gap without checking lifecycle state can trigger exceptions or stale UI.",
            "Using streams for one-shot work adds moving parts when a plain `Future` would be simpler and clearer.",
        ],
        takeaways=[
            "Use `Future` for one result and `Stream` for multiple values over time.",
            "Async code still needs lifecycle awareness, cancellation strategy, and clear ownership.",
            "Reach for lower-level primitives like `Completer` and `StreamController` only when the simpler APIs are not enough.",
        ],
    ),
    ("flutter", "error_handling"): topic(
        summary="Good error handling separates expected failure modes from programmer mistakes and turns low-level failures into decisions the rest of the app can actually work with.",
        detail_one="`try` and `catch` are only the surface. The real design work is deciding where errors are translated, which layer should know about transport details, and what information is safe and useful to preserve.",
        detail_two="Custom exception types help when failures need structure, while a `Result`-style wrapper is useful when callers should handle success and failure explicitly. Both approaches are better than throwing generic strings or leaking raw library errors across your app.",
        practice="In a Flutter app, repositories often catch HTTP or database errors and map them into domain-level failures that the UI can render. That keeps the presentation layer focused on states like retryable, unauthorized, or empty instead of socket details.",
        example_code="sealed class LoginResult {\n  const LoginResult();\n}\nclass LoginSuccess extends LoginResult {}\nclass LoginFailure extends LoginResult {\n  const LoginFailure(this.message);\n  final String message;\n}\n\nFuture<LoginResult> login(String email) async {\n  try {\n    if (!email.contains('@')) throw FormatException('Invalid email');\n    return LoginSuccess();\n  } catch (_) {\n    return const LoginFailure('Please check the email and try again.');\n  }\n}\n",
        pitfalls=[
            "Catching everything at the edge of the app without translating it produces vague UI and weak logs.",
            "Using exceptions for normal control flow makes success paths harder to read and harder to test.",
        ],
        takeaways=[
            "Handle errors at the layer where you can add meaning, not just where the exception happens to surface.",
            "Map infrastructure failures into domain or presentation states the caller can actually act on.",
            "Prefer structured failures over untyped strings and generic catch-all logic.",
        ],
    ),
    ("flutter", "generics_type_system"): topic(
        summary="Generics let you describe reusable behavior without giving up type safety. They matter most when a widget, service, or collection should work for many types but still preserve compile-time guarantees.",
        detail_one="A generic type parameter is useful when the caller should decide the concrete type. Bounds such as `T extends Object` or `T extends SomeBase` let you say what capabilities the generic code expects without overcommitting to one implementation.",
        detail_two="The type system is also about variance and inference. If a function signature becomes hard to read, that is usually a sign the abstraction is too clever or the generic contract is doing more than one job.",
        practice="In Flutter, generics appear in repositories, state containers, form fields, and reusable widgets. A good interview answer uses generics to reduce duplication while still keeping the API readable to the next person who touches it.",
        example_code="class CacheBox<T> {\n  CacheBox(this.value);\n  T value;\n\n  void update(T nextValue) {\n    value = nextValue;\n  }\n}\n\nvoid main() {\n  final names = CacheBox<List<String>>(['Mila']);\n  names.update([...names.value, 'Noah']);\n  print(names.value);\n}\n",
        pitfalls=[
            "Generic abstractions that hide the actual domain intent are harder to maintain than a little duplication.",
            "Skipping type bounds can leave the contract too vague and push errors to runtime or awkward casts.",
        ],
        takeaways=[
            "Use generics when the caller should supply the concrete type but the behavior stays the same.",
            "Add type bounds when generic code depends on specific capabilities.",
            "Readable generic APIs are more valuable than maximal abstraction.",
        ],
    ),
    ("flutter", "isolates_concurrency"): topic(
        summary="Isolates are Dart's way to run CPU-heavy work concurrently without shared mutable memory. Each isolate owns its own heap and communicates by passing messages.",
        detail_one="That memory model is the key idea: isolates are safer than threads with shared memory because they force explicit communication, but they also cost more to start and coordinate. They are usually the wrong tool for short-lived or purely I/O-bound work.",
        detail_two="In Flutter, the main isolate drives the UI. Heavy JSON parsing, image processing, or large computations can be moved to another isolate so animation and input stay responsive, but the result still has to be marshaled back cleanly.",
        practice="Interviewers often want to hear that `async` is not the same as parallel CPU work. Futures help you wait without blocking, while isolates help when the work itself would monopolize the main isolate and cause jank.",
        example_code="import 'dart:isolate';\n\nFuture<int> expensiveSum(List<int> values) async {\n  return Isolate.run(() => values.fold<int>(0, (sum, value) => sum + value));\n}\n",
        pitfalls=[
            "Starting an isolate for tiny jobs can cost more than the computation you were trying to offload.",
            "Assuming isolates share memory like threads leads to designs that simply do not fit Dart's model.",
        ],
        takeaways=[
            "Use isolates for CPU-bound work that would otherwise block the main isolate.",
            "Dart isolates communicate through message passing, not shared mutable state.",
            "Do not confuse asynchronous waiting with parallel execution of expensive computation.",
        ],
    ),
    ("flutter", "dart_3_features"): topic(
        summary="Dart 3 adds records, patterns, and class modifiers so you can model data and branching more explicitly with less boilerplate.",
        detail_one="Records are lightweight typed tuples, which makes them useful for returning small groups of related values without creating a full class. Patterns let you destructure those values and validate shape in a single expression, especially inside switch statements.",
        detail_two="Class modifiers such as `base`, `interface`, `final`, and `sealed` clarify inheritance intent. They help you communicate whether a type is meant to be subclassed, implemented, or treated as a closed set of states.",
        practice="These features are especially useful for state modeling and small transformations. When used well, they reduce ceremony; when overused, they can make everyday code feel like language trivia instead of communication.",
        example_code="({int total, bool hasNext}) summarizePage(List<String> items) {\n  return (total: items.length, hasNext: items.length == 20);\n}\n\nvoid main() {\n  final (:total, :hasNext) = summarizePage(['a', 'b']);\n  print('$total / $hasNext');\n}\n",
        pitfalls=[
            "Using new syntax just because it is new can make code less approachable for teammates who do not need the cleverness.",
            "Ignoring class modifiers means the compiler cannot help you enforce the inheritance rules you intended.",
        ],
        takeaways=[
            "Records and patterns reduce boilerplate when the shape of data is small and explicit.",
            "Class modifiers make inheritance intent visible and enforceable.",
            "Use Dart 3 features where they clarify the model, not where they only make the code look newer.",
        ],
    ),
    ("flutter", "widget_tree_element_tree_renderobject_tree"): topic(
        summary="Flutter works because three trees collaborate: widgets describe configuration, elements hold identity and location in the tree, and render objects perform layout and painting.",
        detail_one="Widgets are cheap immutable blueprints. When `build` runs, Flutter compares the new widgets to the previous configuration and updates the existing element tree when possible instead of rebuilding the whole engine state from scratch.",
        detail_two="Elements decide whether a widget update can reuse existing state, and render objects apply constraints, compute sizes, and paint pixels. Understanding that split explains why some rebuilds are cheap, why keys matter, and why layout bugs live below the widget layer.",
        practice="This topic is the mental model behind performance discussions. If you can explain which layer stores state and which layer paints, you can reason about rebuilds without cargo-culting optimization tricks.",
        example_code="class CounterLabel extends StatelessWidget {\n  const CounterLabel({super.key, required this.value});\n  final int value;\n\n  @override\n  Widget build(BuildContext context) {\n    return Text('Count: $value');\n  }\n}\n",
        pitfalls=[
            "Saying Flutter has only a widget tree ignores where identity, lifecycle, layout, and painting actually live.",
            "Trying to optimize blindly without understanding which tree is doing the work often wastes effort.",
        ],
        takeaways=[
            "Widgets are immutable configuration, elements preserve identity, and render objects handle layout and paint.",
            "Rebuild does not mean repaint everything; the framework reuses lower layers when it can.",
            "This tree model explains keys, lifecycle behavior, and many performance decisions.",
        ],
    ),
    ("flutter", "statelesswidget_vs_statefulwidget_lifecycle"): topic(
        summary="The difference between `StatelessWidget` and `StatefulWidget` is not complexity but ownership of mutable state over time.",
        detail_one="A `StatelessWidget` is pure configuration: if its inputs change, Flutter creates a new widget and calls `build`. A `StatefulWidget` splits immutable configuration from a `State` object that survives rebuilds and owns lifecycle hooks such as `initState`, `didUpdateWidget`, and `dispose`.",
        detail_two="The lifecycle matters because controllers, focus nodes, animations, and subscriptions need setup and cleanup in the right places. `setState` only marks the local widget subtree dirty; it is not a global state management solution.",
        practice="A good rule is to keep ephemeral UI state local and lift shared or long-lived state to a better owner. Interviewers like hearing why a widget should stay stateful, become stateless, or move its state somewhere else.",
        example_code="class NameField extends StatefulWidget {\n  const NameField({super.key});\n\n  @override\n  State<NameField> createState() => _NameFieldState();\n}\n\nclass _NameFieldState extends State<NameField> {\n  final controller = TextEditingController();\n\n  @override\n  void dispose() {\n    controller.dispose();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return TextField(controller: controller);\n  }\n}\n",
        pitfalls=[
            "Putting shared business state into `setState` makes it hard to test and impossible to reuse outside one widget subtree.",
            "Forgetting cleanup in `dispose` leads to leaks and listeners surviving longer than the UI that created them.",
        ],
        takeaways=[
            "Use `StatefulWidget` when local mutable state must survive rebuilds over time.",
            "Lifecycle hooks exist so setup, updates, and teardown happen in the correct place.",
            "Keep ephemeral UI state local and move shared domain state to a dedicated owner.",
        ],
    ),
    ("flutter", "buildcontext"): topic(
        summary="`BuildContext` is a handle to a widget's location in the element tree, which is why it is used for inherited data lookup, navigation, theming, and size or ancestor queries.",
        detail_one="The main rule is scope: a context only sees ancestors above its element. That is why a context from one place in the tree can read one provider or navigator while another cannot, even inside the same screen.",
        detail_two="Contexts are short-lived. You should not store them long term, and after an async gap you should check whether the widget is still mounted before using context-dependent APIs such as navigation or snack bars.",
        practice="Many 'context not found' bugs come from using the wrong scope or from reading inherited state before it exists. Strong Flutter answers explain context as tree position, not as a magic object required by the framework.",
        example_code="ElevatedButton(\n  onPressed: () {\n    final theme = Theme.of(context);\n    ScaffoldMessenger.of(context).showSnackBar(\n      SnackBar(content: Text('Accent: ${theme.colorScheme.primary}')),\n    );\n  },\n  child: const Text('Show theme info'),\n)\n",
        pitfalls=[
            "Keeping a `BuildContext` in a service or field after the widget lifecycle has moved on invites invalid lookups.",
            "Using a context from the wrong subtree is the root cause of many navigation and provider lookup errors.",
        ],
        takeaways=[
            "A `BuildContext` represents tree position, not global app state.",
            "Context lookups only work for ancestors available above that exact element.",
            "Do not store context long term, and guard context usage after async gaps with lifecycle checks.",
        ],
    ),
    ("flutter", "keys"): topic(
        summary="Keys tell Flutter how to match widgets across rebuilds when position alone is not enough to preserve the correct state or animation.",
        detail_one="`ValueKey` uses a stable value, `ObjectKey` uses object identity, and `UniqueKey` forces the framework to treat the widget as brand new every time. `GlobalKey` is the most powerful option because it gives cross-tree identity and state access, but that power comes with more coupling and cost.",
        detail_two="The real question is not 'what key type exists' but 'what identity should survive reorder, insertion, and removal.' Lists that change order are the classic case where the absence of a stable key causes state to stick to the wrong row.",
        practice="Use keys deliberately around reorderable lists, animated collections, and forms that need stable state. If you only add keys everywhere without understanding identity, you often hide the real modeling problem.",
        example_code="ListView(\n  children: todos.map((todo) {\n    return CheckboxListTile(\n      key: ValueKey(todo.id),\n      value: todo.isDone,\n      onChanged: (_) {},\n      title: Text(todo.title),\n    );\n  }).toList(),\n)\n",
        pitfalls=[
            "Using `UniqueKey` to 'fix' a bug often just forces state to reset instead of preserving the right identity.",
            "Reaching for `GlobalKey` first creates unnecessary coupling when a stable local key would solve the actual problem.",
        ],
        takeaways=[
            "Keys exist to preserve the right identity when widget position changes.",
            "Choose the key type based on what should stay stable across rebuilds and reorders.",
            "Use `GlobalKey` sparingly because it solves special cases, not everyday list identity.",
        ],
    ),
    ("flutter", "layouts"): topic(
        summary="Flutter layout follows one rule chain: constraints go down, sizes go up, and parents set positions. Once that mental model clicks, widgets like `Row`, `Column`, `Stack`, `Wrap`, and `LayoutBuilder` stop feeling mysterious.",
        detail_one="Overflow and 'unbounded constraints' errors usually happen because a child is asking for more freedom than its parent can actually offer. Widgets such as `Expanded`, `Flexible`, `SizedBox`, `ConstrainedBox`, and `AspectRatio` are tools for negotiating that contract.",
        detail_two="`LayoutBuilder` is useful when a child needs the actual incoming constraints to decide what to render. `Wrap` and `Stack` solve different problems: wrap flows items to the next line, while stack layers items in the same paint space.",
        practice="Most Flutter layout debugging becomes easier when you stop asking 'which widget should I try next' and instead ask 'what constraints is each widget receiving and returning.' That is the interview answer that sounds like real understanding.",
        example_code="Row(\n  children: const [\n    Expanded(child: Text('This label can take the remaining width')),\n    SizedBox(width: 12),\n    Icon(Icons.check_circle),\n  ],\n)\n",
        pitfalls=[
            "Adding random `SizedBox` or `Expanded` widgets without understanding the incoming constraints rarely fixes the actual layout bug.",
            "Confusing `Wrap` with `Row` or `Column` leads to screens that behave well in one width but break immediately in another.",
        ],
        takeaways=[
            "Think in constraints first; layout widgets are just ways of negotiating that contract.",
            "Use sizing and flex tools intentionally instead of stacking them until the error disappears.",
            "When layout changes with width or height, inspect constraints rather than guessing.",
        ],
    ),
    ("flutter", "responsive_design"): topic(
        summary="Responsive design in Flutter means adapting layout to available space and platform expectations, not merely shrinking everything until it fits.",
        detail_one="`MediaQuery` gives you screen-level information such as padding, text scaling, and size, while `LayoutBuilder` is often better when a specific part of the UI needs to react to its actual constraints. Breakpoints help you switch structure deliberately instead of writing one giant flexible layout that is mediocre everywhere.",
        detail_two="Responsive and adaptive are related but not identical. Responsive design handles size changes; adaptive design also considers platform conventions, input methods, navigation patterns, and whether a large screen should show more information at once.",
        practice="A common mobile interview example is turning a single-column list-detail flow into a split layout on tablets. The best answer explains both the technical tools and the product reason for reorganizing the information hierarchy.",
        example_code="LayoutBuilder(\n  builder: (context, constraints) {\n    if (constraints.maxWidth >= 700) {\n      return const Row(\n        children: [\n          Expanded(child: MailboxList()),\n          VerticalDivider(width: 1),\n          Expanded(child: MessageDetail()),\n        ],\n      );\n    }\n\n    return const MailboxList();\n  },\n)\n",
        pitfalls=[
            "Relying only on screen width ignores text scaling, safe areas, and real component constraints.",
            "Keeping the same information architecture on tablet and phone can waste the extra space instead of improving usability.",
        ],
        takeaways=[
            "Use responsive techniques to adapt to space and adaptive thinking to respect platform context.",
            "Prefer breakpoints and structural changes over one fragile layout that tries to fit every size.",
            "Choose between `MediaQuery` and `LayoutBuilder` based on whether you need screen data or local constraints.",
        ],
    ),
    ("flutter", "slivers"): topic(
        summary="Slivers are Flutter's low-level scrollable building blocks. They let one scroll view combine lazily rendered lists, grids, app bars, and custom effects in a single coordinated viewport.",
        detail_one="A normal `ListView` hides the sliver system, but `CustomScrollView` exposes it. `SliverList`, `SliverGrid`, `SliverAppBar`, and adapters all speak the same protocol, which is why they can share scrolling behavior without nesting multiple scroll views on top of each other.",
        detail_two="The main benefit is composition and laziness. Slivers can build only what is visible, preserve one scroll axis, and support advanced behavior such as collapsible headers or mixed list-grid feeds without the performance and gesture conflicts of nested scrollables.",
        practice="Use slivers when a screen has complex scrolling structure, not just because they are more advanced. Interviewers usually want to hear when a plain `ListView` is enough and when a `CustomScrollView` becomes the cleaner architecture.",
        example_code="CustomScrollView(\n  slivers: const [\n    SliverAppBar(\n      pinned: true,\n      expandedHeight: 180,\n      flexibleSpace: FlexibleSpaceBar(title: Text('Explore')),\n    ),\n    SliverList.list(\n      children: [\n        ListTile(title: Text('First item')),\n        ListTile(title: Text('Second item')),\n      ],\n    ),\n  ],\n)\n",
        pitfalls=[
            "Choosing slivers for a simple screen adds cognitive overhead without solving a real problem.",
            "Nesting multiple primary scroll views is a common sign that the screen should be redesigned around one sliver-based viewport.",
        ],
        takeaways=[
            "Slivers are composable pieces of one lazy scrollable viewport.",
            "Reach for `CustomScrollView` when a screen mixes headers, grids, and lists in one scroll flow.",
            "Do not use slivers just because they are powerful; use them when the scroll structure actually needs them.",
        ],
    ),
    ("flutter", "forms_input"): topic(
        summary="Forms are about turning raw user input into valid domain data while keeping focus, validation, and submission feedback coherent.",
        detail_one="`TextFormField` and the `Form` widget give you a structured validation flow, but the design question is where validation should happen and how eagerly. Synchronous checks are great for shape and emptiness, while asynchronous checks should usually happen at submit time or with deliberate debouncing.",
        detail_two="Controllers, `FocusNode`, and input formatters are lifecycle-sensitive objects. They make it possible to manage cursor behavior, focus movement, and text transformations, but they also need clear ownership and cleanup when the widget goes away.",
        practice="A good user experience validates early enough to help but not so aggressively that typing feels hostile. In interviews, talk about validation rules, submission state, keyboard flow, and what happens when the backend rejects otherwise well-formed input.",
        example_code="final formKey = GlobalKey<FormState>();\n\nForm(\n  key: formKey,\n  child: TextFormField(\n    validator: (value) {\n      if (value == null || value.trim().isEmpty) {\n        return 'Email is required';\n      }\n      return value.contains('@') ? null : 'Enter a valid email';\n    },\n  ),\n)\n",
        pitfalls=[
            "Putting all validation only in the UI layer makes it easy for business rules to diverge from the real domain constraints.",
            "Forgetting to dispose controllers and focus nodes leads to leaks and confusing behavior after navigation.",
        ],
        takeaways=[
            "Forms combine validation, focus management, submission state, and user feedback.",
            "Use synchronous validators for quick feedback and design asynchronous validation deliberately.",
            "Treat controllers and focus nodes as owned resources with explicit lifecycle management.",
        ],
    ),
    ("flutter", "navigation"): topic(
        summary="Navigation is really app state expressed as screens and URLs. The main difference between Flutter approaches is whether you drive routes imperatively or model them declaratively.",
        detail_one="Navigator 1.0 uses push and pop calls, which is straightforward for simple flows. Navigator 2.0 turns the route stack into state, which is more flexible for deep links and web-style addressability but much heavier to wire by hand.",
        detail_two="Packages like GoRouter sit on top of those primitives to make route parsing, redirection, nested navigation, and deep linking more practical. The trade-off is giving up some low-level control in exchange for clearer route definitions and less boilerplate.",
        practice="Strong answers connect navigation to auth flows, tabs, and deep links. The important question is not which API is newer, but which model makes the app's navigation state easiest to reason about and test.",
        example_code="final router = GoRouter(\n  routes: [\n    GoRoute(path: '/', builder: (_, __) => const HomeView()),\n    GoRoute(path: '/product/:id', builder: (_, state) {\n      return ProductView(id: state.pathParameters['id']!);\n    }),\n  ],\n);\n",
        pitfalls=[
            "Mixing multiple navigation styles without a clear ownership model usually creates confusing back-stack behavior.",
            "Treating deep links as an afterthought makes auth redirects and shareable URLs much harder later.",
        ],
        takeaways=[
            "Choose navigation APIs based on how explicit your route state needs to be.",
            "Declarative routing is especially valuable when deep links and redirects are part of the product.",
            "Keep one clear source of truth for navigation behavior instead of layering ad hoc pushes everywhere.",
        ],
    ),
    ("flutter", "state_management"): topic(
        summary="State management is about choosing the right owner for changing data and deciding which parts of the UI should react when that data changes.",
        detail_one="`setState` is perfect for local ephemeral state. `InheritedWidget` is the primitive for sharing state down the tree, while Provider, Riverpod, Bloc, and similar tools package different trade-offs around reactivity, dependency wiring, and testability.",
        detail_two="The most important interview skill is not listing libraries. It is explaining why a piece of state should stay local, move up, live in a dedicated controller, or become derived data instead of stored data.",
        practice="In real apps, the simplest solution that matches the scope of the problem is usually best. Teams get into trouble when they pick a framework first and only later discover that their ownership, caching, and error-state decisions were never clear.",
        example_code="class CounterNotifier extends ChangeNotifier {\n  int count = 0;\n\n  void increment() {\n    count += 1;\n    notifyListeners();\n  }\n}\n",
        pitfalls=[
            "Choosing a state management library before defining state ownership and update boundaries leads to accidental complexity.",
            "Storing derived values instead of recomputing them from source state creates synchronization bugs.",
        ],
        takeaways=[
            "State management starts with ownership and data flow, not package selection.",
            "Keep local UI state local and escalate only when multiple parts of the app genuinely need shared ownership.",
            "A good solution makes updates explicit and rebuild scope easy to control.",
        ],
    ),
    ("flutter", "dependency_injection"): topic(
        summary="Dependency injection separates object creation from object use so code can depend on contracts and receive different implementations in tests, previews, or production.",
        detail_one="Manual injection through constructors is the simplest and most explicit form. Service locators like `get_it` reduce wiring noise, while provider-based approaches such as Riverpod combine dependency access with lifecycle and reactive state features.",
        detail_two="The trade-off is visibility. Explicit constructor injection shows dependencies where they are needed, while container-style access can hide them and make code easier to write but harder to read when overused.",
        practice="In interview answers, talk about testability, replaceability, and ownership. Dependency injection is not about using a framework; it is about avoiding hard-coded creation inside business logic.",
        example_code="class ProfileRepository {\n  ProfileRepository(this.apiClient);\n  final ApiClient apiClient;\n\n  Future<Profile> load() => apiClient.fetchProfile();\n}\n",
        pitfalls=[
            "A service locator can become hidden global state if every class reaches into it freely.",
            "Injecting everything through a giant root container without clear boundaries can make dependency graphs harder to understand, not easier.",
        ],
        takeaways=[
            "Dependency injection keeps creation separate from behavior so implementations can vary safely.",
            "Start with explicit constructor injection unless a broader wiring tool solves a real problem.",
            "The best DI choice is the one that keeps dependencies visible and test seams easy to use.",
        ],
    ),
    ("flutter", "networking"): topic(
        summary="Networking code should turn remote calls into predictable domain data while handling serialization, retries, authentication, and observability without leaking transport details everywhere.",
        detail_one="The HTTP client is only one part of the design. `http` is small and direct, `dio` adds interceptors and richer middleware, and code generation tools like Retrofit or `json_serializable` help reduce repetitive mapping logic.",
        detail_two="The key design choice is where to decode JSON, where to translate failures, and how to keep request concerns like auth headers or logging out of feature widgets. Repositories are often the seam that turns transport data into app-level models.",
        practice="Real networking answers mention timeouts, cancellation, cache strategy, and what the UI should do during loading and failure. That is far more convincing than listing package names from memory.",
        example_code="final dio = Dio()\n  ..interceptors.add(\n    InterceptorsWrapper(\n      onRequest: (options, handler) {\n        options.headers['Authorization'] = 'Bearer token';\n        return handler.next(options);\n      },\n    ),\n  );\n",
        pitfalls=[
            "Parsing JSON and handling transport errors inside widgets mixes presentation with infrastructure concerns.",
            "Retrying blindly without considering idempotency, auth state, or user intent can create worse failures than the original request.",
        ],
        takeaways=[
            "Design the networking layer so widgets consume domain data and app-level failures, not raw transport details.",
            "Pick libraries based on middleware and ergonomics needs, not because one package is fashionable.",
            "Authentication, serialization, and observability are part of the networking design from day one.",
        ],
        example_language="dart",
    ),
    ("flutter", "local_storage"): topic(
        summary="Local storage choices depend on the shape of the data, how often it changes, and whether you need simple preferences, offline-first querying, or relational integrity.",
        detail_one="Key-value stores such as SharedPreferences are fine for tiny settings, but they are a poor fit for structured domain data. Local databases like sqflite, drift, Isar, or Hive exist because querying, indexing, and relationships eventually matter.",
        detail_two="The storage layer should also define ownership and invalidation rules. What is cached, what is the source of truth, and how conflicts are merged matter more than the specific package name in most interviews.",
        practice="A strong answer compares tools by read-write patterns, schema complexity, and offline requirements. For example, user settings, cached feeds, and transactional financial data should not all be stored with the same approach.",
        example_code="class SettingsStore {\n  SettingsStore(this.prefs);\n  final SharedPreferences prefs;\n\n  Future<void> saveThemeMode(String mode) async {\n    await prefs.setString('theme_mode', mode);\n  }\n}\n",
        pitfalls=[
            "Using a simple key-value store for relational or query-heavy data usually creates migration pain later.",
            "Caching data locally without a clear invalidation strategy leads to stale UI and hard-to-debug sync issues.",
        ],
        takeaways=[
            "Choose storage by data shape, query needs, and source-of-truth rules.",
            "Simple preferences and offline domain data are different problems and deserve different tools.",
            "A storage strategy is incomplete until cache freshness and migration are defined.",
        ],
    ),
    ("flutter", "firebase_integration"): topic(
        summary="Firebase integration is less about adding SDKs and more about deciding which backend services the app can trust for auth, data sync, messaging, and crash visibility.",
        detail_one="Authentication, Firestore, FCM, and Crashlytics solve different layers of the problem. The app still needs clear ownership around user session state, data modeling, security rules, and what should happen when connectivity or permissions change.",
        detail_two="Firebase feels fast to start with because many services are managed, but that convenience does not remove architecture questions. You still need boundaries so Firebase-specific types do not leak into every feature.",
        practice="Good answers mention platform setup, environment separation, analytics or crash privacy, and security rules. Interviewers want to hear that you know managed services still require disciplined app design.",
        example_code="await Firebase.initializeApp();\n\nfinal auth = FirebaseAuth.instance;\nfinal result = await auth.signInWithEmailAndPassword(\n  email: email,\n  password: password,\n);\nprint(result.user?.uid);\n",
        pitfalls=[
            "Treating Firestore rules and auth configuration as setup chores instead of core security decisions is risky.",
            "Letting Firebase SDK types leak directly into presentation code makes future migration and testing harder.",
        ],
        takeaways=[
            "Firebase services solve infrastructure problems, but app architecture still needs clear boundaries.",
            "Security rules, auth state handling, and environment setup are first-class concerns.",
            "Wrap Firebase behind app-level services or repositories instead of coupling every feature to the SDK.",
        ],
    ),
    ("flutter", "animations"): topic(
        summary="Animation in Flutter is about changing values over time in a controlled way so motion communicates state, hierarchy, and continuity rather than pure decoration.",
        detail_one="Implicit animations are best when Flutter can interpolate for you from one value to another. Explicit animations with `AnimationController`, `Tween`, and builders are more work, but they give you precise timing, orchestration, and lifecycle control.",
        detail_two="Hero transitions, `AnimatedBuilder`, `TweenAnimationBuilder`, Rive, and Lottie all sit on the same design question: do you need simple interpolation, frame-level control, or asset-driven motion. Choosing the lightest tool that fits keeps motion maintainable.",
        practice="Strong motion design serves a user goal: reinforcing navigation, showing causality, or softening layout changes. The best interview answers mention when animation helps understanding and when it becomes distracting or too expensive.",
        example_code="class FadeCard extends StatefulWidget {\n  const FadeCard({super.key});\n\n  @override\n  State<FadeCard> createState() => _FadeCardState();\n}\n\nclass _FadeCardState extends State<FadeCard> with SingleTickerProviderStateMixin {\n  late final AnimationController controller = AnimationController(\n    vsync: this,\n    duration: const Duration(milliseconds: 300),\n  )..forward();\n\n  @override\n  void dispose() {\n    controller.dispose();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return FadeTransition(opacity: controller, child: const Card());\n  }\n}\n",
        pitfalls=[
            "Using explicit controllers when an implicit animation would do makes simple UI harder to maintain.",
            "Adding motion without a product reason can hurt clarity, accessibility, and performance all at once.",
        ],
        takeaways=[
            "Start with the simplest animation tool that expresses the motion you actually need.",
            "Use animation to communicate state changes and continuity, not just to make the UI feel busy.",
            "Explicit animation APIs are powerful, but they also create lifecycle and maintenance responsibilities.",
        ],
    ),
    ("flutter", "custom_painting"): topic(
        summary="Custom painting gives you direct drawing control when standard widgets are not expressive enough, such as charts, signature pads, decorative backgrounds, or game-like visuals.",
        detail_one="`CustomPainter` works at the canvas level, so you are responsible for describing shapes, colors, clipping, transforms, and when repainting should happen. That power is useful, but it sits lower than normal widget composition and therefore requires more discipline.",
        detail_two="`shouldRepaint` matters because painting can be expensive. The goal is to repaint only when the inputs that affect the drawing actually change, not every time some unrelated widget above it rebuilds.",
        practice="A good interview answer explains when custom painting is worth the complexity. If layout widgets or existing components can solve the problem, they are usually easier to theme, test, and maintain than raw drawing code.",
        example_code="class DotPainter extends CustomPainter {\n  @override\n  void paint(Canvas canvas, Size size) {\n    final paint = Paint()..color = Colors.blue;\n    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, paint);\n  }\n\n  @override\n  bool shouldRepaint(covariant DotPainter oldDelegate) => false;\n}\n",
        pitfalls=[
            "Using custom painting for problems standard widgets already solve adds complexity with little upside.",
            "Returning `true` from `shouldRepaint` all the time can create expensive redraw work without any visual benefit.",
        ],
        takeaways=[
            "Custom painting is a lower-level escape hatch for visuals that normal widgets cannot express cleanly.",
            "Manage repaint frequency deliberately because drawing cost can rise quickly.",
            "Prefer standard composition first, then drop to canvas APIs only when the problem truly needs it.",
        ],
    ),
    ("flutter", "platform_channels"): topic(
        summary="Platform channels let Flutter call into native code when a capability is not available through the framework or an existing plugin.",
        detail_one="`MethodChannel` is request-response, `EventChannel` streams values from the platform side, and tools like Pigeon generate typed interfaces to reduce stringly typed glue code. The channel is just the bridge; you still need a stable contract on both sides.",
        detail_two="The hardest part is not writing the call, but managing serialization, threading expectations, lifecycle, and version compatibility between Dart and the native implementation. That is why a well-defined boundary matters more than the channel API itself.",
        practice="Use channels when the app truly needs custom native capabilities or legacy SDK integration. If a maintained plugin already solves the need well, shipping custom bridge code may create unnecessary surface area to own forever.",
        example_code="const channel = MethodChannel('device/info');\n\nFuture<String> platformVersion() async {\n  return await channel.invokeMethod<String>('platformVersion') ?? 'unknown';\n}\n",
        pitfalls=[
            "Passing loosely structured maps and magic strings through the bridge makes both sides fragile and hard to evolve.",
            "Creating custom channels for capabilities that a stable plugin already covers adds maintenance cost without clear benefit.",
        ],
        takeaways=[
            "Platform channels are a bridge, so the contract between Dart and native code must stay explicit and versionable.",
            "Choose `MethodChannel` or `EventChannel` based on whether the interaction is one-shot or streaming.",
            "Use Pigeon or another typed layer when the bridge surface starts to grow.",
        ],
    ),
    ("flutter", "theming"): topic(
        summary="Theming is how you turn design decisions into consistent, reusable visual tokens instead of hard-coded colors and text styles scattered across the app.",
        detail_one="`ThemeData` and `ColorScheme` define semantic roles like primary, surface, and error rather than raw RGB values. Material 3 leans heavily on those roles so components can adapt consistently across light mode, dark mode, and dynamic color contexts.",
        detail_two="A good theme architecture distinguishes app-wide tokens from one-off component tweaks. The more your widgets depend on semantic roles and shared typography, the easier it is to evolve the design without touching every screen.",
        practice="In interviews, connect theming to maintainability and accessibility. Dark mode, contrast, and feature-specific styling become much easier when the app uses semantic theme values instead of hard-coded visual decisions.",
        example_code="final theme = ThemeData(\n  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),\n  useMaterial3: true,\n  textTheme: const TextTheme(\n    titleLarge: TextStyle(fontWeight: FontWeight.w700),\n  ),\n);\n",
        pitfalls=[
            "Hard-coding colors inside feature widgets makes redesigns and dark mode support far more expensive.",
            "Treating theme objects as a dumping ground for random constants creates a second source of truth instead of a design system.",
        ],
        takeaways=[
            "Use semantic theme roles so visual decisions stay consistent and reusable.",
            "Centralized theming reduces redesign cost and makes accessibility requirements easier to meet.",
            "Local visual overrides should be the exception, not the main design strategy.",
        ],
    ),
    ("flutter", "internationalization"): topic(
        summary="Internationalization is the engineering work that makes multiple languages, regions, and formatting rules possible without rewriting the app for each market.",
        detail_one="The `intl` package and ARB files separate translatable messages from code, while generated localization classes give typed access to those strings. That setup also supports pluralization, gender, and locale-aware date or number formatting.",
        detail_two="Localization is more than translating words. Layout expansion, right-to-left direction, currency formatting, and culturally different copy length all affect the way the UI must be built.",
        practice="Strong answers mention avoiding string concatenation, testing long translations, and making locale an explicit part of formatting logic. The goal is to design UI that can flex, not just to extract strings at the end.",
        example_code="Text(\n  AppLocalizations.of(context)!.welcomeMessage,\n)\n",
        pitfalls=[
            "Building sentences by concatenating fragments breaks translation quality and often grammar itself.",
            "Waiting until the end of development to think about localization makes layout and formatting problems far more expensive.",
        ],
        takeaways=[
            "Internationalization separates locale-aware content and formatting from hard-coded UI strings.",
            "Plan for pluralization, formatting, and layout growth instead of translating only the obvious labels.",
            "Localization succeeds when the UI is designed to flex, not when strings are merely extracted.",
        ],
    ),
    ("flutter", "accessibility"): topic(
        summary="Accessibility work makes the app usable for people who rely on screen readers, larger text, keyboard or switch input, reduced motion, or stronger contrast.",
        detail_one="Flutter's `Semantics` system gives assistive technologies meaning, but accessible apps also depend on focus order, touch target size, color contrast, and the willingness to test with VoiceOver and TalkBack instead of guessing.",
        detail_two="Accessibility is not a final QA task. It shapes naming, interaction patterns, error messaging, animation choices, and whether important information is available in more than one sensory channel.",
        practice="A credible interview answer moves past 'add labels' and talks about how inaccessible designs block real tasks. For example, a beautiful custom control that cannot announce its value or focus state is functionally broken for some users.",
        example_code="Semantics(\n  label: 'Profile picture',\n  hint: 'Double tap to change the photo',\n  button: true,\n  child: GestureDetector(\n    onTap: () {},\n    child: const CircleAvatar(),\n  ),\n)\n",
        pitfalls=[
            "Assuming visual polish automatically means accessible interaction usually hides major usability failures.",
            "Testing only with default text size and without assistive tech leaves many accessibility bugs invisible to the team.",
        ],
        takeaways=[
            "Accessibility combines semantics, focus behavior, readable content, and resilient layout.",
            "Screen-reader labels are necessary but not sufficient for an accessible experience.",
            "Build and test with accessibility in mind from the start instead of treating it as a final patch.",
        ],
    ),
    ("flutter", "testing"): topic(
        summary="Testing is how you prove behavior at the right level of abstraction instead of manually re-checking the same assumptions after every change.",
        detail_one="Unit tests are best for pure logic, widget tests cover UI behavior in isolation, integration tests exercise whole flows, and golden tests catch visual regressions. Each layer has a cost, so the goal is not to maximize test count but to place the right confidence at the right level.",
        detail_two="Mocking is useful when a collaborator is expensive or nondeterministic, but too much mocking can make tests assert implementation details instead of user-visible behavior. The healthiest suites keep most tests fast and deterministic while reserving slower end-to-end coverage for key paths.",
        practice="A good interview answer mentions test seams, repeatability, and what should be tested with real implementations versus fakes. It also explains how you keep UI logic small enough that widget tests stay practical.",
        example_code="testWidgets('shows validation error for empty email', (tester) async {\n  await tester.pumpWidget(const MaterialApp(home: EmailForm()));\n  await tester.tap(find.text('Submit'));\n  await tester.pump();\n\n  expect(find.text('Email is required'), findsOneWidget);\n});\n",
        pitfalls=[
            "Mocking every dependency can make tests brittle and disconnected from the behavior users actually see.",
            "Relying only on manual QA means regressions are found late and often without a reproducible safety net.",
        ],
        takeaways=[
            "Choose the test level based on the behavior you want confidence in, not on habit.",
            "Keep most tests fast and deterministic so they help during everyday development.",
            "Test behavior and boundaries more than framework implementation details.",
        ],
    ),
    ("flutter", "performance"): topic(
        summary="Performance work is about finding the real source of jank, memory churn, or overdraw and fixing it with evidence instead of folklore.",
        detail_one="Flutter DevTools helps you inspect frame times, rebuild counts, memory usage, and rendering cost. `const` constructors, lazy lists, `RepaintBoundary`, and memoized work can all help, but only when they address the specific bottleneck you measured.",
        detail_two="Not every rebuild is a problem. The question is whether rebuilds trigger expensive layout or paint work, or whether synchronous CPU tasks are monopolizing the main isolate. Good performance answers distinguish those cases instead of treating all rebuilds as inherently bad.",
        practice="In real apps, common issues include decoding large payloads on the main isolate, building huge offscreen lists eagerly, and repainting large areas for small changes. Profiling first lets you choose the fix that actually matters.",
        example_code="ListView.builder(\n  itemCount: products.length,\n  itemBuilder: (context, index) {\n    final product = products[index];\n    return ProductRow(product: product);\n  },\n)\n",
        pitfalls=[
            "Applying every known optimization pattern at once makes code harder to read and often does not touch the real bottleneck.",
            "Equating rebuild count with performance quality hides the difference between cheap configuration work and expensive paint or layout.",
        ],
        takeaways=[
            "Profile before optimizing so you know whether the problem is build, layout, paint, memory, or CPU work.",
            "Use performance tools to target the actual bottleneck instead of cargo-culting optimizations.",
            "A small number of deliberate fixes beats a long list of premature micro-optimizations.",
        ],
    ),
    ("flutter", "architecture_patterns"): topic(
        summary="Architecture patterns exist to make change cheaper by separating concerns, clarifying boundaries, and giving the team predictable places for logic to live.",
        detail_one="Feature-first organization groups everything a feature needs in one place, which often helps growing apps more than pure layer-first folders. Clean Architecture, repositories, and use cases can be useful, but only when the extra layers are buying isolation and testability instead of ceremony.",
        detail_two="The best architecture is rarely the most abstract one. It is the one whose boundaries match the volatility of the product: where UI changes often, domain rules stay valuable, and infrastructure details can change without forcing the whole codebase to move.",
        practice="Interviewers usually care less about labels like MVVM or Clean Architecture than about whether you can explain responsibility boundaries with a concrete feature. Show how data flows from API or storage to domain logic to UI and where you would test each part.",
        example_code="class LoadProfileUseCase {\n  LoadProfileUseCase(this.repository);\n  final ProfileRepository repository;\n\n  Future<Profile> call() => repository.fetchProfile();\n}\n",
        pitfalls=[
            "Adding layers because a blog post said so often creates indirection without reducing real coupling.",
            "A folder structure is not architecture if responsibilities and data flow are still unclear.",
        ],
        takeaways=[
            "Architecture should reduce the cost of change, not increase ceremony for its own sake.",
            "Choose boundaries based on volatility, test seams, and team comprehension.",
            "A good explanation follows the data flow of one real feature from inputs to UI.",
        ],
    ),
    ("flutter", "flavors_environment_configuration"): topic(
        summary="Flavors and environment configuration let one codebase target different backends, app identities, and release settings without manual editing before every build.",
        detail_one="A flavor normally changes bundle identifiers, icons, names, endpoints, feature flags, or analytics environments. The goal is to make staging, QA, and production reproducible so people and pipelines cannot accidentally ship the wrong configuration.",
        detail_two="`--dart-define` and flavor-specific entry points are common Flutter tools, but the bigger design question is how secrets are handled and how configuration values stay explicit across local development and CI.",
        practice="A good answer mentions avoiding hard-coded environment values, making non-production builds obvious in the UI, and keeping build configuration deterministic. This topic is really about release safety, not just developer convenience.",
        example_code="void main() {\n  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');\n  runApp(MyApp(apiBaseUrl: apiBaseUrl));\n}\n",
        pitfalls=[
            "Relying on manual edits to switch environments is how staging credentials end up in production builds.",
            "Treating secrets and environment configuration as the same problem can expose values that should never live in the client binary.",
        ],
        takeaways=[
            "Flavors make environments reproducible and reduce release mistakes.",
            "Inject configuration explicitly so local runs and CI builds use the same contract.",
            "Separate safe runtime configuration from secrets that should not ship in the client at all.",
        ],
    ),
    ("flutter", "ci_cd"): topic(
        summary="CI/CD turns build, test, signing, and distribution steps into repeatable automation so the team can trust releases instead of recreating them by hand.",
        detail_one="Continuous integration focuses on validation: linting, tests, static analysis, and building artifacts on every meaningful change. Continuous delivery or deployment goes further by packaging, signing, and releasing those artifacts to internal testers or stores.",
        detail_two="For Flutter projects, tools like GitHub Actions, Codemagic, and Fastlane mainly differ in integration ergonomics and hosted capabilities. The enduring design questions are secret management, cache strategy, pipeline speed, and what gates should block a release.",
        practice="Strong answers describe a pipeline as stages with clear ownership. For example: install dependencies, run tests, build app artifacts, sign them securely, distribute to testers, and publish only after approvals or automated checks pass.",
        example_code="name: Flutter CI\non: [push]\njobs:\n  build:\n    runs-on: macos-latest\n    steps:\n      - uses: actions/checkout@v4\n      - uses: subosito/flutter-action@v2\n      - run: flutter test\n      - run: flutter build ios --no-codesign\n",
        pitfalls=[
            "Automating builds without defining release gates or secret handling can make the pipeline fast but unsafe.",
            "Pipelines that are slow and flaky quickly lose trust, so developers stop treating them as real feedback.",
        ],
        takeaways=[
            "CI/CD is about reliable automation of validation and release steps, not just adding a YAML file.",
            "A useful pipeline is fast enough to trust and strict enough to block unsafe changes.",
            "Signing, secret management, and artifact distribution are part of the delivery design from the start.",
        ],
        example_language="yaml",
        section_code=None,
    ),
    ("flutter", "publishing"): topic(
        summary="Publishing is the process of turning a built app into a compliant, signed, review-ready release for the App Store and Play Store.",
        detail_one="Code signing, versioning, store metadata, privacy disclosures, screenshots, and review policies all affect whether a release can ship. The app binary is only one piece of the release package.",
        detail_two="A strong release process includes staged rollouts, crash monitoring, and a plan for rollback or hotfixes. Publishing is easier when the team has already automated signing, environment management, and QA checkpoints earlier in the pipeline.",
        practice="Interview answers are strongest when they treat publishing as a cross-functional release discipline. Mention testers, compliance, store review delays, and how you avoid surprises late in the process.",
        example_code="Release checklist\n1. Bump version and build number\n2. Verify signing configuration\n3. Run smoke tests on release builds\n4. Upload metadata and screenshots\n5. Roll out gradually and watch crash metrics\n",
        pitfalls=[
            "Leaving signing, metadata, and policy checks until the final day creates release risk that code changes alone cannot fix.",
            "Treating store submission as a one-click step ignores review delays, rollout strategy, and post-release monitoring.",
        ],
        takeaways=[
            "Publishing includes signing, compliance, metadata, rollout, and monitoring, not just building the app.",
            "Release discipline is much easier when CI/CD and environment setup are already reliable.",
            "Plan for verification after launch, because a successful upload is not the end of the release process.",
        ],
        example_language="text",
        section_code=None,
    ),
    ("swift", "variables_constants_type_inference"): topic(
        summary="Swift declarations are about mutability and type clarity: `let` creates an immutable binding, `var` allows reassignment, and type inference keeps code concise when the assigned value already makes the type obvious.",
        detail_one="Use `let` by default because immutable values are easier to reason about and safer in concurrent code. Add explicit types when the initializer hides intent, when public APIs need to communicate contracts clearly, or when inference would choose a more general type than you want.",
        detail_two="Swift's compiler is strong enough to infer many types, but readable code still matters. Interviewers usually care that you can explain when inference helps and when explicit types make refactors or cross-file understanding easier.",
        practice="In app code, immutable view models, configuration values, and dependency references reduce accidental state changes. Reaching for `var` only when mutation is real keeps code intent visible.",
        example_code="let apiHost = \"api.example.com\"\nvar retryCount = 0\nlet supportedLocales: [String] = [\"en\", \"it\"]\n\nretryCount += 1\nprint(apiHost, retryCount, supportedLocales)\n",
        pitfalls=[
            "Using `var` everywhere hides whether a value is expected to change and makes reasoning about state harder.",
            "Relying on inference when the chosen type is subtle can create confusing APIs and brittle refactors.",
        ],
        takeaways=[
            "Use `let` by default and choose `var` only for values that must actually change.",
            "Type inference is great when it improves readability, not when it makes contracts implicit.",
            "Clear mutability and type intent are part of good Swift design, not just syntax preferences.",
        ],
    ),
    ("swift", "optionals"): topic(
        summary="Optionals model absence explicitly. `String?` means a value may be missing, so Swift forces you to unwrap it before use instead of letting nil-related bugs hide until runtime.",
        detail_one="Optional binding with `if let` or `guard let` is the most common safe path because it narrows the type from optional to non-optional after the check. Optional chaining and nil coalescing help when you want to keep the code compact while still handling missing values deliberately.",
        detail_two="Forced unwrapping with `!` is only safe when some earlier invariant already guarantees the value exists. Overuse of `!` or implicitly unwrapped optionals usually means the design is pushing uncertainty somewhere the compiler can no longer protect you.",
        practice="In iOS code, optionals appear around network data, outlets, navigation arguments, and lookup operations. Strong answers explain how the API communicates missing state instead of rushing to force-unwrap values to silence the compiler.",
        example_code="func displayName(for nickname: String?) -> String {\n    guard let nickname, !nickname.isEmpty else {\n        return \"Anonymous\"\n    }\n    return nickname\n}\n\nprint(displayName(for: nil))\n",
        pitfalls=[
            "Using `!` as a habit turns a compile-time safety feature back into a runtime crash source.",
            "Modeling required data as optional makes business logic noisy and usually signals an API boundary that is too vague.",
        ],
        takeaways=[
            "Optionals represent uncertainty explicitly so code must handle absence on purpose.",
            "Prefer safe unwrapping and better API design over forced unwrapping.",
            "A clear optional contract makes app state and failure cases easier to reason about.",
        ],
    ),
    ("swift", "functions_closures"): topic(
        summary="Functions and closures shape how behavior is composed in Swift. Their signatures affect readability, testability, and how much hidden state a piece of logic relies on.",
        detail_one="Swift function features like argument labels, default values, trailing closures, and `@escaping` exist to make call sites expressive. The best APIs read almost like prose while still making ownership and asynchronous behavior obvious.",
        detail_two="Closures capture surrounding state, which is powerful for callbacks but also the root of many memory and lifecycle mistakes. `@autoclosure` and escaping closures are useful tools, but they should only appear when they truly improve the API contract.",
        practice="In SwiftUI and UIKit code, closures power event handlers, completion callbacks, async wrappers, and collection transforms. Keeping closure behavior explicit is often the difference between elegant code and logic that is hard to debug.",
        example_code="func loadTitle(prefix: String = \"Hello\", body: () -> String) -> String {\n    return \"\\(prefix), \\(body())\"\n}\n\nlet title = loadTitle {\n    \"Mila\"\n}\n\nprint(title)\n",
        pitfalls=[
            "Closures that capture `self` strongly by default are a common source of retain cycles and hidden coupling.",
            "Overusing advanced closure features can make everyday APIs harder to read than a plain function or value type would.",
        ],
        takeaways=[
            "Design function signatures so call sites communicate intent clearly.",
            "Treat closure capture and escaping behavior as ownership decisions, not just syntax details.",
            "Prefer small, explicit functions over clever APIs that hide control flow.",
        ],
    ),
    ("swift", "control_flow"): topic(
        summary="Control flow in Swift is about expressing states and guard conditions clearly. `if`, `guard`, loops, and pattern-matching `switch` are at their best when they reveal intent instead of burying it.",
        detail_one="`guard` is especially important in Swift because it keeps the happy path flat by handling invalid conditions early. `switch` is powerful because pattern matching can destructure enums, ranges, tuples, and associated values in a way that documents the valid cases.",
        detail_two="The best control flow usually mirrors the domain model. When branching feels tangled, the underlying state representation is often the real issue, not the syntax you chose to write it.",
        practice="UI and networking code constantly branches on loading, error, permission, and empty states. Strong Swift answers explain how guard clauses and enums make those branches explicit and maintainable.",
        example_code="func statusLabel(for score: Int) -> String {\n    switch score {\n    case 90...:\n        return \"excellent\"\n    case 70..<90:\n        return \"good\"\n    case 50..<70:\n        return \"ok\"\n    default:\n        return \"needs work\"\n    }\n}\n",
        pitfalls=[
            "Deep nesting makes it hard to see the valid states and turns simple logic into a debugging exercise.",
            "Using booleans and magic values instead of explicit state models often creates harder control flow than necessary.",
        ],
        takeaways=[
            "Use `guard` and clear branching to keep the happy path readable.",
            "Pattern matching in `switch` is most valuable when the domain model itself is explicit.",
            "Messy control flow often points to a weak state model rather than a missing language feature.",
        ],
    ),
    ("swift", "collections"): topic(
        summary="Swift collections are the default way to model and transform in-memory data, so understanding Array, Set, Dictionary, and higher-order functions pays off in almost every feature.",
        detail_one="Choose a collection by the guarantee you need: order, uniqueness, or keyed lookup. Value semantics matter here because copying and mutation behavior are part of the correctness story, not just an implementation detail.",
        detail_two="Methods like `map`, `filter`, `compactMap`, and `reduce` let you express transformations declaratively. They are most useful when each step in the pipeline does one clear thing and the types still tell a readable story.",
        practice="A lot of view-model work is simply turning raw domain data into what the UI needs. Clean collection pipelines make that transformation obvious and keep mutation localized.",
        example_code="let users = [\n    [\"name\": \"Ari\", \"active\": true],\n    [\"name\": \"Mila\", \"active\": false],\n    [\"name\": \"Noah\", \"active\": true]\n]\n\nlet activeNames = users\n    .filter { $0[\"active\"] as? Bool == true }\n    .compactMap { $0[\"name\"] as? String }\n\nprint(activeNames)\n",
        pitfalls=[
            "Choosing the wrong collection type can hide performance or correctness problems until the code grows.",
            "Long chains of higher-order functions become unreadable when each step is not clearly named or scoped.",
        ],
        takeaways=[
            "Pick collections based on order, uniqueness, and lookup needs.",
            "Use higher-order functions to make transformations explicit, not just shorter.",
            "Collection design is part of domain modeling, not a minor implementation choice.",
        ],
    ),
    ("swift", "oop"): topic(
        summary="Swift supports classes, structs, enums, protocols, and extensions because different problems need different modeling tools, not because everything should be an object hierarchy.",
        detail_one="Swift is especially strong at protocol-oriented design: protocols define capabilities, structs model independent values, and classes remain useful when identity or shared mutable state is genuinely required. Enums with associated values often model finite state more clearly than inheritance trees.",
        detail_two="Extensions let you organize behavior around a type without modifying the original declaration's main body. The language gives you many abstraction tools, so the key skill is choosing the smallest one that makes the model clearer.",
        practice="Strong answers explain why protocol composition and value types often beat classical inheritance in Swift. The point is not to reject OOP, but to use classes only where reference identity solves a real problem.",
        example_code="protocol Searchable {\n    var queryText: String { get }\n}\n\nstruct SearchRequest: Searchable {\n    let queryText: String\n}\n",
        pitfalls=[
            "Forcing every model into a class hierarchy ignores Swift's stronger tools for value modeling and finite state.",
            "Using protocols or extensions everywhere without a clear capability boundary can make the design feel fragmented.",
        ],
        takeaways=[
            "Swift gives you multiple abstraction tools, so choose the one that matches the real behavior and ownership model.",
            "Protocols and value types often produce simpler, safer designs than deep inheritance.",
            "Good modeling starts with the domain, not with loyalty to one paradigm label.",
        ],
    ),
    ("swift", "value_types_vs_reference_types"): topic(
        summary="The difference between value and reference types is really the difference between copying state and sharing identity.",
        detail_one="Structs, enums, and tuples are value types: assigning them creates an independent copy. Classes are reference types: multiple variables can point to the same instance, which is useful for identity and coordination but riskier when mutation is shared.",
        detail_two="Swift's value types are powerful because copy-on-write optimizations make them efficient in many real workloads. That means 'structs are slow because they copy' is usually the wrong mental model and a poor interview answer.",
        practice="Use value types for independent data models and view state, then move to classes when you truly need shared identity, inheritance, or coordinated mutation. That trade-off becomes even more important with concurrency.",
        example_code="struct Counter {\n    var value = 0\n}\n\nvar first = Counter()\nvar second = first\nsecond.value = 10\n\nprint(first.value)   // 0\nprint(second.value)  // 10\n",
        pitfalls=[
            "Choosing classes by default creates shared mutable state that is harder to reason about and test.",
            "Assuming value types are always expensive ignores Swift's copy-on-write optimizations and the clarity benefits of independent copies.",
        ],
        takeaways=[
            "Value types copy state; reference types share identity.",
            "Prefer value semantics when independent state makes the model simpler and safer.",
            "Reach for classes when identity and coordinated mutation are essential, not by habit.",
        ],
    ),
    ("swift", "generics_associated_types"): topic(
        summary="Generics let Swift code stay reusable without giving up type safety, while associated types allow protocols to describe placeholder types that conformers decide later.",
        detail_one="A generic function or type is useful when the algorithm stays the same but the concrete type should vary. Associated types are different: they let a protocol describe relationships between types, which is why they are common in collection and sequence-style abstractions.",
        detail_two="The cost of generic power is API complexity. When signatures become hard to read, you may need type erasure, a simpler protocol boundary, or a more concrete abstraction that communicates intent better.",
        practice="In interview answers, focus on what generics buy you: compile-time safety, reusable behavior, and fewer casts. Then explain when the abstraction becomes so clever that a concrete type would actually be easier for the team to maintain.",
        example_code="protocol Repository {\n    associatedtype Item\n    func fetchAll() async throws -> [Item]\n}\n\nstruct UserRepository: Repository {\n    func fetchAll() async throws -> [User] { [] }\n}\n",
        pitfalls=[
            "Over-generalizing too early makes APIs harder to understand than a bit of well-placed duplication.",
            "Ignoring associated type constraints can leave protocols too vague to be used meaningfully.",
        ],
        takeaways=[
            "Use generics when behavior is stable but concrete types should vary safely.",
            "Associated types let protocols describe type relationships that ordinary inheritance cannot express well.",
            "Readable generic APIs are more valuable than maximal abstraction.",
        ],
    ),
    ("swift", "error_handling"): topic(
        summary="Swift error handling is about deciding when failures should be explicit in the type system, when they should be thrown, and how much context callers need to respond well.",
        detail_one="Throwing functions work well when failure is exceptional relative to the happy path and the caller can handle it higher up. `Result` is useful when success and failure should both travel as values, especially in APIs that compose asynchronous work or legacy callbacks.",
        detail_two="Well-designed error types carry domain meaning instead of leaking raw infrastructure details. The best place to translate low-level errors is usually the boundary where they become meaningful to the rest of the app.",
        practice="In app code, networking, file access, and decoding often throw lower-level errors that repositories or use cases then map into app-level failures. That keeps the UI focused on retry, empty, unauthorized, or unavailable states instead of transport trivia.",
        example_code="enum LoginError: Error {\n    case invalidCredentials\n    case offline\n}\n\nfunc login(email: String) throws {\n    guard email.contains(\"@\") else {\n        throw LoginError.invalidCredentials\n    }\n}\n",
        pitfalls=[
            "Throwing generic errors or strings makes recovery logic weak and logs less useful.",
            "Catching errors too low or too high in the stack can both hide the place where real meaning should be added.",
        ],
        takeaways=[
            "Use Swift's error tools to make failure modes explicit and meaningful.",
            "Translate low-level failures into domain-level decisions at the right boundary.",
            "Choose between `throws` and `Result` based on how explicitly callers should handle both paths.",
        ],
    ),
    ("swift", "concurrency"): topic(
        summary="Swift concurrency gives you language-level tools to run asynchronous work safely: `async/await` for readability, tasks and groups for coordination, actors for isolation, and `MainActor` for UI correctness.",
        detail_one="Structured concurrency is the big idea. Child tasks belong to a parent task, so cancellation and lifetime are explicit instead of spreading through ad hoc callback chains. `TaskGroup` handles parallel subtasks while still keeping ownership visible.",
        detail_two="Actors protect mutable state by serializing access, and `Sendable` helps the compiler verify what can cross concurrency domains safely. `MainActor` matters because UI updates still need to happen on the main thread even when the data work happens elsewhere.",
        practice="Strong answers distinguish waiting from parallel work, explain why unstructured tasks should be used carefully, and mention cancellation. In app code, stale updates and actor-hopping confusion are common if lifecycle and ownership are fuzzy.",
        example_code="actor ImageCache {\n    private var storage: [URL: Data] = [:]\n\n    func value(for url: URL) -> Data? {\n        storage[url]\n    }\n\n    func insert(_ data: Data, for url: URL) {\n        storage[url] = data\n    }\n}\n",
        pitfalls=[
            "Creating detached or unstructured tasks casually can make ownership, cancellation, and error propagation hard to reason about.",
            "Ignoring actor isolation and `MainActor` rules leads to race conditions or invalid UI updates despite using modern syntax.",
        ],
        takeaways=[
            "Swift concurrency is about structured ownership of asynchronous work, not just nicer syntax.",
            "Actors and `Sendable` make shared mutable state safer across concurrency domains.",
            "UI code still needs `MainActor` discipline even when data work moves off the main thread.",
        ],
    ),
    ("swift", "memory_management"): topic(
        summary="Swift uses ARC to keep objects alive as long as strong references exist, which means memory management is mostly an ownership design problem rather than a manual retain-release problem.",
        detail_one="Strong references keep objects alive, weak references avoid ownership cycles when the value may disappear, and unowned references are for relationships where the value should outlive the holder. Capture lists matter because closures are just another place where ownership can become cyclic.",
        detail_two="Retain cycles often appear in view models, delegates, timers, and callback-heavy code. The fix is not always 'use weak everywhere'; it is to model which object truly owns which other object and how long each reference should survive.",
        practice="A good interview answer explains ARC in terms of lifetime graphs. Memory bugs are usually architecture bugs in disguise, where ownership was never made explicit and the runtime did exactly what the references told it to do.",
        example_code="final class Loader {\n    var onFinish: (() -> Void)?\n\n    func start() {\n        onFinish = { [weak self] in\n            print(self != nil)\n        }\n    }\n}\n",
        pitfalls=[
            "Using strong captures by default in long-lived closures is a common way to leak view models and controllers.",
            "Sprinkling `weak` everywhere without understanding ownership can hide logic errors and make objects disappear unexpectedly.",
        ],
        takeaways=[
            "ARC manages object lifetime based on ownership relationships you model in code.",
            "Weak and unowned references are tools for expressing those relationships, not generic performance tweaks.",
            "Most retain cycles come from hidden ownership in closures, delegates, or bidirectional object graphs.",
        ],
    ),
    ("swift", "property_wrappers"): topic(
        summary="Property wrappers package repeated storage behavior behind a clean declaration syntax, which is why SwiftUI uses them so heavily for state and bindings.",
        detail_one="A property wrapper defines how a value is stored and exposed, while projected values like `$name` can provide extra capabilities such as bindings. `@State`, `@Binding`, `@ObservedObject`, and custom wrappers all rely on this idea.",
        detail_two="The key is to understand what the wrapper owns and what it merely exposes. For example, `@State` stores local view state, while `@Binding` is a reference-like projection into state owned elsewhere.",
        practice="In interviews, explain wrappers as a way to separate declaration from storage behavior. That is more robust than memorizing which wrapper 'works' in which scenario without knowing why.",
        example_code="@propertyWrapper\nstruct Clamped {\n    private var value: Int\n    let range: ClosedRange<Int>\n\n    init(wrappedValue: Int, _ range: ClosedRange<Int>) {\n        self.range = range\n        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)\n    }\n\n    var wrappedValue: Int {\n        get { value }\n        set { value = min(max(newValue, range.lowerBound), range.upperBound) }\n    }\n}\n",
        pitfalls=[
            "Using wrappers without understanding ownership can create confusing state bugs, especially in SwiftUI.",
            "Turning every repeated pattern into a custom wrapper can hide behavior better expressed by a plain type or function.",
        ],
        takeaways=[
            "Property wrappers attach reusable storage behavior to normal-looking declarations.",
            "Understand what each wrapper owns, exposes, or derives before using it in SwiftUI.",
            "A wrapper is helpful when it clarifies repeated behavior, not when it hides simple logic.",
        ],
    ),
    ("swift", "macros"): topic(
        summary="Swift macros generate code at compile time so you can remove boilerplate while still keeping the generated result type-checked and visible to the compiler.",
        detail_one="Attached macros annotate existing declarations, while freestanding macros expand into code from a call site. The important mental model is that macros are source transformations performed by the compiler, not runtime metaprogramming.",
        detail_two="Macros are powerful because they can enforce patterns consistently, but they also add indirection. Teams need to know what code is being generated and whether the abstraction is clearer than the boilerplate it replaces.",
        practice="A strong answer compares macros to older tools such as code generation scripts or reflection-heavy designs. The point is to explain when compile-time generation makes APIs more maintainable rather than simply more magical.",
        example_code="@Observable\nfinal class SessionStore {\n    var username = \"\"\n    var isLoggedIn = false\n}\n",
        pitfalls=[
            "Using macros to hide ordinary logic can make code harder to search and understand than the explicit version.",
            "Depending on generated behavior without understanding the expansion weakens debugging and code review.",
        ],
        takeaways=[
            "Macros perform compile-time code generation, not runtime reflection tricks.",
            "They are best used to remove repetitive patterns while preserving readability and compiler guarantees.",
            "Generated code still needs to be understood by the team that will maintain it.",
        ],
    ),
    ("swift", "opaque_types_some_keyword"): topic(
        summary="Opaque types let a function promise the capabilities of a returned value without exposing the exact concrete type behind it.",
        detail_one="`some Protocol` means the caller gets one concrete hidden type chosen by the implementation. That is different from an existential like `any Protocol`, where the value may be any conforming type and dynamic dispatch or boxing trade-offs apply.",
        detail_two="SwiftUI relies heavily on opaque types because view builders return large concrete compositions that callers do not need to know. The hidden concrete type still matters to the compiler for optimization and type checking.",
        practice="In interviews, contrast opaque types with protocols as values. The strongest answer explains what is hidden, what stays guaranteed, and why `some View` is more efficient and expressive than exposing giant view types directly.",
        example_code="func makeTitle() -> some View {\n    Text(\"Profile\")\n        .font(.title)\n        .bold()\n}\n",
        pitfalls=[
            "Confusing `some Protocol` with `any Protocol` leads to weak explanations about flexibility and performance.",
            "Opaque return types are awkward when branches must return different concrete types and no builder or erasure is involved.",
        ],
        takeaways=[
            "Opaque types hide the concrete return type while preserving one consistent underlying implementation.",
            "They differ from existentials because the compiler still knows the concrete type behind the scenes.",
            "SwiftUI uses `some View` to keep APIs clean without giving up static type information.",
        ],
    ),
    ("swift", "swift_5_9_features"): topic(
        summary="Recent Swift releases add features like if or switch expressions and ownership-related keywords because the language keeps moving toward clearer intent with fewer accidental copies or boilerplate.",
        detail_one="If and switch expressions reduce temporary variables by letting control flow produce values directly. Ownership ideas such as consuming or borrowing are about making data movement and mutation intent more explicit so the compiler can enforce and optimize it.",
        detail_two="These features matter because they shape API design and performance thinking, especially in generic and systems-level code. The practical interview skill is explaining what new clarity or safety each feature provides, not just reciting syntax.",
        practice="Use newer language features where they genuinely improve readability or ownership guarantees. Teams get the most value when they adopt new tools intentionally rather than trying to rewrite every old pattern immediately.",
        example_code="let status = if isPremium {\n    \"priority\"\n} else {\n    \"standard\"\n}\n\nprint(status)\n",
        pitfalls=[
            "Adopting new syntax everywhere at once can make code feel like a feature showcase instead of a maintainable product.",
            "Talking about ownership features without understanding the lifetime problem they solve leads to shallow interview answers.",
        ],
        takeaways=[
            "New Swift features are most valuable when they clarify intent or make ownership safer.",
            "If and switch expressions improve readability when they replace obvious temporary variables.",
            "Language evolution matters because it changes how APIs communicate cost and guarantees.",
        ],
    ),
    ("swift", "view_protocol_view_lifecycle"): topic(
        summary="SwiftUI views are lightweight value descriptions of UI, while lifecycle behavior emerges from state changes and the framework's diffing process rather than from long-lived view objects.",
        detail_one="A `View`'s `body` is recalculated whenever relevant state changes, so the struct itself is not the stateful object you should imagine persisting. That is why stored mutable state belongs in wrappers like `@State`, observable models, or external owners instead of ordinary properties.",
        detail_two="Lifecycle hooks like `onAppear`, `onDisappear`, and task modifiers are useful, but they should be treated as effects attached to view identity, not as one-time constructors. Structural identity and data flow determine when those effects rerun.",
        practice="A good answer compares SwiftUI's value-based rendering model with UIKit's object lifecycle. Once you understand that difference, repeated body evaluation stops feeling scary and state ownership decisions become more deliberate.",
        example_code="struct GreetingView: View {\n    @State private var count = 0\n\n    var body: some View {\n        Button(\"Tapped \\(count) times\") {\n            count += 1\n        }\n    }\n}\n",
        pitfalls=[
            "Assuming a SwiftUI view struct behaves like a long-lived controller leads to misplaced state and surprising lifecycle behavior.",
            "Running side effects from `body` instead of lifecycle-aware modifiers can cause repeated work and bugs.",
        ],
        takeaways=[
            "SwiftUI views are value descriptions; state lives in dedicated wrappers or models.",
            "View lifecycle in SwiftUI is tied to identity and state, not to persistent view objects.",
            "Understanding the rendering model makes repeated body evaluation feel normal instead of alarming.",
        ],
    ),
    ("swift", "modifiers"): topic(
        summary="SwiftUI modifiers transform view values, so their order matters because each modifier wraps the previous result and changes what later modifiers are applied to.",
        detail_one="That composition model explains common surprises: padding before background differs from background before padding, and gesture or accessibility modifiers attach to the view produced so far, not to some abstract original view.",
        detail_two="Custom modifiers are useful when a styling or behavior pattern repeats, but they work best when they package one coherent concern. If a modifier hides too much business logic, it stops being a styling tool and starts becoming a mysterious abstraction.",
        practice="In interviews, explain modifiers as value composition rather than 'chainable methods'. That mental model helps you reason about visual results, hit-testing, accessibility, and reusable UI conventions.",
        example_code="Text(\"New\")\n    .padding(8)\n    .background(Color.blue)\n    .foregroundStyle(.white)\n    .clipShape(Capsule())\n",
        pitfalls=[
            "Ignoring modifier order leads to confusing layout, gesture, and styling bugs that feel random until you understand the wrapping model.",
            "Packing unrelated concerns into one custom modifier can make UI behavior harder to inspect and test.",
        ],
        takeaways=[
            "Modifiers wrap and transform views, so order changes the result.",
            "Think in terms of composition, not mutable view objects being edited in place.",
            "Create custom modifiers when they package one repeated concern clearly.",
        ],
    ),
    ("swift", "layout_system"): topic(
        summary="SwiftUI layout is a proposal-response system: parents propose sizes, children choose sizes, and containers place them based on alignment and available space.",
        detail_one="Stacks, grids, lazy containers, and `ViewThatFits` are all ways of negotiating that size conversation. When a layout looks wrong, the fix usually comes from understanding the proposal and priority chain rather than randomly adding frames and spacers.",
        detail_two="Lazy containers matter for performance because they create views on demand, while views like `Grid` or `ViewThatFits` help express more structured or adaptive layouts. The right container depends on how much content is present and how it should adapt.",
        practice="A strong answer compares SwiftUI layout with Auto Layout or Flutter-style constraint reasoning only if it helps explain the current problem. The key is to show you can diagnose layout by the rules of the system you are actually using.",
        example_code="VStack(alignment: .leading, spacing: 12) {\n    Text(\"Inbox\")\n        .font(.title)\n    ViewThatFits {\n        HStack { Text(\"Wide layout\") }\n        VStack { Text(\"Compact layout\") }\n    }\n}\n",
        pitfalls=[
            "Stacking `frame`, `Spacer`, and fixed sizes without understanding the layout proposal often creates fragile screens.",
            "Using non-lazy containers for large data sets wastes work before the user can even see the content.",
        ],
        takeaways=[
            "SwiftUI layout is a negotiation of proposed size, chosen size, and placement.",
            "Choose containers based on content shape, adaptability, and rendering cost.",
            "Diagnose layout issues by understanding the proposal chain instead of guessing with extra modifiers.",
        ],
    ),
    ("swift", "state_management"): topic(
        summary="SwiftUI state management is about deciding who owns changing data and how changes should propagate through the view hierarchy.",
        detail_one="`@State` owns local value state, `@Binding` exposes a writable projection into state owned elsewhere, and object-based wrappers like `@StateObject`, `@ObservedObject`, and `@EnvironmentObject` coordinate reference-type models across view boundaries.",
        detail_two="The wrapper choice reflects lifetime and ownership. If a view should create and own a model, `@StateObject` fits. If it receives a model from a parent, `@ObservedObject` is more appropriate. The best explanations connect wrapper choice to lifecycle rather than memorized rules.",
        practice="Good SwiftUI answers keep local UI state small and move shared or long-lived state into explicit models. Trouble usually starts when too many layers can mutate the same source without a clear ownership story.",
        example_code="struct CounterView: View {\n    @State private var count = 0\n\n    var body: some View {\n        Stepper(\"Count: \\(count)\", value: $count)\n    }\n}\n",
        pitfalls=[
            "Using the wrong wrapper often creates duplicate models, unexpected resets, or updates that never reach the view you expected.",
            "Shared mutable state without clear ownership becomes hard to test and hard to reason about quickly.",
        ],
        takeaways=[
            "Choose SwiftUI wrappers based on who owns the state and how long it should live.",
            "Keep local state local and lift shared behavior into explicit models when the scope justifies it.",
            "Wrapper choice is really an ownership and lifecycle decision, not just a syntax rule.",
        ],
    ),
    ("swift", "observation_framework"): topic(
        summary="The Observation framework modernizes SwiftUI data flow by making change tracking more fine-grained and more natural with ordinary Swift types.",
        detail_one="`@Observable` lets the compiler synthesize observation for a type, while `@Bindable` creates bindings into observable properties. Compared with the older `ObservableObject` model, the framework tracks property access more precisely and reduces boilerplate.",
        detail_two="The same ownership questions still apply. Observation makes updates more ergonomic, but it does not remove the need to decide who owns the model, how it is injected, or which parts of the UI should depend on which state.",
        practice="In interviews, frame Observation as an evolution of data flow mechanics, not a replacement for architecture. It helps SwiftUI express state changes more naturally, especially on modern OS targets, but clean ownership is still the foundation.",
        example_code="@Observable\nfinal class SettingsStore {\n    var notificationsEnabled = true\n    var username = \"Elbek\"\n}\n",
        pitfalls=[
            "Switching to the new framework without revisiting ownership and injection can preserve the same architecture problems with newer syntax.",
            "Treating `@Observable` types as global mutable state makes the app easy to wire but harder to test and reason about.",
        ],
        takeaways=[
            "Observation reduces boilerplate and tracks state more precisely in SwiftUI.",
            "It improves update mechanics, but ownership and architecture decisions still matter just as much.",
            "Use `@Bindable` and observable models where bindings genuinely make the UI simpler and clearer.",
        ],
    ),
    ("swift", "navigation"): topic(
        summary="SwiftUI navigation is state-driven. `NavigationStack`, `NavigationPath`, and related APIs work best when the navigation model is treated as data instead of scattered push logic.",
        detail_one="`NavigationStack` handles hierarchical flows, `NavigationSplitView` supports larger-screen master-detail layouts, and `navigationDestination` maps values to destinations declaratively. `NavigationPath` becomes useful when the route stack itself needs to be stored or reconstructed.",
        detail_two="The main design question is what should be encoded in navigation state versus view-local transient actions. Deep linking, restoration, and multi-column layouts become much easier when route data is explicit instead of hidden in button callbacks.",
        practice="Strong answers compare SwiftUI's approach with UIKit's imperative push model and explain why value-driven navigation is easier to restore, test, and adapt across screen sizes.",
        example_code="NavigationStack {\n    List(products) { product in\n        NavigationLink(value: product) {\n            Text(product.name)\n        }\n    }\n    .navigationDestination(for: Product.self) { product in\n        ProductDetailView(product: product)\n    }\n}\n",
        pitfalls=[
            "Mixing local booleans, selection state, and ad hoc paths without a clear route model creates confusing back navigation.",
            "Treating navigation as side effects instead of state makes deep linking and restoration harder later.",
        ],
        takeaways=[
            "Model navigation as data so the UI can derive destinations declaratively.",
            "Choose stack, split, or path APIs based on flow complexity and restoration needs.",
            "Explicit route state pays off when deep links and larger-screen layouts enter the picture.",
        ],
    ),
    ("swift", "lists_grids"): topic(
        summary="Lists and grids are specialized containers for rendering structured collections of data with the right scrolling, identity, and performance behavior.",
        detail_one="`List` provides platform-style scrolling behavior, editing affordances, and accessibility conventions out of the box. `LazyVGrid` and `LazyHGrid` are better when the content is fundamentally grid-shaped rather than just a styled list.",
        detail_two="Identity is crucial. `ForEach` needs stable identifiers so SwiftUI can preserve the right rows during updates, animate correctly, and avoid state attaching to the wrong item.",
        practice="A good interview answer explains not just which container exists, but which one matches the interaction pattern and dataset size. Editing, selection, lazy rendering, and sectioning all influence the right choice.",
        example_code="List {\n    Section(\"Favorites\") {\n        ForEach(favorites) { item in\n            Text(item.name)\n        }\n    }\n}\n",
        pitfalls=[
            "Using unstable identifiers in `ForEach` causes subtle UI bugs because SwiftUI cannot preserve the right row identity.",
            "Choosing a grid for list-shaped content or vice versa often complicates interaction without improving the experience.",
        ],
        takeaways=[
            "Pick lists and grids based on the interaction model and visual structure of the data.",
            "Stable identity is essential for correct updates and animations.",
            "Lazy containers matter when the dataset or rendering cost is large enough to justify them.",
        ],
    ),
    ("swift", "forms_user_input"): topic(
        summary="User input is about transforming typing, taps, and selections into valid domain values while keeping the experience understandable and forgiving.",
        detail_one="SwiftUI offers controls like `TextField`, `Toggle`, `Picker`, and `DatePicker`, but the real design questions are validation timing, formatting, keyboard flow, and how raw input maps to the underlying model safely.",
        detail_two="Bindings make form wiring concise, yet complex forms still need clear ownership, validation strategy, and sometimes dedicated view models. Otherwise input logic spreads across modifiers and becomes difficult to test.",
        practice="The strongest answers cover both UX and code structure: where validation lives, how errors are shown, when submission is allowed, and how the form reacts to asynchronous backend responses.",
        example_code="@State private var email = \"\"\n\nTextField(\"Email\", text: $email)\n    .textInputAutocapitalization(.never)\n    .keyboardType(.emailAddress)\n",
        pitfalls=[
            "Pushing all validation into scattered view modifiers makes complex forms hard to test and maintain.",
            "Showing validation too aggressively can make input feel hostile even when the rules are correct.",
        ],
        takeaways=[
            "A good form balances validation, ownership, formatting, and user feedback.",
            "Bindings keep input concise, but larger forms still benefit from clear state and validation architecture.",
            "Form design should reduce user confusion, not merely reject invalid data.",
        ],
    ),
    ("swift", "sheets_alerts_confirmations_popovers"): topic(
        summary="Presentation modifiers such as sheets, alerts, confirmation dialogs, and popovers exist to show transient UI with different levels of context and interruption.",
        detail_one="The choice depends on the user's task. Alerts are for urgent acknowledgment, confirmation dialogs for choosing among actions, sheets for contained flows, and popovers for contextual detail where the platform supports them comfortably.",
        detail_two="In SwiftUI these presentations are usually driven by state, which means dismissal and presentation logic should have a clear owner. That makes testing and restoration cleaner than sprinkling presentation calls throughout the code.",
        practice="A strong answer treats presentation as part of interaction design, not just an API to memorize. You should be able to explain why interrupting the user is justified or why a richer flow deserves its own sheet.",
        example_code="@State private var showDeleteDialog = false\n\nButton(\"Delete\") {\n    showDeleteDialog = true\n}\n.confirmationDialog(\"Delete item?\", isPresented: $showDeleteDialog) {\n    Button(\"Delete\", role: .destructive) {}\n}\n",
        pitfalls=[
            "Using alerts and sheets interchangeably often produces awkward UX because they carry very different expectations.",
            "Presentation state with no clear owner quickly turns into conflicting booleans and impossible states.",
        ],
        takeaways=[
            "Choose the presentation style based on the amount of context and interruption the task deserves.",
            "Drive transient presentations from explicit state instead of scattered imperative calls.",
            "Good UX matters as much as API familiarity when explaining presentation choices.",
        ],
    ),
    ("swift", "animations_transitions"): topic(
        summary="Animation and transition APIs in SwiftUI help motion communicate change, continuity, and focus rather than merely adding decoration.",
        detail_one="`withAnimation` animates state changes, transitions describe how views enter and leave, and tools like `matchedGeometryEffect`, `PhaseAnimator`, and `KeyframeAnimator` support more choreographed motion. The important question is what state change the motion is trying to explain.",
        detail_two="Because animations are state-driven, view identity still matters. If identity changes unexpectedly, a carefully designed transition may disappear because SwiftUI thinks it is looking at a completely different view tree.",
        practice="Interview answers are strongest when they mention meaning and performance together. Motion should help users track change and should respect accessibility preferences such as reduced motion where relevant.",
        example_code="@State private var isExpanded = false\n\nRoundedRectangle(cornerRadius: 24)\n    .frame(width: isExpanded ? 220 : 120, height: 120)\n    .animation(.spring(response: 0.35), value: isExpanded)\n",
        pitfalls=[
            "Adding motion without a product reason makes the UI busier without making it clearer.",
            "Ignoring view identity and state ownership often leads to animations that behave inconsistently or not at all.",
        ],
        takeaways=[
            "Animation should clarify change, hierarchy, or causality for the user.",
            "State-driven motion still depends on stable identity and deliberate ownership.",
            "Choose the simplest animation API that communicates the effect you actually need.",
        ],
    ),
    ("swift", "drawing"): topic(
        summary="Drawing APIs like `Shape`, `Path`, and `Canvas` let you create visuals that standard views cannot express cleanly, while still fitting into SwiftUI's layout and state system.",
        detail_one="Custom shapes are great when the geometry can be described declaratively, while `Canvas` is useful for more advanced or performance-sensitive drawing. The trade-off is that lower-level drawing pushes more visual responsibility onto your code instead of reusable system components.",
        detail_two="As with other low-level tools, the question is when the visual requirement truly justifies the complexity. Custom drawing is valuable for charts, masks, and branded visuals, but it is usually unnecessary for ordinary layout or decoration.",
        practice="A strong answer contrasts drawing primitives with standard composition. That shows you know drawing is an intentional escape hatch, not a default way to build UI.",
        example_code="struct Triangle: Shape {\n    func path(in rect: CGRect) -> Path {\n        Path { path in\n            path.move(to: CGPoint(x: rect.midX, y: rect.minY))\n            path.addLines([\n                CGPoint(x: rect.maxX, y: rect.maxY),\n                CGPoint(x: rect.minX, y: rect.maxY)\n            ])\n            path.closeSubpath()\n        }\n    }\n}\n",
        pitfalls=[
            "Rebuilding custom drawing for visuals that standard views already handle adds complexity with little benefit.",
            "Forgetting that drawing still participates in layout can lead to surprising clipping or sizing behavior.",
        ],
        takeaways=[
            "Use drawing APIs when the visual requirement goes beyond normal view composition.",
            "Custom drawing is powerful but should be justified by a real need such as charts or brand-specific shapes.",
            "Keep layout and rendering responsibilities clear even when working at a lower visual level.",
        ],
    ),
    ("swift", "gestures"): topic(
        summary="Gestures turn raw touch input into semantic interactions such as tapping, dragging, pinching, or sequencing multiple actions together.",
        detail_one="SwiftUI gesture APIs let you compose simultaneous, high-priority, and sequenced gestures, which matters because many interactions compete for the same touches. The design question is which gesture should win and how feedback should guide the user.",
        detail_two="Gesture state is often transient, so it pairs naturally with local view state. More complex gestures still need clear ownership and may need to coordinate with scroll views, accessibility, or UIKit interoperability.",
        practice="A good answer mentions interaction conflict, not just the names of gesture types. Real products often care about whether a drag should start immediately, whether a tap still fires after a drag, and how the experience feels for users with assistive technologies.",
        example_code="Circle()\n    .gesture(\n        DragGesture()\n            .onChanged { value in\n                print(value.translation)\n            }\n    )\n",
        pitfalls=[
            "Composing gestures without a clear priority model can create interactions that feel inconsistent or broken.",
            "Ignoring accessibility and scroll-view coordination can make a custom gesture work in isolation but fail in the real screen.",
        ],
        takeaways=[
            "Think of gestures as interaction design decisions, not just input callbacks.",
            "Coordinate gesture priority and state carefully when multiple interactions compete.",
            "Transient gesture state belongs close to the view unless broader ownership is genuinely needed.",
        ],
    ),
    ("swift", "data_flow_architecture"): topic(
        summary="Data flow architecture defines where state lives, how it changes, and how views observe those changes without business logic dissolving into UI code.",
        detail_one="Patterns like MVVM or environment-driven composition are useful when they make responsibilities obvious: views render, view models or controllers prepare state, and services or repositories handle side effects. The pattern label matters less than the clarity of the boundaries.",
        detail_two="Preferences, environment values, and injected dependencies are all part of the data-flow story because they determine what information is ambient and what must be passed explicitly. Good architecture balances convenience with visibility.",
        practice="The best interview answers follow a real feature from input to rendered output, calling out where data is transformed and who owns the side effects. That is far more convincing than reciting acronyms.",
        example_code="final class ProfileViewModel: ObservableObject {\n    @Published private(set) var username = \"\"\n    private let repository: ProfileRepository\n\n    init(repository: ProfileRepository) {\n        self.repository = repository\n    }\n}\n",
        pitfalls=[
            "Treating architecture as folder naming alone leaves ownership and data transformation problems unsolved.",
            "Ambient dependencies become hidden global state when too much information is pulled from the environment without clear rules.",
        ],
        takeaways=[
            "Architecture should make ownership, transformation, and side effects obvious.",
            "Pattern names matter less than whether the chosen boundaries reduce the cost of change.",
            "Trace one real feature end to end to evaluate whether the data flow is actually understandable.",
        ],
    ),
    ("swift", "swiftdata"): topic(
        summary="SwiftData is Apple's modern persistence layer that integrates model declaration, querying, and observation more directly with SwiftUI-style development.",
        detail_one="Models are expressed in Swift, queries can be driven from views, and the framework handles much of the object graph and persistence plumbing. That makes simple app storage more ergonomic, especially when observation and persistence should feel native to the same language model.",
        detail_two="The same persistence questions still matter: relationships, migrations, source-of-truth rules, and how much domain logic should depend on the persistence model directly. Convenience does not remove architecture trade-offs.",
        practice="A strong answer compares SwiftData with Core Data by ergonomics and platform maturity. SwiftData is attractive when you want modern Swift APIs, but you still need to plan for schema evolution and testability.",
        example_code="@Model\nfinal class Note {\n    var title: String\n    var createdAt: Date\n\n    init(title: String, createdAt: Date = .now) {\n        self.title = title\n        self.createdAt = createdAt\n    }\n}\n",
        pitfalls=[
            "Treating the persistence model as the entire domain model can couple business logic too tightly to storage details.",
            "Ignoring migration and relationship design because the API feels simple creates pain later when the app evolves.",
        ],
        takeaways=[
            "SwiftData modernizes persistence ergonomics, but schema and ownership design still matter.",
            "It works best when the convenience aligns with the app's complexity and platform targets.",
            "Persistence choices should still respect boundaries between storage concerns and domain behavior.",
        ],
    ),
    ("swift", "core_data"): topic(
        summary="Core Data is an object graph and persistence framework built to manage structured data, relationships, faulting, and change tracking efficiently on Apple platforms.",
        detail_one="Concepts like managed object contexts, fetch requests, predicates, and relationships matter because Core Data is more than a database wrapper. It tracks object identity, lazily loads data, and coordinates changes across contexts and stores.",
        detail_two="The complexity is worth it when the data model is rich, relational, and long-lived. The main design skill is deciding where Core Data types should be exposed and where repositories or mappers should shield the rest of the app from persistence details.",
        practice="In interviews, explain Core Data in terms of object graph management, context isolation, and migration strategy instead of reducing it to 'SQLite with extra steps'. That shows you understand why the framework exists.",
        example_code="let request = NSFetchRequest<TaskEntity>(entityName: \"TaskEntity\")\nrequest.predicate = NSPredicate(format: \"isDone == NO\")\nrequest.sortDescriptors = [NSSortDescriptor(key: \"createdAt\", ascending: false)]\n",
        pitfalls=[
            "Passing managed objects through every layer can make the app tightly coupled to persistence and tricky to test.",
            "Ignoring context boundaries and merge behavior often creates data races or stale UI in larger apps.",
        ],
        takeaways=[
            "Core Data manages object graphs, identity, and persistence together, not just storage bytes on disk.",
            "Context design and migration strategy are central to a healthy Core Data architecture.",
            "Shield the rest of the app from persistence-specific details when broader flexibility matters.",
        ],
    ),
    ("swift", "networking"): topic(
        summary="Networking in Swift should turn remote calls into predictable models and meaningful failures while respecting cancellation, decoding, and UI lifecycle.",
        detail_one="`URLSession` with async or await is the modern baseline, and `Codable` helps decode predictable payloads quickly. The important design work is deciding where request construction, response validation, decoding, and error translation should live.",
        detail_two="A good networking layer also thinks about idempotency, retries, auth refresh, and observability. The UI should not need to know whether a failure came from transport, decoding, or authorization unless that distinction is actually relevant to the user.",
        practice="In interviews, speak about repositories or clients that isolate transport concerns. Then connect the network design to cancellation and stale-response handling in the UI, which is where many real bugs surface.",
        example_code="struct Product: Decodable {\n    let id: Int\n    let name: String\n}\n\nfunc loadProducts() async throws -> [Product] {\n    let url = URL(string: \"https://example.com/products\")!\n    let (data, response) = try await URLSession.shared.data(from: url)\n    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {\n        throw URLError(.badServerResponse)\n    }\n    return try JSONDecoder().decode([Product].self, from: data)\n}\n",
        pitfalls=[
            "Decoding and error translation inside views or view models can mix transport concerns into presentation logic.",
            "Retrying or refreshing auth blindly without modeling request safety and user intent can make failures harder to debug.",
        ],
        takeaways=[
            "Keep transport, decoding, and app-level failure decisions in clear networking boundaries.",
            "Modern Swift networking is simpler with async/await, but lifecycle and cancellation still matter.",
            "The best API layer gives the UI meaningful models and actionable errors, not raw transport noise.",
        ],
    ),
    ("swift", "combine"): topic(
        summary="Combine is Apple's reactive framework for values over time, built around publishers, subscribers, and operators that transform asynchronous streams.",
        detail_one="The framework is still relevant because many production codebases use it, and because understanding publishers clarifies how state, side effects, and cancellation can be modeled declaratively. Operators like `map`, `debounce`, `merge`, and `combineLatest` let you express stream logic compactly once the mental model is clear.",
        detail_two="Even if new code uses Swift concurrency more often, Combine remains useful for legacy systems, event pipelines, and APIs that are naturally stream-based. The key interview skill is understanding the dataflow, not memorizing every operator.",
        practice="Strong answers compare Combine with async or await: one is about streams over time, the other about sequential asynchronous code. That distinction helps you explain when a publisher pipeline is still the right tool.",
        example_code="let subject = PassthroughSubject<String, Never>()\nlet cancellable = subject\n    .map { $0.uppercased() }\n    .sink { value in\n        print(value)\n    }\n\nsubject.send(\"hello\")\n",
        pitfalls=[
            "Large publisher chains become unreadable when each step does too much and no one names the intermediate intent.",
            "Keeping Combine in a codebase without understanding cancellation and ownership leads to leaks and stale subscriptions.",
        ],
        takeaways=[
            "Combine models streams of values over time with transformation and cancellation built in.",
            "It is still important for legacy code and naturally reactive workflows even in the async/await era.",
            "Readable reactive code depends on clear stream intent, not on chaining every operator you know.",
        ],
    ),
    ("swift", "app_intents_shortcuts"): topic(
        summary="App Intents expose app actions and entities to Siri, Spotlight, and Shortcuts so the system can invoke meaningful app capabilities outside the normal UI flow.",
        detail_one="The key idea is making app behavior discoverable and parameterized at the system level. An intent defines what the action does, what inputs it needs, and what result or dialog the system should present.",
        detail_two="This work is part API design and part product design. The best intents map to tasks users genuinely want to automate, not internal implementation details that happen to be easy to expose.",
        practice="In interviews, explain App Intents as a bridge between app capabilities and system automation. Mention entities, parameters, donation, and the need for stable, user-meaningful action semantics.",
        example_code="struct StartFocusSessionIntent: AppIntent {\n    static var title: LocalizedStringResource = \"Start Focus Session\"\n\n    func perform() async throws -> some IntentResult {\n        .result()\n    }\n}\n",
        pitfalls=[
            "Exposing actions that are too technical or too unstable makes the shortcuts hard for users to trust.",
            "Treating App Intents as a checkbox feature misses the product thinking needed for good automation flows.",
        ],
        takeaways=[
            "App Intents make app capabilities callable by system automation features.",
            "A useful intent represents a real user task with stable parameters and outcomes.",
            "Good Shortcut integration is as much about product semantics as API wiring.",
        ],
    ),
    ("swift", "widgetkit"): topic(
        summary="WidgetKit lets an app surface glanceable information in constrained system spaces like the Home Screen, Lock Screen, or Live Activities.",
        detail_one="Widgets are driven by timelines and snapshots rather than by a fully interactive app runtime. That means data access, refresh frequency, and layout constraints are all more limited than in the main app, and the content must still remain useful at a glance.",
        detail_two="Live Activities extend the concept by showing frequently updated task state, but they still require disciplined modeling of what information is important and how often it should change. Power and privacy constraints matter.",
        practice="Strong answers focus on choosing the right information density and update strategy. Widgets are successful when users can understand the state quickly, not when the app tries to replicate a full screen inside a tiny surface.",
        example_code="struct ScoreWidgetEntryView: View {\n    var entry: Provider.Entry\n\n    var body: some View {\n        VStack(alignment: .leading) {\n            Text(entry.teamName)\n            Text(entry.score)\n                .font(.title)\n        }\n    }\n}\n",
        pitfalls=[
            "Trying to recreate full app workflows inside widgets usually fights the platform's glanceable design model.",
            "Ignoring refresh limits and system constraints can produce stale or misleading widget content.",
        ],
        takeaways=[
            "Widgets succeed when they deliver glanceable value within strict system constraints.",
            "Timeline and update design are central, because widgets do not run like normal app screens.",
            "Choose information that is immediately useful, not merely available.",
        ],
    ),
    ("swift", "push_notifications"): topic(
        summary="Push notifications are a delivery system for timely events, but the real design work is deciding what deserves interruption and how the app should respond when a notification arrives.",
        detail_one="APNs handles transport, while `UserNotifications` defines categories, actions, and presentation behavior on the device. The app still needs clear rules for authorization prompts, deep linking, and what happens when the user taps or dismisses the notification.",
        detail_two="Good notification architecture separates registration, token handling, backend coordination, and user-facing behavior. It also respects that not every event deserves a push, because irrelevant notifications train users to turn the feature off.",
        practice="Interview answers should mention payload design, notification categories, and how notification handling fits into navigation and analytics. The product value matters as much as the API steps.",
        example_code="UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in\n    print(granted)\n}\n",
        pitfalls=[
            "Treating push notifications as a purely technical pipeline ignores permission timing and user trust.",
            "Wiring token registration without a clear payload and deep-linking strategy leads to notifications that open the wrong experience or none at all.",
        ],
        takeaways=[
            "Push notifications combine transport, permissions, deep linking, and product judgment.",
            "Only notify when the event is timely and valuable enough to interrupt the user.",
            "Design the app response path before you celebrate receiving the first device token.",
        ],
    ),
    ("swift", "keychain_security"): topic(
        summary="The Keychain stores sensitive credentials and secrets with stronger protection than ordinary app storage, but secure design still depends on what you store, how you access it, and when it should be available.",
        detail_one="Keychain items can have accessibility classes that define when they are readable, such as only when the device is unlocked. That matters because security is not just encryption at rest; it is about tying data access to the right device and session conditions.",
        detail_two="Security also means minimizing what the client stores at all. If a token can be short-lived or refreshed server-side, that is often better than storing more durable secrets on the device unnecessarily.",
        practice="A strong answer talks about threat models, secure storage boundaries, and how biometric prompts or access control improve the user flow without becoming security theater. The point is controlled access, not just 'use Keychain'.",
        example_code="let query: [String: Any] = [\n    kSecClass as String: kSecClassGenericPassword,\n    kSecAttrAccount as String: \"session-token\",\n    kSecValueData as String: Data(\"abc123\".utf8)\n]\nSecItemAdd(query as CFDictionary, nil)\n",
        pitfalls=[
            "Putting long-lived secrets in plain user defaults or files is a serious storage design mistake.",
            "Using the Keychain without choosing appropriate accessibility or rotation strategy can still leave the security story weak.",
        ],
        takeaways=[
            "Keychain is for sensitive values that need stronger storage guarantees than general app data.",
            "Secure storage decisions should reflect a real threat model and least-privilege mindset.",
            "Good security minimizes stored secrets and controls when protected values can be read.",
        ],
    ),
    ("swift", "accessibility"): topic(
        summary="Accessibility means designing the app so people with different vision, hearing, motor, or cognitive needs can complete tasks reliably and with dignity.",
        detail_one="On Apple platforms that includes VoiceOver labels and hints, Dynamic Type, contrast, focus order, semantic grouping, and making custom controls expose meaningful accessibility behavior. The API surface is broad because accessibility spans the whole interaction model.",
        detail_two="An accessible interface is usually a clearer interface for everyone. When labels are meaningful, touch targets are large enough, and content reflows gracefully at larger text sizes, the app becomes more resilient in general.",
        practice="In interviews, speak concretely about testing with VoiceOver and larger text rather than just mentioning modifiers. Accessibility work is strongest when it is part of the design conversation from the start.",
        example_code="Button(\"Delete\") {}\n    .accessibilityLabel(\"Delete draft\")\n    .accessibilityHint(\"Removes the unsent message\")\n",
        pitfalls=[
            "Adding labels to a fundamentally confusing flow does not make the experience truly accessible.",
            "Only testing at default font sizes and without assistive technologies leaves many real issues hidden.",
        ],
        takeaways=[
            "Accessibility is a product quality issue, not a small set of modifiers.",
            "VoiceOver, Dynamic Type, focus, contrast, and semantic structure all matter together.",
            "Testing with assistive tech is the fastest way to uncover problems teams otherwise miss.",
        ],
    ),
    ("swift", "localization"): topic(
        summary="Localization makes the app feel native across languages and regions by separating user-facing text and formatting rules from hard-coded assumptions in the UI.",
        detail_one="String Catalogs and locale-aware formatters help centralize translations, pluralization, and regional presentation rules. That matters because dates, numbers, names, currencies, and writing direction vary by locale, not just the words on a button.",
        detail_two="A localized app also needs flexible layout. Text can expand dramatically, right-to-left languages change alignment expectations, and images or symbols may carry different meaning across markets.",
        practice="A strong answer mentions avoiding string concatenation, designing for text expansion, and treating localization as an ongoing engineering discipline rather than a final translation pass.",
        example_code="Text(String(localized: \"profile.title\"))\nText(orderDate, format: .dateTime.year().month().day())\n",
        pitfalls=[
            "Concatenating fragments in code creates translation problems that are hard to fix cleanly later.",
            "Leaving localization until the final sprint usually reveals layout and formatting issues at the worst possible time.",
        ],
        takeaways=[
            "Localization is about language, formatting, layout, and cultural fit together.",
            "Use structured localization tools so content and formatting rules stay out of ad hoc string building.",
            "Design flexible layouts early so translated text and RTL support do not become expensive surprises.",
        ],
    ),
    ("swift", "testing"): topic(
        summary="Testing in Swift and iOS development is about putting confidence at the right layer so changes stay safe without slowing the team to a crawl.",
        detail_one="XCTest handles unit and integration-style tests, UI tests verify high-level flows, and previews can help catch layout or state problems during development. Each tool is most useful when it targets the kind of risk it can reveal efficiently.",
        detail_two="The test design question is where to place seams. Pure logic should be isolated and cheap to test, while platform-heavy code often benefits from focused adapters and a smaller number of end-to-end checks.",
        practice="The best interview answers mention determinism, speed, and user-visible behavior. A healthy test suite makes frequent changes less scary because regressions are caught by repeatable checks rather than memory alone.",
        example_code="func testPriceFormatterRoundsToTwoDecimals() {\n    let result = PriceFormatter.string(for: 12.345)\n    XCTAssertEqual(result, \"$12.35\")\n}\n",
        pitfalls=[
            "Tests that mirror implementation details too closely break during refactors without catching real regressions.",
            "Depending only on slow UI tests leaves too much behavior uncovered during normal development loops.",
        ],
        takeaways=[
            "Choose the test level based on the risk and the speed of feedback you need.",
            "Good seams in production code make testing simpler and more trustworthy.",
            "A sustainable test strategy balances fast logic checks with a smaller set of realistic integration flows.",
        ],
    ),
    ("swift", "performance"): topic(
        summary="Performance work in SwiftUI and iOS is about understanding identity, rendering cost, memory churn, and asynchronous work well enough to fix the real bottleneck instead of optimizing by superstition.",
        detail_one="Instruments helps you profile CPU, memory, allocations, leaks, and time spent in code paths. In SwiftUI, structural identity and view invalidation matter because the framework can only optimize well when the state and identity model are stable.",
        detail_two="Not every redraw or recomputation is bad. The key is whether expensive work is happening too often, too broadly, or on the wrong thread. Measuring tells you whether the issue is layout, rendering, I/O, memory, or algorithmic cost.",
        practice="Strong answers connect performance to user experience: smooth scrolling, fast launch, responsive interactions, and acceptable battery impact. Optimization decisions are easier to justify when you can point to measured user-facing pain.",
        example_code="struct FeedView: View {\n    let items: [FeedItem]\n\n    var body: some View {\n        List(items) { item in\n            FeedRow(item: item)\n        }\n    }\n}\n",
        pitfalls=[
            "Chasing micro-optimizations before measuring can make code uglier without fixing the user's actual problem.",
            "Ignoring identity and state boundaries in SwiftUI often causes broad invalidation work that feels mysterious until profiled.",
        ],
        takeaways=[
            "Profile first so you know what kind of work is actually expensive.",
            "SwiftUI performance depends heavily on stable identity and deliberate state boundaries.",
            "Optimize for user-visible responsiveness, not for abstract metrics detached from experience.",
        ],
    ),
    ("swift", "app_architecture"): topic(
        summary="App architecture is the set of boundaries that keep navigation, state, side effects, and domain logic understandable as the product grows.",
        detail_one="Patterns like MVC, MVVM, Coordinators, TCA, and Clean Architecture solve different coordination problems. The real evaluation criteria are clarity of ownership, cost of change, testability, and whether the pattern fits the team's complexity rather than a tutorial's idealized app.",
        detail_two="Coordinator-style approaches help when navigation and flow logic need dedicated ownership, while unidirectional architectures help when explicit action and state flow are the hardest problems. No single pattern is universally best because products and teams do not all fail in the same way.",
        practice="A strong answer maps one real feature through the chosen architecture and explains what became easier because of the boundary. That demonstrates judgment instead of pattern loyalty.",
        example_code="protocol AppRouter {\n    func showProfile(for userID: String)\n}\n\nfinal class ProfileCoordinator {\n    private let router: AppRouter\n\n    init(router: AppRouter) {\n        self.router = router\n    }\n}\n",
        pitfalls=[
            "Adopting an architecture for its reputation rather than for a concrete pain point often adds ceremony without clarity.",
            "A pattern name is not a design if state ownership and side-effect boundaries are still fuzzy.",
        ],
        takeaways=[
            "Architecture should make the app easier to change, test, and reason about.",
            "Choose patterns based on the complexity you actually have, not the complexity you imagine someday.",
            "Explain architecture through real feature flow rather than through acronyms alone.",
        ],
    ),
    ("swift", "uikit_interop"): topic(
        summary="UIKit interoperability matters because many apps mix SwiftUI with older screens, system controllers, or third-party SDKs that still expect UIKit entry points.",
        detail_one="`UIViewRepresentable` and `UIViewControllerRepresentable` let SwiftUI host UIKit views and controllers, while coordinators help bridge delegates, callbacks, and other imperative patterns back into state-driven SwiftUI code.",
        detail_two="The challenge is lifecycle translation. SwiftUI updates views by rebuilding value descriptions, while UIKit manages long-lived objects directly. Interop code needs to decide which side owns creation, updates, and cleanup.",
        practice="In interviews, talk about interop as boundary design. The goal is to keep the UIKit bridge thin, testable, and clearly responsible for translation instead of letting imperative patterns leak through the whole SwiftUI codebase.",
        example_code="struct ActivityView: UIViewControllerRepresentable {\n    let items: [Any]\n\n    func makeUIViewController(context: Context) -> UIActivityViewController {\n        UIActivityViewController(activityItems: items, applicationActivities: nil)\n    }\n\n    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}\n}\n",
        pitfalls=[
            "Letting UIKit delegate patterns leak unchecked into the whole SwiftUI layer creates confusing mixed paradigms.",
            "Ignoring ownership and update rules in representables can lead to stale state or repeated controller creation.",
        ],
        takeaways=[
            "Interop code is a translation layer between value-driven SwiftUI and object-driven UIKit.",
            "Keep bridges thin and explicit so the two UI models do not bleed into each other unnecessarily.",
            "Lifecycle ownership is the main complexity in representables, not the protocol conformance itself.",
        ],
    ),
    ("swift", "ci_cd"): topic(
        summary="CI/CD for iOS automates validation, signing, builds, and distribution so releases become repeatable instead of dependent on one laptop and a checklist in someone's head.",
        detail_one="Xcode Cloud, Fastlane, and GitHub Actions differ mostly in hosting model and integration ergonomics. The enduring concerns are secret management, code signing, test reliability, artifact storage, and keeping the pipeline fast enough that developers trust it.",
        detail_two="A strong pipeline runs linting and tests early, builds archives deterministically, signs with controlled credentials, and sends artifacts to the right audience such as internal QA or TestFlight. Release automation is only useful if the resulting process is safer than manual distribution.",
        practice="In interviews, explain CI/CD as staged automation: validate, build, sign, distribute, and monitor. That framing shows you understand both developer feedback loops and release operations.",
        example_code="lane :beta do\n  scan\n  build_app(scheme: \"InterviewPrep\")\n  upload_to_testflight\nend\n",
        pitfalls=[
            "Automating archives without solving signing and secret management simply moves the release bottleneck somewhere harder to debug.",
            "If pipelines are slow or flaky, the team stops trusting them and the automation loses its safety value.",
        ],
        takeaways=[
            "CI/CD should make releases both faster and safer through repeatable automation.",
            "Code signing and secret handling are central iOS pipeline concerns, not afterthoughts.",
            "A trustworthy pipeline gives quick validation feedback and reliable release artifacts.",
        ],
        example_language="ruby",
        section_code=None,
    ),
    ("swift", "app_store"): topic(
        summary="Shipping to the App Store is a release discipline that includes signing, metadata, review compliance, tester distribution, and monitoring after launch.",
        detail_one="App Store Connect, TestFlight, provisioning, certificates, privacy declarations, and review guidelines all affect whether a build can move from development to real users. The binary itself is only one part of the submission package.",
        detail_two="Good release teams plan for staged rollout, crash monitoring, and fallback options because approval is not the end of the job. Policy and operational readiness matter as much as the build succeeding locally.",
        practice="Strong answers frame App Store work as risk management: automate what can be automated, make environments explicit, and catch policy or metadata problems before the last possible minute.",
        example_code="Release flow\n1. Archive a release build with correct signing\n2. Upload to App Store Connect\n3. Distribute with TestFlight\n4. Validate metadata, privacy, and screenshots\n5. Roll out gradually and watch crash metrics\n",
        pitfalls=[
            "Leaving App Store metadata, privacy disclosures, and signing checks until release day creates avoidable launch risk.",
            "Treating TestFlight and monitoring as optional can hide problems until a public release is already live.",
        ],
        takeaways=[
            "App Store delivery includes operational and policy work, not just compiling the app.",
            "TestFlight, monitoring, and staged rollout reduce the risk of a public release.",
            "Release readiness improves when signing, metadata, and compliance are handled continuously, not at the last second.",
        ],
        example_language="text",
        section_code=None,
    ),
    ("general", "oop_principles"): topic(
        summary="Object-oriented principles are about bundling state and behavior so code models real responsibilities instead of turning the whole system into disconnected utility functions.",
        detail_one="Encapsulation protects invariants by controlling how state changes, inheritance shares behavior cautiously, polymorphism lets different implementations satisfy the same contract, and abstraction hides irrelevant detail behind a simpler interface.",
        detail_two="The main interview skill is understanding why these principles exist and where they stop helping. OOP is useful when objects have meaningful behavior and lifetimes, but forcing everything into classes can create more indirection than clarity.",
        practice="A good explanation uses a concrete example such as a payment processor or notification sender. Show how the design becomes easier to extend or test because each object owns a coherent responsibility.",
        example_code="interface PaymentMethod {\n  charge(amount: number): void;\n}\n\nclass CardPayment implements PaymentMethod {\n  charge(amount: number) {\n    console.log(`Charging ${amount} by card`);\n  }\n}\n",
        pitfalls=[
            "Using inheritance just to reuse code often creates brittle hierarchies that are harder to evolve than composition.",
            "Hiding all data and logic behind classes without clear responsibilities is not good OOP; it is just extra ceremony.",
        ],
        takeaways=[
            "OOP principles exist to organize responsibility, variation, and invariants around meaningful objects.",
            "Encapsulation and polymorphism are usually more valuable day to day than deep inheritance trees.",
            "A good OOP design makes change safer because responsibilities are explicit and narrow.",
        ],
        example_language="typescript",
    ),
    ("general", "solid_principles"): topic(
        summary="SOLID is a set of heuristics for making object-oriented code easier to change, test, and extend without accidental breakage.",
        detail_one="Single Responsibility keeps a type focused, Open/Closed encourages extension through new behavior rather than edits everywhere, Liskov warns that substitutions must preserve expectations, Interface Segregation prefers small targeted contracts, and Dependency Inversion keeps high-level policy away from low-level details.",
        detail_two="These principles are tools, not laws. Good interview answers explain the pressure each principle is reacting to and when strict application would add too many layers for the complexity of the problem.",
        practice="Use examples. A repository interface, a notification strategy, or a payment processor hierarchy can show how SOLID reduces the blast radius of change when requirements evolve.",
        example_code="interface PaymentGateway {\n  charge(amount: number): Promise<void>;\n}\n\nclass CheckoutService {\n  constructor(private gateway: PaymentGateway) {}\n\n  async checkout(amount: number) {\n    await this.gateway.charge(amount);\n  }\n}\n",
        pitfalls=[
            "Applying SOLID mechanically often produces too many tiny types and abstractions for simple code.",
            "Talking about the acronym without tying it to a concrete change scenario makes the explanation sound memorized.",
        ],
        takeaways=[
            "SOLID helps you reason about change cost and coupling, not just class design aesthetics.",
            "Each principle addresses a specific maintenance pain, so examples matter more than definitions.",
            "Use the principles when they reduce real friction, not as a license to over-abstract everything.",
        ],
        example_language="typescript",
    ),
    ("general", "design_patterns"): topic(
        summary="Design patterns are recurring solutions to recurring coordination problems, such as creation, adaptation, delegation, or state change notification.",
        detail_one="Patterns like Factory, Builder, Observer, Strategy, Adapter, Facade, Decorator, Repository, Coordinator, and Dependency Injection are useful because they name trade-offs. Once a team shares the vocabulary, it becomes easier to talk about why one structure fits the problem better than another.",
        detail_two="The danger is pattern worship. A pattern is valuable only when it makes the design clearer or more adaptable for a real problem; otherwise it is just indirection with a famous name.",
        practice="Interviewers usually want to hear what problem a pattern solves, what trade-off it introduces, and when a simpler alternative would be enough. Naming the pattern is the easy part.",
        example_code="class DiscountContext {\n  constructor(private strategy: { apply(total: number): number }) {}\n\n  checkout(total: number) {\n    return this.strategy.apply(total);\n  }\n}\n",
        pitfalls=[
            "Choosing patterns by popularity instead of by the underlying problem usually creates accidental complexity.",
            "Explaining only the structure and not the trade-offs makes pattern knowledge sound shallow.",
        ],
        takeaways=[
            "Patterns are vocabulary for common design trade-offs, not mandatory architecture ingredients.",
            "A good pattern explanation starts with the problem it solves and the cost it introduces.",
            "When a simpler design works, it is usually the better choice than a pattern-rich one.",
        ],
        example_language="typescript",
    ),
    ("general", "data_structures"): topic(
        summary="Data structures matter because they determine how quickly and safely you can insert, search, remove, or organize information.",
        detail_one="Arrays are great for indexed access, linked lists are optimized for node insertion patterns, stacks and queues model LIFO and FIFO behavior, hash tables trade memory for fast lookup, trees organize hierarchical relationships, heaps support priority access, and graphs model arbitrary connections.",
        detail_two="The important interview skill is matching operations to structure. Big O notation matters, but a good answer also mentions memory layout, iteration needs, and whether ordering or uniqueness is important.",
        practice="Use examples such as browser history for stacks, job scheduling for priority queues, or route planning for graphs. That shows you understand the structure as a tool, not a flashcard.",
        example_code="class MinHeap {\n  values = [];\n\n  insert(value) {\n    this.values.push(value);\n    this.values.sort((a, b) => a - b);\n  }\n\n  removeMin() {\n    return this.values.shift();\n  }\n}\n",
        pitfalls=[
            "Choosing structures by familiarity instead of by operation cost leads to code that works but scales poorly.",
            "Talking only in Big O terms without describing the use case misses why the structure was chosen in the first place.",
        ],
        takeaways=[
            "Pick data structures based on the operations that must stay efficient and correct.",
            "Different structures encode different guarantees around ordering, lookup, insertion, and traversal.",
            "Interview answers are strongest when they connect the structure to a concrete workload.",
        ],
        example_language="javascript",
    ),
    ("general", "algorithms"): topic(
        summary="Algorithms are step-by-step strategies for solving problems, and the real skill is choosing or adapting one based on the shape of the input and the cost constraints.",
        detail_one="Sorting, searching, recursion, traversal, and dynamic techniques each make sense in different situations. Big O helps compare growth, but it is only useful when tied to the operations the user or system actually performs.",
        detail_two="Good interview reasoning shows how you move from brute force to improvement. Explaining why a naive approach is too slow and what property makes a better approach possible is often more important than instantly naming the final algorithm.",
        practice="Talk through examples like binary search on sorted data, DFS or BFS on trees and graphs, or the trade-offs between quicksort and mergesort. That shows both recall and judgment.",
        example_code="function binarySearch(values, target) {\n  let left = 0;\n  let right = values.length - 1;\n\n  while (left <= right) {\n    const middle = Math.floor((left + right) / 2);\n    if (values[middle] === target) return middle;\n    if (values[middle] < target) left = middle + 1;\n    else right = middle - 1;\n  }\n\n  return -1;\n}\n",
        pitfalls=[
            "Jumping to an advanced algorithm without justifying the input assumptions makes the explanation fragile.",
            "Optimizing asymptotic complexity while ignoring constant factors or problem constraints can lead to the wrong trade-off in practice.",
        ],
        takeaways=[
            "Algorithm choice starts with understanding the input, output, and bottleneck.",
            "Big O is useful when it is tied to real operations and constraints, not used as trivia.",
            "A good explanation shows how and why you improve from a simpler baseline approach.",
        ],
        example_language="javascript",
    ),
    ("general", "rest_api"): topic(
        summary="A REST API is a resource-oriented way to expose server capabilities over HTTP, where methods, status codes, and representations communicate what happened and what the client can do next.",
        detail_one="GET, POST, PUT, PATCH, and DELETE are not just verbs to memorize; they describe intent around fetching, creating, replacing, partially updating, or deleting resources. Status codes, headers, pagination, and authentication form the contract that lets clients behave predictably.",
        detail_two="Good API design also thinks about naming, idempotency, versioning, and error shape. A client should not need insider knowledge to know whether a request can be retried or why it failed.",
        practice="A strong answer compares endpoint structure and transport semantics to product needs. For example, a feed API, a checkout API, and an admin API may all use HTTP, but the safety and consistency expectations differ.",
        example_code="GET /api/v1/orders/42\nAuthorization: Bearer <token>\nAccept: application/json\n",
        pitfalls=[
            "Treating REST as 'just JSON over HTTP' misses the importance of resource modeling and protocol semantics.",
            "Inconsistent status codes and error bodies make APIs harder to integrate than the business logic itself.",
        ],
        takeaways=[
            "REST design is about using HTTP semantics to communicate intent and outcomes clearly.",
            "Status codes, idempotency, and error contracts matter as much as endpoint names.",
            "A good API contract helps clients recover, paginate, cache, and evolve safely.",
        ],
        example_language="http",
    ),
    ("general", "websocket"): topic(
        summary="WebSocket provides a persistent full-duplex connection when client and server need to exchange messages continuously without repeated HTTP request overhead.",
        detail_one="The connection starts with an HTTP upgrade handshake, then moves to framed messages over a long-lived socket. That makes WebSocket useful for chat, live dashboards, collaborative editing, and presence features where updates flow in both directions.",
        detail_two="Socket.IO adds higher-level features such as rooms and fallback transport behavior, but it is not the same thing as the WebSocket protocol itself. The real design questions are connection lifecycle, retry strategy, ordering, and what happens when the connection drops.",
        practice="Interview answers are strongest when they mention the trade-off: WebSocket gives low-latency updates, but you take on connection management, backpressure, and distributed systems concerns that simple request-response APIs avoid.",
        example_code="client.connect()\nclient.on(\"message\", (payload) => {\n  console.log(payload)\n})\nclient.send(JSON.stringify({ type: \"ping\" }))\n",
        pitfalls=[
            "Choosing WebSocket for occasional updates adds connection complexity when polling or server-sent events might be enough.",
            "Ignoring reconnect, ordering, and offline behavior makes real-time features look good in demos but fragile in production.",
        ],
        takeaways=[
            "WebSocket is valuable when low-latency bidirectional messaging is part of the product experience.",
            "The protocol choice comes with lifecycle and reliability responsibilities beyond the happy path.",
            "Different real-time tools solve different problems, so compare them by update pattern and operational cost.",
        ],
        example_language="javascript",
    ),
    ("general", "graphql"): topic(
        summary="GraphQL lets clients ask for precisely shaped data through queries, mutations, and subscriptions, which can reduce over-fetching but shifts complexity into the schema and resolver layer.",
        detail_one="Queries read data, mutations change it, and subscriptions stream changes. The schema is the contract, so good GraphQL design depends on stable types, clear field ownership, and resolver performance that avoids N+1 query problems.",
        detail_two="Compared with REST, GraphQL gives clients more flexibility but often requires stronger server-side discipline around caching, authorization, and complexity limits. The trade-off is not simply 'GraphQL is more modern'.",
        practice="Strong answers compare the API styles in context. GraphQL is especially attractive when multiple clients need differently shaped views of related data, but it can be unnecessary if a small, stable REST surface already fits the workload well.",
        example_code="query ProductDetail($id: ID!) {\n  product(id: $id) {\n    id\n    name\n    reviews {\n      rating\n      comment\n    }\n  }\n}\n",
        pitfalls=[
            "GraphQL does not automatically solve backend design problems; poor resolver structure can make performance worse than a simple REST API.",
            "Allowing arbitrary query complexity without limits creates operational and security risk quickly.",
        ],
        takeaways=[
            "GraphQL trades endpoint flexibility for more schema and resolver discipline.",
            "It shines when clients need differently shaped data from one coherent graph.",
            "Authorization, caching, and query complexity still need deliberate design.",
        ],
        example_language="graphql",
    ),
    ("general", "networking_fundamentals"): topic(
        summary="Networking fundamentals explain how machines find each other, establish trust, and move data across unreliable networks with predictable rules.",
        detail_one="HTTP and HTTPS describe application-layer communication, TCP and UDP define different transport guarantees, DNS maps names to addresses, and TLS secures data in transit through encryption and certificate-based trust. Each layer solves a different part of the problem.",
        detail_two="Certificate pinning is a good example of adding stricter trust requirements for sensitive applications, but it also adds operational cost because certificate rotation becomes your problem too. Security and reliability choices always come with trade-offs.",
        practice="Strong answers connect the layers. For example, an HTTPS request usually relies on DNS lookup, a TCP connection, a TLS handshake, and then the HTTP exchange. Understanding that chain helps debug latency, trust, and connection issues more intelligently.",
        example_code="Client -> DNS lookup -> TCP connection -> TLS handshake -> HTTP request -> HTTP response\n",
        pitfalls=[
            "Treating all network failures as 'the API is down' ignores where problems can happen in the stack.",
            "Adding security mechanisms like pinning without planning for rotation and failure handling can create self-inflicted outages.",
        ],
        takeaways=[
            "Network communication depends on multiple layers that solve naming, transport, trust, and application semantics separately.",
            "Good debugging comes from knowing which layer is responsible for which guarantee.",
            "Security choices such as TLS and pinning improve trust but also create operational responsibilities.",
        ],
        example_language="text",
    ),
    ("general", "authentication_authorization"): topic(
        summary="Authentication answers 'who are you', while authorization answers 'what are you allowed to do'. Mixing them up produces weak system design and security holes.",
        detail_one="OAuth 2.0, JWTs, API keys, session cookies, and biometric checks all play different roles. Some establish identity, some transport delegated permissions, some identify applications, and some unlock secrets already stored securely on the device.",
        detail_two="A secure design also includes expiration, refresh, revocation, least privilege, and how permissions are enforced server-side. Identity without careful authorization still leaves the system exposed.",
        practice="A good interview answer compares the mechanism to the threat model. For example, mobile client auth, backend service auth, and third-party delegated login are related but not identical problems.",
        example_code="POST /oauth/token\ngrant_type=refresh_token\nrefresh_token=<refresh-token>\n",
        pitfalls=[
            "Storing long-lived credentials casually or treating client-side role checks as real authorization is a serious design mistake.",
            "Using JWTs or OAuth terminology without explaining token lifetime, refresh, and revocation makes the answer incomplete.",
        ],
        takeaways=[
            "Authentication and authorization solve different security questions and should be modeled separately.",
            "Token format is less important than how issuance, storage, expiry, and enforcement are handled.",
            "Least privilege and server-side checks are central to a real authorization design.",
        ],
        example_language="http",
    ),
    ("general", "git"): topic(
        summary="Git is a distributed version-control system for tracking changes, collaborating safely, and keeping a clear history of why code evolved.",
        detail_one="Branches, merges, rebases, cherry-picks, stashes, and tagging all manipulate history in different ways. The important thing is understanding the history you want to preserve and what collaboration model your team can work with safely.",
        detail_two="Merge versus rebase is not a morality debate; it is a choice between preserving branch history and presenting a cleaner linear history. Trunk-based development and GitFlow make different trade-offs around release cadence and coordination cost.",
        practice="Strong answers focus on collaboration outcomes: cleaner reviews, safer releases, easier rollbacks, and less confusion when conflicts happen. Conventional commits and small branches help because they make intent and release notes clearer.",
        example_code="git checkout -b feature/profile\n# work\ngit commit -m \"feat: add profile summary card\"\ngit rebase main\n",
        pitfalls=[
            "Using Git commands by habit without understanding the resulting history makes conflict recovery and collaboration much harder.",
            "Large long-lived branches increase merge pain and hide integration problems until late in the cycle.",
        ],
        takeaways=[
            "Git proficiency is really about understanding history and collaboration trade-offs.",
            "Choose branch and integration strategies that fit the team's release rhythm and review process.",
            "Smaller, clearer commits make debugging and collaboration easier than any advanced command alone.",
        ],
        example_language="bash",
    ),
    ("general", "ci_cd_concepts"): topic(
        summary="CI/CD is the practice of automating validation and delivery so software moves through build, test, and release stages reliably instead of by manual repetition.",
        detail_one="Continuous integration catches problems early by running checks on changes as they happen. Continuous delivery or deployment extends that by packaging and shipping artifacts into real environments through controlled automation.",
        detail_two="Pipelines reflect environment strategy too: development, staging, and production often need different data, secrets, and approvals. Good CI/CD design balances speed with enough gates to keep releases safe.",
        practice="A strong explanation frames a pipeline as stages with clear inputs and outputs: fetch code, install dependencies, run tests, build artifacts, deploy, verify, and potentially roll back. That shows operational thinking, not just tool familiarity.",
        example_code="pipeline:\n  - lint\n  - test\n  - build\n  - deploy-to-staging\n  - smoke-test\n  - deploy-to-production\n",
        pitfalls=[
            "Automating deployment without trustworthy tests and rollback plans can turn mistakes into faster outages.",
            "Pipelines that are slow or flaky lose credibility, so developers stop relying on them for feedback.",
        ],
        takeaways=[
            "CI/CD is about reliable feedback and release automation, not just a specific vendor or YAML syntax.",
            "A good pipeline is fast enough to use constantly and strict enough to catch risky changes.",
            "Environment strategy, secrets, and rollback planning are part of the delivery design.",
        ],
        example_language="yaml",
        section_code=None,
    ),
    ("general", "databases"): topic(
        summary="Database design is about storing and retrieving data with the right balance of consistency, flexibility, and performance for the workload.",
        detail_one="SQL databases emphasize structured schema, joins, and ACID transactions, while NoSQL databases vary widely in exchange for different trade-offs around schema flexibility, scaling, and access patterns. The right choice depends on the queries and invariants you must support.",
        detail_two="Normalization reduces duplication, indexing speeds lookups at the cost of write overhead and storage, and transactions protect correctness when multiple changes must succeed or fail together. These are design tools, not abstract theory.",
        practice="Strong answers compare databases through concrete access patterns. A reporting system, a chat timeline, and a financial ledger often need different storage guarantees and query shapes.",
        example_code="CREATE INDEX idx_orders_user_id ON orders(user_id);\n",
        pitfalls=[
            "Choosing a database by trend instead of by access pattern and consistency needs leads to painful rewrites later.",
            "Adding indexes without measuring query patterns can improve one path while degrading write performance and storage use.",
        ],
        takeaways=[
            "Pick storage technology based on consistency, query shape, and scaling needs.",
            "Schema design, indexing, and transaction boundaries are central to correctness and performance.",
            "SQL versus NoSQL is a trade-off discussion, not a simple quality ranking.",
        ],
        example_language="sql",
    ),
    ("general", "caching_strategies"): topic(
        summary="Caching improves speed and reduces load by reusing previously fetched or computed data, but it only works well when freshness and invalidation are designed deliberately.",
        detail_one="In-memory caches are fast but ephemeral, disk caches survive restarts, and HTTP caching with headers like ETag or Cache-Control lets clients and servers cooperate on freshness decisions. Each layer solves a different latency problem.",
        detail_two="The classic hard part is invalidation. A cache is useful only if you know when to reuse, revalidate, expire, or bypass it based on data volatility and user expectations.",
        practice="A strong answer uses examples such as avatar images, feature flags, or product listings. That makes it easier to explain time-to-live, stale-while-revalidate, and what happens when cached data conflicts with user-triggered updates.",
        example_code="GET /feed\nIf-None-Match: \"v42\"\n",
        pitfalls=[
            "Adding a cache without a freshness strategy simply trades latency problems for correctness problems.",
            "Caching highly user-specific or rapidly changing data blindly can create confusing stale experiences.",
        ],
        takeaways=[
            "Caching is a trade-off between speed, load reduction, and freshness guarantees.",
            "Different cache layers solve different problems, from RAM speed to HTTP revalidation.",
            "Invalidation rules are part of the design from the start, not a later patch.",
        ],
        example_language="http",
    ),
    ("general", "system_design_basics"): topic(
        summary="System design basics are about decomposing a product into services, storage, and delivery paths that can scale, stay available, and remain understandable under real traffic.",
        detail_one="Load balancers distribute traffic, CDNs move static content closer to users, message queues smooth asynchronous work, microservices trade isolation for operational complexity, and sharding spreads data when one database node is not enough. Each tool exists because one box or one process eventually stops being enough.",
        detail_two="The skill is knowing which bottleneck you are solving. Scaling write throughput, lowering latency, isolating failures, and supporting team autonomy are different goals that may point to different architectures.",
        practice="A strong interview answer starts with requirements and bottlenecks, then introduces components only when they solve a specific need. That is much better than drawing every famous box from a distributed systems diagram.",
        example_code="Client -> Load Balancer -> API Service -> Queue -> Worker -> Database\n                \\-> CDN -> Static assets\n",
        pitfalls=[
            "Adding distributed-system components before identifying the actual bottleneck creates complexity without value.",
            "System design answers that ignore trade-offs around consistency, failure, and operations sound theoretical rather than practical.",
        ],
        takeaways=[
            "System design starts with requirements, traffic, and failure modes, not with architecture buzzwords.",
            "Each component should exist because it solves a defined scaling, latency, or reliability problem.",
            "Trade-offs around consistency, complexity, and operations matter as much as the boxes on the diagram.",
        ],
        example_language="text",
    ),
    ("general", "security"): topic(
        summary="Security is the discipline of reducing risk by protecting data, identities, and execution paths against realistic threats, not by adding isolated checklists after the product is built.",
        detail_one="For mobile and backend systems that includes secure transport, encryption, safe storage, input validation, dependency hygiene, least privilege, and defenses against common OWASP issues such as insecure storage or broken authentication.",
        detail_two="Every security choice belongs to a threat model. Code obfuscation, biometric gates, or certificate pinning can help in some contexts, but they do not replace basic discipline around server-side validation, secrets handling, and access control.",
        practice="Strong answers connect controls to threats and acknowledge trade-offs. Security decisions affect UX, operations, recoverability, and developer workflows, so they cannot be treated as purely technical add-ons.",
        example_code="Security checklist\n- Encrypt data in transit with HTTPS/TLS\n- Store secrets in protected storage only\n- Validate authorization on the server\n- Rotate credentials and monitor abuse\n",
        pitfalls=[
            "Relying on client-side checks or obfuscation while neglecting server-side authorization is a fundamental security mistake.",
            "Listing security practices without connecting them to actual threats leads to shallow designs and blind spots.",
        ],
        takeaways=[
            "Security is threat-model-driven risk reduction, not a bag of unrelated best practices.",
            "Server-side authorization, secure transport, and safe secret handling are foundational.",
            "Every extra security layer has operational and UX trade-offs that must be understood, not ignored.",
        ],
        example_language="text",
    ),
    ("general", "agile_scrum"): topic(
        summary="Agile and Scrum are ways of organizing work so teams can learn, adapt, and deliver incrementally rather than betting everything on long up-front plans.",
        detail_one="Sprints, planning, daily standups, reviews, and retrospectives exist to create a feedback loop around delivery. Story points, kanban limits, and backlog refinement are tools for managing uncertainty and flow, not rituals to perform blindly.",
        detail_two="The strongest interview answers talk about outcomes: faster feedback, clearer priorities, and earlier risk discovery. A team can follow every ceremony and still fail if work is poorly sliced or feedback is ignored.",
        practice="Use real examples. Explain how small increments, demos, and retrospectives changed the way a team handled ambiguity, release pressure, or cross-functional coordination.",
        example_code="Sprint flow\nBacklog -> Planning -> Build/Test -> Review -> Retro -> Next sprint\n",
        pitfalls=[
            "Treating Scrum events as performance theater instead of feedback mechanisms wastes time and frustrates teams.",
            "Large vague tickets undermine agile processes because there is no real increment to learn from or ship.",
        ],
        takeaways=[
            "Agile methods are valuable when they shorten feedback loops and reduce planning blindness.",
            "Ceremonies matter only if they help the team inspect, adapt, and deliver usable increments.",
            "Work slicing and learning speed are often more important than perfect process terminology.",
        ],
        example_language="text",
    ),
    ("general", "code_quality"): topic(
        summary="Code quality is the combined result of design clarity, review discipline, automation, and the team's willingness to keep the codebase easy to change.",
        detail_one="Code reviews, linting, static analysis, and automated tests all catch different classes of problems. Reviews surface design risks and context, while tools enforce consistent rules and catch mistakes that humans overlook when tired or rushed.",
        detail_two="Tech debt is not just 'old code'. It is the accumulated cost of decisions that make future changes slower or riskier. Good teams track it intentionally and pay it down where it blocks meaningful progress.",
        practice="Strong answers focus on maintainability under change: can new engineers understand the code, can risky changes be reviewed safely, and do the tools catch obvious regressions before humans need to argue about style?",
        example_code="Quality loop\n1. Clear ownership and coding standards\n2. Automated lint and test checks\n3. Review for correctness and design risk\n4. Refactor high-friction areas before they become blockers\n",
        pitfalls=[
            "Reducing code quality to formatting rules misses the deeper issues of design, naming, and change cost.",
            "Ignoring tech debt until delivery slows down sharply makes cleanup more expensive than steady maintenance would have been.",
        ],
        takeaways=[
            "Code quality is about preserving the ability to change software safely and confidently.",
            "Humans and automation catch different problems, so strong teams rely on both.",
            "Tech debt should be managed intentionally where it creates recurring friction or risk.",
        ],
        example_language="text",
    ),
    ("general", "clean_code"): topic(
        summary="Clean code is code that communicates intent clearly, keeps responsibilities narrow, and avoids unnecessary complexity for the next person who has to change it.",
        detail_one="Good naming, small focused functions, and principles like KISS, DRY, and YAGNI are all trying to reduce mental load. The goal is not to make code look clever; it is to make behavior and trade-offs easy to see.",
        detail_two="Comments should explain why something exists or what constraint matters, not restate obvious code. When code needs long comments to be understood, the design often wants better names or smaller units.",
        practice="A strong interview answer admits the trade-offs. Sometimes duplication is cheaper than premature abstraction, and sometimes a simple comment is better than another layer of indirection. Clean code is judgment, not purity.",
        example_code="function calculateCheckoutTotal(items) {\n  return items.reduce((sum, item) => sum + item.price, 0);\n}\n",
        pitfalls=[
            "Using DRY as an excuse to merge unrelated logic into one abstraction often makes the code less clear, not more.",
            "Comments that narrate obvious syntax become noise and hide the places where real explanation is needed.",
        ],
        takeaways=[
            "Clean code optimizes for clarity, changeability, and honest communication of intent.",
            "Principles like KISS and YAGNI help only when applied with context and restraint.",
            "Prefer better names and boundaries before reaching for explanatory comments everywhere.",
        ],
        example_language="javascript",
    ),
    ("general", "accessibility"): topic(
        summary="Accessibility is about making software usable by people with different abilities, devices, and interaction methods so critical tasks remain possible and understandable.",
        detail_one="WCAG principles such as perceivable, operable, understandable, and robust translate into concrete engineering choices: semantic labels, keyboard support, contrast, captions, focus order, touch targets, and scalable text. Mobile accessibility also depends on platform tools like VoiceOver and TalkBack.",
        detail_two="Accessibility is a design quality issue, not a niche add-on. The same improvements that help screen-reader users often improve clarity for everyone else by making structure, labels, and interactions less ambiguous.",
        practice="Strong answers mention testing with assistive technologies and considering accessibility during design reviews. That shows you know guidelines matter only when they survive real interaction, not just checklist completion.",
        example_code="Accessibility review\n- Every control has a meaningful label\n- Content works with larger text sizes\n- Color is not the only signal\n- Focus order matches reading order\n",
        pitfalls=[
            "Relying on visual cues alone excludes users who cannot perceive the screen in the same way as the design team.",
            "Treating accessibility as final polish means major layout and interaction issues appear too late to fix cheaply.",
        ],
        takeaways=[
            "Accessibility combines semantics, interaction design, readable content, and resilient layout.",
            "Guidelines become real quality only when verified with assistive tools and real scenarios.",
            "Accessible design usually produces clearer, more robust software for all users.",
        ],
        example_language="text",
    ),
    ("general", "internationalization_localization"): topic(
        summary="Internationalization prepares software to support multiple languages and regions, while localization adapts the product for a specific locale's language, formatting, and cultural expectations.",
        detail_one="This includes translatable strings, pluralization, date and number formatting, right-to-left layout support, and enough flexible UI space for languages that expand dramatically. The engineering work is mostly about removing hidden assumptions from the code and design.",
        detail_two="Cultural fit matters too. Icons, color meaning, examples, and legal expectations can differ across markets. A truly localizable product anticipates those differences instead of forcing every locale into the original design mold.",
        practice="Strong answers mention separating content from code, testing with long translations, and treating locale as an input to formatting logic rather than as a patch applied after the UI is done.",
        example_code="Localization checklist\n- Externalize strings\n- Use locale-aware formatting\n- Support RTL layouts\n- Test long and short translations\n",
        pitfalls=[
            "String extraction alone is not enough when layout, formatting, and cultural assumptions are still hard-coded.",
            "Deferring localization until late in development often exposes expensive UI and content problems at the worst moment.",
        ],
        takeaways=[
            "Internationalization removes locale assumptions so localization can adapt the product cleanly.",
            "Formatting, layout, and cultural expectations matter alongside translation.",
            "Flexible UI and locale-aware logic are the foundation of a product that scales internationally.",
        ],
        example_language="text",
    ),
    ("general", "app_performance"): topic(
        summary="App performance is about keeping launch, interaction, memory, and rendering costs low enough that the product feels responsive on real devices and networks.",
        detail_one="Profiling reveals whether the bottleneck is CPU work, main-thread blocking, image decoding, memory leaks, over-fetching, or rendering too much content too early. Lazy loading and image optimization help only when they target the actual problem you measured.",
        detail_two="Performance also has a product dimension. A fast feature is one that responds predictably under typical and poor conditions, not just on a developer's flagship device over perfect Wi-Fi.",
        practice="Strong answers mention tools, measurement, and user experience together. Optimizations are easiest to justify when you can describe the real pain they remove: dropped frames, high memory use, slow feed load, or battery drain.",
        example_code="Performance loop\n1. Measure with profiler tools\n2. Identify the real bottleneck\n3. Fix the most expensive work first\n4. Re-measure on representative devices\n",
        pitfalls=[
            "Optimizing before measuring often adds complexity without improving the user experience.",
            "Testing only on fast devices hides problems that dominate the experience for a large part of the user base.",
        ],
        takeaways=[
            "Performance work starts with measurement and ends with user-visible improvement.",
            "Different bottlenecks require different fixes, so profiling matters more than intuition.",
            "Representative devices, data sizes, and networks are essential for honest performance decisions.",
        ],
        example_language="text",
    ),
    ("general", "dependency_management"): topic(
        summary="Dependency management is the practice of choosing, versioning, updating, and auditing third-party packages so the codebase stays buildable, secure, and understandable.",
        detail_one="Package managers like SPM, CocoaPods, and pub.dev solve installation and resolution differently, but the larger design question is how much external code your app should rely on and how that risk is controlled over time.",
        detail_two="Versioning and lock files matter because reproducible builds depend on everyone using the same resolved dependency graph. Security advisories, transitive dependencies, and abandoned packages turn dependency decisions into long-term maintenance concerns, not one-time setup.",
        practice="A strong answer covers both speed and caution: dependencies can accelerate delivery, but every package is also a supply-chain and maintenance commitment. The best teams evaluate need, maturity, update policy, and exit cost before adopting one.",
        example_code="dependencies:\n  package_a: ^2.4.0\n  package_b: 1.3.2\nlockfile: committed\n",
        pitfalls=[
            "Adding packages for trivial problems increases attack surface and maintenance cost without meaningful leverage.",
            "Ignoring lock files or update strategy leads to non-reproducible builds and surprise breakages in CI or production.",
        ],
        takeaways=[
            "Dependencies save time only when their long-term maintenance cost is understood and acceptable.",
            "Lock files and version strategy are central to reproducible builds.",
            "Evaluate packages by fit, health, security, and exit cost, not just by stars or convenience.",
        ],
        example_language="yaml",
        section_code=None,
    ),
}


def paragraph(*parts: str) -> str:
    return "\n\n".join(part.strip() for part in parts if part and part.strip())


def base_title(title: str) -> str:
    return title.split(" (", 1)[0].strip()


def default_language(track: str) -> str:
    if track == "flutter":
        return "dart"
    if track == "swift":
        return "swift"
    return "text"


def fallback_spec(lesson: dict) -> dict:
    title = base_title(lesson["title"])
    track = lesson["track"]
    topic_name = lesson["topic"].replace("_", " ")
    if track == "flutter":
        example_code = (
            "class ExampleWidget extends StatelessWidget {\n"
            "  const ExampleWidget({super.key});\n\n"
            "  @override\n"
            "  Widget build(BuildContext context) {\n"
            "    return const Placeholder();\n"
            "  }\n"
            "}"
        )
    elif track == "swift":
        example_code = (
            "struct ExampleView: View {\n"
            "    var body: some View {\n"
            "        Text(\"Study the trade-offs, not just the syntax\")\n"
            "    }\n"
            "}"
        )
    else:
        example_code = (
            "Input -> apply the concept deliberately -> measure the result -> iterate on facts, not guesses"
        )

    return topic(
        summary=(
            f"{title} is worth learning because it shapes how you design, reason about, and explain {topic_name} in real projects."
        ),
        detail_one=(
            "A strong answer starts with the mental model: what problem this concept solves, what trade-off it introduces, "
            "and how it changes the code a teammate has to read."
        ),
        detail_two=(
            "Once the mental model is clear, the interview conversation becomes easier because you can compare alternatives "
            "instead of reciting isolated API names."
        ),
        practice=(
            "Tie the concept back to a feature you could actually ship, then explain what can go wrong when the team applies "
            "it mechanically without understanding the constraints."
        ),
        example_code=example_code,
        pitfalls=[
            "Treating the topic as memorization instead of understanding why one approach is safer or cheaper than another.",
            "Jumping to advanced abstractions before you can explain the simplest version that solves the problem.",
        ],
        takeaways=[
            f"Start with the problem that {title} is solving.",
            "Compare the trade-offs between the main options instead of naming APIs without context.",
            "Use a concrete app scenario to prove that you understand the topic well enough to apply it.",
        ],
    )


def unique_items(items: list[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for item in items:
        cleaned = item.strip()
        if cleaned and cleaned not in seen:
            seen.add(cleaned)
            result.append(cleaned)
    return result


def placed_options(correct: str, distractors: list[str], correct_index: int) -> tuple[list[str], int]:
    cleaned_correct = correct.strip()
    options = unique_items([item for item in distractors if item.strip() != cleaned_correct])
    filler = [
        "The topic mostly matters when the framework or tool forces it, not as part of normal design work.",
        "Once the first version works, the surrounding trade-offs are no longer important.",
        "The best default is to hide the concept entirely so the team does not need to reason about it directly.",
    ]
    for candidate in filler:
        if len(options) >= 3:
            break
        if candidate != cleaned_correct and candidate not in options:
            options.append(candidate)

    options = options[:3]
    options.insert(correct_index, cleaned_correct)
    return options[:4], correct_index


def mcq_kind(exercise: dict) -> str:
    question = exercise.get("question") or ""
    if question.startswith("Which statement about "):
        return "concept"
    if question.startswith("What should a strong interview answer about "):
        return "interview_answer"
    if question.startswith("Which mistake is most likely when a team handles "):
        return "mistake"
    if question.startswith("Which tag best matches the core concern in "):
        return "tag"
    if question.startswith("Which statement best reflects the engineering tradeoff in "):
        return "tradeoff"
    return "other"


def build_quiz(lesson: dict, spec: dict) -> list[dict]:
    title = lesson["title"]
    concept_options, concept_answer = placed_options(
        spec["summary"],
        [
            spec["takeaways"][0],
            spec["practice"],
            spec["pitfalls"][0],
        ],
        1,
    )
    practice_options, practice_answer = placed_options(
        spec["takeaways"][1],
        [
            spec["summary"],
            spec["pitfalls"][0],
            spec["pitfalls"][1],
        ],
        2,
    )
    trap_options, trap_answer = placed_options(
        spec["pitfalls"][0],
        [
            spec["takeaways"][0],
            spec["takeaways"][1],
            spec["takeaways"][2],
        ],
        3,
    )

    return [
        {
            "id": f"{lesson['id'].replace('_lesson_1', '')}_quiz_1",
            "question": f"Which option best captures the core mental model behind {title}?",
            "options": concept_options,
            "correct_answer": concept_answer,
            "explanation": spec["summary"],
        },
        {
            "id": f"{lesson['id'].replace('_lesson_1', '')}_quiz_2",
            "question": f"Which day-to-day approach is strongest when working with {title}?",
            "options": practice_options,
            "correct_answer": practice_answer,
            "explanation": spec["takeaways"][1],
        },
        {
            "id": f"{lesson['id'].replace('_lesson_1', '')}_quiz_3",
            "question": f"Which trap is most likely to create bugs or confusion with {title}?",
            "options": trap_options,
            "correct_answer": trap_answer,
            "explanation": spec["pitfalls"][0],
        },
    ]


def pick_tag_distractors(track: str, current_tags: list[str], tag_pool_by_track: dict[str, list[str]]) -> list[str]:
    pool = [tag for tag in tag_pool_by_track[track] if tag not in current_tags]
    if len(pool) < 3:
        pool.extend(
            [
                "architecture",
                "performance",
                "debugging",
                "state",
            ]
        )
    return unique_items(pool)[:3]


def rebuild_mcq_exercise(exercise: dict, spec: dict, title: str, tag_pool_by_track: dict[str, list[str]]) -> dict:
    kind = mcq_kind(exercise)
    if kind == "other":
        return exercise

    if kind == "concept":
        question = f"Which option best captures the core mental model of {title}?"
        options, correct_answer = placed_options(
            spec["summary"],
            [
                spec["takeaways"][0],
                spec["practice"],
                spec["pitfalls"][0],
            ],
            2,
        )
        explanation = spec["summary"]
    elif kind == "interview_answer":
        question = f"Which point would make an interview explanation of {title} noticeably stronger?"
        options, correct_answer = placed_options(
            spec["takeaways"][1],
            [
                spec["summary"],
                spec["pitfalls"][0],
                spec["pitfalls"][1],
            ],
            0,
        )
        explanation = spec["takeaways"][1]
    elif kind == "mistake":
        question = f"Which behavior is most likely to cause trouble when a team uses {title}?"
        options, correct_answer = placed_options(
            spec["pitfalls"][0],
            [
                spec["takeaways"][0],
                spec["takeaways"][1],
                spec["practice"],
            ],
            1,
        )
        explanation = spec["pitfalls"][0]
    elif kind == "tag":
        correct_tag = exercise["tags"][0] if exercise.get("tags") else "fundamentals"
        options, correct_answer = placed_options(
            correct_tag,
            pick_tag_distractors(exercise["track"], exercise.get("tags") or [], tag_pool_by_track),
            3,
        )
        question = f"Which tag is the best fit for the core concern in {title}?"
        explanation = f"`{correct_tag}` is the best match because it sits at the center of this topic's mental model."
    else:
        question = f"Which reminder best captures the key design tradeoff in {title}?"
        options, correct_answer = placed_options(
            spec["takeaways"][2],
            [
                spec["summary"],
                spec["practice"],
                spec["pitfalls"][1],
            ],
            2,
        )
        explanation = spec["takeaways"][2]

    return {
        **exercise,
        "question": question,
        "options": options,
        "correct_answer": correct_answer,
        "explanation": explanation,
    }


def build_lesson(lesson: dict) -> dict:
    spec = deepcopy(SPECS.get((lesson["track"], lesson["topic"])) or fallback_spec(lesson))
    lesson_id_root = lesson["id"].replace("_lesson_1", "")
    title_root = base_title(lesson["title"])

    section_code = spec["section_code"] or spec["example_code"]

    return {
        **lesson,
        "content": [
            {
                "id": f"{lesson_id_root}_section_1",
                "heading": "Mental Model",
                "body": paragraph(spec["summary"], spec["detail_one"]),
                "code_snippet": None,
            },
            {
                "id": f"{lesson_id_root}_section_2",
                "heading": "Key Mechanics",
                "body": spec["detail_two"],
                "code_snippet": section_code,
            },
            {
                "id": f"{lesson_id_root}_section_3",
                "heading": "In Practice",
                "body": spec["practice"],
                "code_snippet": None,
            },
            {
                "id": f"{lesson_id_root}_section_4",
                "heading": "Common Traps",
                "body": paragraph(*[f"- {item}" for item in spec["pitfalls"]]),
                "code_snippet": None,
            },
        ],
        "code_examples": [
            {
                "id": f"{lesson_id_root}_example_1",
                "title": spec["example_title"] or f"{title_root} example",
                "code": spec["example_code"],
                "language": spec["example_language"] or default_language(lesson["track"]),
                "explanation": paragraph(
                    spec["summary"],
                    spec["practice"],
                ),
            }
        ],
        "key_takeaways": spec["takeaways"],
        "mini_quiz": build_quiz(lesson, spec),
    }


def main() -> None:
    with CONTENT_PATH.open() as handle:
        bundle = json.load(handle)

    specs_by_lesson = {
        (lesson["track"], lesson["topic"]): deepcopy(SPECS.get((lesson["track"], lesson["topic"])) or fallback_spec(lesson))
        for lesson in bundle["lessons"]
    }
    tag_pool_by_track: dict[str, list[str]] = {}
    for lesson in bundle["lessons"]:
        track = lesson["track"]
        tag_pool_by_track.setdefault(track, [])
        for tag in lesson.get("tags", []):
            if tag not in tag_pool_by_track[track]:
                tag_pool_by_track[track].append(tag)

    bundle["lessons"] = [build_lesson(lesson) for lesson in bundle["lessons"]]
    bundle["exercises"] = [
        rebuild_mcq_exercise(
            exercise,
            specs_by_lesson[(exercise["track"], exercise["topic"])],
            base_title(
                next(
                    lesson["title"]
                    for lesson in bundle["lessons"]
                    if lesson["track"] == exercise["track"] and lesson["topic"] == exercise["topic"]
                )
            ),
            tag_pool_by_track,
        )
        if exercise["type"] == "mcq"
        else exercise
        for exercise in bundle["exercises"]
    ]

    with CONTENT_PATH.open("w") as handle:
        json.dump(bundle, handle, indent=2, ensure_ascii=True)
        handle.write("\n")


if __name__ == "__main__":
    main()
