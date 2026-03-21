import Foundation

// MARK: - Sample Data for DevPrep
// Provides fallback content when content.json is unavailable.

extension ContentService {

    // MARK: - Sample Lessons

    static var sampleLessons: [Lesson] {
        [
            // ───────────────────────────────────────────────
            // FLUTTER / DART
            // ───────────────────────────────────────────────

            Lesson(
                id: "lesson_flutter_dart_basics_1",
                track: .flutter,
                topic: "dart_basics",
                title: "Dart Language Fundamentals",
                difficulty: .easy,
                content: [
                    LessonSection(
                        id: "ls_dart_1_1",
                        heading: "Variables and Type System",
                        body: "Dart is a statically typed language with sound null safety. You declare variables using var, final, or const. The var keyword lets Dart infer the type, while final and const create immutable bindings. With null safety, every type is non-nullable by default; append a question mark (String?) to allow null values. This system catches null-reference errors at compile time rather than at runtime.",
                        codeSnippet: "var name = 'Alice';      // Type inferred as String\nfinal int age = 30;       // Immutable, set at runtime\nconst pi = 3.14159;       // Compile-time constant\nString? nickname;         // Nullable — defaults to null"
                    ),
                    LessonSection(
                        id: "ls_dart_1_2",
                        heading: "Functions and Closures",
                        body: "Functions in Dart are first-class objects. You can assign them to variables, pass them as arguments, and return them from other functions. Dart supports both named and positional parameters, and you can provide default values. Arrow syntax (=>) is a shorthand for functions that contain a single expression. Closures capture the surrounding lexical scope, which is essential for callbacks in Flutter.",
                        codeSnippet: "int add(int a, int b) => a + b;\n\nvoid greet({required String name, int times = 1}) {\n  for (var i = 0; i < times; i++) {\n    print('Hello, $name!');\n  }\n}\n\nfinal multiplier = (int x) => x * 2;"
                    ),
                    LessonSection(
                        id: "ls_dart_1_3",
                        heading: "Collections",
                        body: "Dart provides three core collection types: List (ordered), Set (unique elements), and Map (key-value pairs). All collections support generics and come with a rich set of methods such as map, where, fold, and expand. The spread operator (...) lets you insert all elements of one collection into another, and collection-if and collection-for allow conditional and iterative element insertion inside literals.",
                        codeSnippet: "final fruits = ['apple', 'banana', 'cherry'];\nfinal uniqueNumbers = {1, 2, 3};\nfinal scores = {'Alice': 95, 'Bob': 87};\n\n// Spread and collection-if\nfinal extra = ['date'];\nfinal all = [...fruits, ...extra, if (true) 'elderberry'];"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_dart_1_1",
                        title: "Null Safety in Practice",
                        code: "String? findUser(int id) {\n  final users = {1: 'Alice', 2: 'Bob'};\n  return users[id]; // Returns String?\n}\n\nvoid main() {\n  final user = findUser(1);\n  // Must handle null before using\n  print(user?.toUpperCase() ?? 'Unknown');\n  \n  // Bang operator — throws if null\n  // print(user!.toUpperCase());\n}",
                        language: "dart",
                        explanation: "This example shows how Dart's null safety forces you to handle nullable return values. The ?. operator safely accesses members, the ?? operator provides a fallback, and the ! operator asserts non-null at runtime."
                    ),
                    CodeExample(
                        id: "ce_dart_1_2",
                        title: "Higher-Order Functions",
                        code: "void main() {\n  final numbers = [1, 2, 3, 4, 5, 6];\n\n  final evens = numbers.where((n) => n.isEven).toList();\n  final doubled = numbers.map((n) => n * 2).toList();\n  final sum = numbers.fold<int>(0, (acc, n) => acc + n);\n\n  print(evens);   // [2, 4, 6]\n  print(doubled); // [2, 4, 6, 8, 10, 12]\n  print(sum);     // 21\n}",
                        language: "dart",
                        explanation: "Dart collections provide functional-style methods. where() filters, map() transforms, and fold() reduces a collection to a single value. These are used extensively in Flutter for building widget lists from data."
                    ),
                ],
                keyTakeaways: [
                    "Dart has sound null safety — all types are non-nullable by default, preventing null-reference crashes at compile time.",
                    "Functions are first-class objects and closures capture their surrounding scope, which is fundamental for Flutter callbacks.",
                    "Collections support generics, spread operators, and collection-if/for syntax for declarative list building.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_dart_1_1",
                        question: "What does the '?' after a type mean in Dart?",
                        options: [
                            "The variable is constant",
                            "The variable can hold a null value",
                            "The variable is private",
                            "The variable is lazy-loaded",
                        ],
                        correctAnswer: 1,
                        explanation: "In Dart's null safety system, appending ? to a type (e.g., String?) indicates the variable is allowed to be null. Without it, the compiler enforces that the value is never null."
                    ),
                    QuizQuestion(
                        id: "qq_dart_1_2",
                        question: "Which keyword creates a compile-time constant in Dart?",
                        options: ["var", "final", "const", "static"],
                        correctAnswer: 2,
                        explanation: "const creates a compile-time constant whose value must be determinable at compile time. final creates a runtime constant that is set once and cannot be reassigned, but its value can be computed at runtime."
                    ),
                    QuizQuestion(
                        id: "qq_dart_1_3",
                        question: "What does the => syntax do in Dart?",
                        options: [
                            "Declares a variable type",
                            "Creates an async generator",
                            "Shorthand for a single-expression function body",
                            "Defines a type alias",
                        ],
                        correctAnswer: 2,
                        explanation: "The arrow syntax (=>) is shorthand for { return expression; }. It can only be used when the function body is a single expression."
                    ),
                ],
                tags: ["dart", "fundamentals", "null-safety", "collections"],
                orderIndex: 0
            ),

            Lesson(
                id: "lesson_flutter_widgets_1",
                track: .flutter,
                topic: "widgets",
                title: "Understanding Flutter Widgets",
                difficulty: .easy,
                content: [
                    LessonSection(
                        id: "ls_widgets_1_1",
                        heading: "Everything is a Widget",
                        body: "In Flutter, the user interface is built entirely from widgets. A widget is an immutable description of part of the UI. Widgets are composed together in a tree structure — the widget tree — to create complex interfaces. When a widget's configuration changes, the framework compares the new widget tree with the old one and efficiently updates only the parts of the actual render tree that have changed.",
                        codeSnippet: nil
                    ),
                    LessonSection(
                        id: "ls_widgets_1_2",
                        heading: "StatelessWidget vs StatefulWidget",
                        body: "A StatelessWidget is immutable and describes part of the UI that depends only on its constructor arguments. It has no mutable state. A StatefulWidget, on the other hand, is paired with a State object that persists across rebuilds. When you call setState() inside a State object, Flutter marks the widget as dirty and schedules a rebuild. Choose StatelessWidget when the UI depends only on the configuration passed in, and StatefulWidget when the UI needs to change over time in response to user interaction or data changes.",
                        codeSnippet: "class Greeting extends StatelessWidget {\n  final String name;\n  const Greeting({super.key, required this.name});\n\n  @override\n  Widget build(BuildContext context) {\n    return Text('Hello, $name!');\n  }\n}"
                    ),
                    LessonSection(
                        id: "ls_widgets_1_3",
                        heading: "Common Layout Widgets",
                        body: "Flutter provides a rich set of layout widgets. Column and Row arrange children vertically and horizontally. Stack layers children on top of one another. Container adds padding, margin, decoration, and constraints. Expanded and Flexible control how children share available space inside a Row or Column. ListView and GridView handle scrollable lists and grids. Understanding how these layout widgets negotiate constraints is key to building responsive Flutter UIs.",
                        codeSnippet: "Column(\n  crossAxisAlignment: CrossAxisAlignment.start,\n  children: [\n    Text('Title', style: TextStyle(fontSize: 24)),\n    SizedBox(height: 8),\n    Row(\n      children: [\n        Icon(Icons.star, color: Colors.amber),\n        SizedBox(width: 4),\n        Text('4.8'),\n      ],\n    ),\n  ],\n)"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_widgets_1_1",
                        title: "Building a StatefulWidget Counter",
                        code: "class Counter extends StatefulWidget {\n  const Counter({super.key});\n\n  @override\n  State<Counter> createState() => _CounterState();\n}\n\nclass _CounterState extends State<Counter> {\n  int _count = 0;\n\n  @override\n  Widget build(BuildContext context) {\n    return Column(\n      mainAxisAlignment: MainAxisAlignment.center,\n      children: [\n        Text('Count: $_count', style: TextStyle(fontSize: 32)),\n        ElevatedButton(\n          onPressed: () => setState(() => _count++),\n          child: Text('Increment'),\n        ),\n      ],\n    );\n  }\n}",
                        language: "dart",
                        explanation: "This classic counter demonstrates the StatefulWidget pattern. The _count variable lives in the State object. Calling setState() triggers a rebuild, and Flutter efficiently updates only the Text widget that displays the count."
                    ),
                ],
                keyTakeaways: [
                    "Everything in Flutter's UI is a widget, and widgets are composed into a tree that the framework diffs efficiently.",
                    "Use StatelessWidget when UI depends only on input parameters; use StatefulWidget when the UI changes over time.",
                    "Layout widgets like Column, Row, and Stack are the building blocks for arranging UI elements on screen.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_widgets_1_1",
                        question: "When should you use a StatefulWidget instead of a StatelessWidget?",
                        options: [
                            "When the widget has many children",
                            "When the widget needs to change its appearance over time",
                            "When the widget uses const constructors",
                            "When the widget is at the root of the app",
                        ],
                        correctAnswer: 1,
                        explanation: "StatefulWidget is used when the widget has mutable state that changes during its lifetime, causing the UI to rebuild. If the UI is static given its inputs, StatelessWidget is sufficient."
                    ),
                    QuizQuestion(
                        id: "qq_widgets_1_2",
                        question: "What does calling setState() do in Flutter?",
                        options: [
                            "Immediately repaints the screen",
                            "Marks the widget as dirty and schedules a rebuild",
                            "Sends a notification to all child widgets",
                            "Persists the state to disk",
                        ],
                        correctAnswer: 1,
                        explanation: "setState() marks the widget as needing a rebuild. The framework will call the build() method again on the next frame, and the new widget tree is diffed against the old one to determine the minimal set of changes."
                    ),
                ],
                tags: ["flutter", "widgets", "stateless", "stateful", "layout"],
                orderIndex: 1
            ),

            Lesson(
                id: "lesson_flutter_state_1",
                track: .flutter,
                topic: "state_management",
                title: "State Management in Flutter",
                difficulty: .medium,
                content: [
                    LessonSection(
                        id: "ls_state_1_1",
                        heading: "The State Management Problem",
                        body: "As Flutter apps grow, managing state that multiple widgets need to access becomes challenging. Passing data down through constructor parameters (prop drilling) quickly becomes unwieldy. Flutter and its ecosystem offer several approaches to solve this: InheritedWidget (built-in), Provider, Riverpod, Bloc, and others. The right choice depends on app complexity and team preferences.",
                        codeSnippet: nil
                    ),
                    LessonSection(
                        id: "ls_state_1_2",
                        heading: "Provider Pattern",
                        body: "Provider is the officially recommended state management solution for Flutter. It wraps InheritedWidget to make it easier to use and more reusable. You create a ChangeNotifier class that holds your state and notifies listeners when it changes. Then you place a ChangeNotifierProvider in the widget tree above the widgets that need the state. Consumers rebuild automatically when the state changes.",
                        codeSnippet: "class CartModel extends ChangeNotifier {\n  final List<Item> _items = [];\n  List<Item> get items => List.unmodifiable(_items);\n  double get totalPrice =>\n      _items.fold(0, (sum, item) => sum + item.price);\n\n  void add(Item item) {\n    _items.add(item);\n    notifyListeners();\n  }\n\n  void remove(Item item) {\n    _items.remove(item);\n    notifyListeners();\n  }\n}"
                    ),
                    LessonSection(
                        id: "ls_state_1_3",
                        heading: "Consuming Provider State",
                        body: "There are several ways to read Provider state. context.watch<T>() rebuilds the widget whenever T changes — use this in the build method. context.read<T>() reads the value once without subscribing to changes — use this in callbacks. Consumer widget provides a builder that rebuilds only the subtree that depends on the state, which is useful for performance optimization.",
                        codeSnippet: "// In the widget tree\nChangeNotifierProvider(\n  create: (_) => CartModel(),\n  child: MyApp(),\n)\n\n// Reading state\nWidget build(BuildContext context) {\n  final cart = context.watch<CartModel>();\n  return Text('Items: ${cart.items.length}');\n}\n\n// In a callback (no rebuild needed)\nElevatedButton(\n  onPressed: () => context.read<CartModel>().add(item),\n  child: Text('Add to Cart'),\n)"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_state_1_1",
                        title: "Complete Provider Example",
                        code: "// model\nclass CounterModel extends ChangeNotifier {\n  int _count = 0;\n  int get count => _count;\n\n  void increment() {\n    _count++;\n    notifyListeners();\n  }\n}\n\n// main\nvoid main() {\n  runApp(\n    ChangeNotifierProvider(\n      create: (_) => CounterModel(),\n      child: MaterialApp(home: CounterPage()),\n    ),\n  );\n}\n\n// page\nclass CounterPage extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    final counter = context.watch<CounterModel>();\n    return Scaffold(\n      body: Center(child: Text('${counter.count}')),\n      floatingActionButton: FloatingActionButton(\n        onPressed: () => context.read<CounterModel>().increment(),\n        child: Icon(Icons.add),\n      ),\n    );\n  }\n}",
                        language: "dart",
                        explanation: "This end-to-end example shows the Provider pattern: define a ChangeNotifier model, provide it at the top of the widget tree, watch it for reactive rebuilds in the build method, and read it without listening in callbacks."
                    ),
                ],
                keyTakeaways: [
                    "State management solutions prevent prop drilling and make shared state accessible anywhere in the widget tree.",
                    "Provider wraps InheritedWidget and uses ChangeNotifier to reactively rebuild only the widgets that depend on changed state.",
                    "Use context.watch() in build methods for reactive rebuilds and context.read() in callbacks to avoid unnecessary rebuilds.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_state_1_1",
                        question: "What method must you call on a ChangeNotifier to trigger UI rebuilds?",
                        options: [
                            "setState()",
                            "notifyListeners()",
                            "rebuild()",
                            "update()",
                        ],
                        correctAnswer: 1,
                        explanation: "ChangeNotifier uses the notifyListeners() method to inform all registered listeners (including Provider's Consumer widgets) that the state has changed and they should rebuild."
                    ),
                    QuizQuestion(
                        id: "qq_state_1_2",
                        question: "When should you use context.read() instead of context.watch()?",
                        options: [
                            "Inside the build method",
                            "When you need the widget to rebuild on changes",
                            "Inside event handlers and callbacks",
                            "When using StatefulWidget",
                        ],
                        correctAnswer: 2,
                        explanation: "context.read() accesses the provider value without subscribing to changes. Use it in callbacks (like onPressed) where you want to perform an action but don't need the widget to rebuild when the value changes."
                    ),
                ],
                tags: ["flutter", "state-management", "provider", "changenotifier"],
                orderIndex: 2
            ),

            // ───────────────────────────────────────────────
            // SWIFT / iOS
            // ───────────────────────────────────────────────

            Lesson(
                id: "lesson_swift_basics_1",
                track: .swift,
                topic: "swift_basics",
                title: "Swift Language Essentials",
                difficulty: .easy,
                content: [
                    LessonSection(
                        id: "ls_swift_1_1",
                        heading: "Optionals and Unwrapping",
                        body: "Swift uses optionals to represent values that may be absent. An optional type is declared with a question mark (String?). Before you can use the underlying value, you must unwrap it. Swift provides several safe unwrapping mechanisms: optional binding (if let / guard let), optional chaining (?.), and the nil-coalescing operator (??). Forced unwrapping (!) should be used sparingly as it causes a runtime crash if the value is nil.",
                        codeSnippet: "var name: String? = \"Alice\"\n\n// Optional binding\nif let unwrapped = name {\n    print(unwrapped)\n}\n\n// Guard let (early exit)\nfunc greet(_ name: String?) {\n    guard let name else { return }\n    print(\"Hello, \\(name)!\")\n}\n\n// Nil-coalescing\nlet displayName = name ?? \"Anonymous\""
                    ),
                    LessonSection(
                        id: "ls_swift_1_2",
                        heading: "Value Types vs Reference Types",
                        body: "Swift differentiates between value types (struct, enum, tuple) and reference types (class). Value types are copied when assigned or passed, so each variable holds its own independent copy. Reference types are shared — multiple variables can point to the same instance. Structs are preferred in Swift for most data models because they are safer in concurrent code (no shared mutable state) and the compiler can optimize them aggressively.",
                        codeSnippet: "struct Point {\n    var x: Double\n    var y: Double\n}\n\nvar a = Point(x: 1, y: 2)\nvar b = a       // b is an independent copy\nb.x = 10\nprint(a.x)      // 1 — a is unchanged\n\nclass Node {\n    var value: Int\n    init(value: Int) { self.value = value }\n}\n\nlet n1 = Node(value: 1)\nlet n2 = n1     // n2 points to the same instance\nn2.value = 99\nprint(n1.value)  // 99 — shared reference"
                    ),
                    LessonSection(
                        id: "ls_swift_1_3",
                        heading: "Protocols and Protocol-Oriented Programming",
                        body: "Protocols define a blueprint of methods, properties, and requirements. Any type (class, struct, or enum) can adopt a protocol by providing the required implementations. Protocol extensions let you add default implementations, enabling powerful code reuse without inheritance. Swift's standard library is built heavily on protocols (Equatable, Hashable, Codable), and protocol-oriented programming is considered a core Swift paradigm.",
                        codeSnippet: "protocol Describable {\n    var description: String { get }\n}\n\nextension Describable {\n    var description: String { \"No description\" }\n}\n\nstruct Car: Describable {\n    let make: String\n    var description: String { \"Car: \\(make)\" }\n}"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_swift_1_1",
                        title: "Enums with Associated Values",
                        code: "enum NetworkResult {\n    case success(Data)\n    case failure(Error)\n}\n\nfunc handle(_ result: NetworkResult) {\n    switch result {\n    case .success(let data):\n        print(\"Received \\(data.count) bytes\")\n    case .failure(let error):\n        print(\"Error: \\(error.localizedDescription)\")\n    }\n}",
                        language: "swift",
                        explanation: "Swift enums can carry associated values, making them ideal for modeling states with attached data. Pattern matching with switch exhaustively handles each case, and the compiler ensures you never forget a case."
                    ),
                    CodeExample(
                        id: "ce_swift_1_2",
                        title: "Protocol Conformance with Codable",
                        code: "struct User: Codable {\n    let id: Int\n    let name: String\n    let email: String\n}\n\n// Encode to JSON\nlet user = User(id: 1, name: \"Alice\", email: \"alice@example.com\")\nlet data = try JSONEncoder().encode(user)\n\n// Decode from JSON\nlet decoded = try JSONDecoder().decode(User.self, from: data)\nprint(decoded.name) // Alice",
                        language: "swift",
                        explanation: "Codable is a protocol that combines Encodable and Decodable. When your struct's properties are all Codable, Swift auto-synthesizes the implementation — no manual parsing code needed."
                    ),
                ],
                keyTakeaways: [
                    "Optionals make nil handling explicit; prefer if let, guard let, and ?? over force-unwrapping.",
                    "Prefer structs (value types) over classes for data models — they are safer, especially in concurrent code.",
                    "Protocols with default implementations enable code reuse without the complexity of class inheritance.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_swift_1_1",
                        question: "What happens if you force-unwrap a nil optional with the ! operator?",
                        options: [
                            "It returns a default value",
                            "It returns nil",
                            "The app crashes at runtime",
                            "The compiler raises an error",
                        ],
                        correctAnswer: 2,
                        explanation: "Force-unwrapping a nil optional with ! triggers a fatalError at runtime, crashing the app. Always prefer safe unwrapping techniques like if let or guard let."
                    ),
                    QuizQuestion(
                        id: "qq_swift_1_2",
                        question: "What is the key difference between a struct and a class in Swift?",
                        options: [
                            "Structs can have methods, classes cannot",
                            "Structs are value types, classes are reference types",
                            "Classes are faster than structs",
                            "Structs support inheritance, classes do not",
                        ],
                        correctAnswer: 1,
                        explanation: "Structs are value types (copied on assignment) while classes are reference types (shared via pointers). Both can have methods, properties, and conform to protocols, but only classes support inheritance."
                    ),
                ],
                tags: ["swift", "optionals", "value-types", "protocols"],
                orderIndex: 0
            ),

            Lesson(
                id: "lesson_swift_swiftui_1",
                track: .swift,
                topic: "swiftui",
                title: "SwiftUI Fundamentals",
                difficulty: .medium,
                content: [
                    LessonSection(
                        id: "ls_swiftui_1_1",
                        heading: "Declarative UI with SwiftUI",
                        body: "SwiftUI is Apple's declarative UI framework. Instead of imperatively creating and mutating views, you describe what the UI should look like for any given state. SwiftUI views are lightweight structs conforming to the View protocol, each with a body property that returns some View. When state changes, SwiftUI automatically computes the difference and updates only what changed.",
                        codeSnippet: "struct ContentView: View {\n    var body: some View {\n        VStack(spacing: 16) {\n            Image(systemName: \"swift\")\n                .font(.largeTitle)\n                .foregroundStyle(.orange)\n            Text(\"Hello, SwiftUI!\")\n                .font(.title)\n        }\n        .padding()\n    }\n}"
                    ),
                    LessonSection(
                        id: "ls_swiftui_1_2",
                        heading: "State and Binding",
                        body: "@State is a property wrapper that tells SwiftUI to manage a piece of state for you. When the state value changes, the view automatically re-renders. @Binding creates a two-way connection to a @State property owned by a parent view, allowing child views to read and write the parent's state. For complex or shared state, @StateObject and @ObservedObject connect views to ObservableObject classes.",
                        codeSnippet: "struct ToggleView: View {\n    @State private var isOn = false\n\n    var body: some View {\n        VStack {\n            Toggle(\"Enable\", isOn: $isOn)\n            Text(isOn ? \"Enabled\" : \"Disabled\")\n        }\n    }\n}"
                    ),
                    LessonSection(
                        id: "ls_swiftui_1_3",
                        heading: "Modifiers and Composition",
                        body: "SwiftUI uses modifier methods to configure views. Each modifier returns a new view wrapping the original. The order of modifiers matters because each one wraps the previous result. For example, adding padding before a background gives a different result than adding it after. SwiftUI encourages extracting reusable view components into their own structs for clarity and reuse.",
                        codeSnippet: "Text(\"Important\")\n    .font(.headline)\n    .padding()\n    .background(Color.yellow)\n    .cornerRadius(8)"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_swiftui_1_1",
                        title: "List with Navigation",
                        code: "struct FruitListView: View {\n    let fruits = [\"Apple\", \"Banana\", \"Cherry\"]\n\n    var body: some View {\n        NavigationStack {\n            List(fruits, id: \\.self) { fruit in\n                NavigationLink(fruit) {\n                    Text(\"You selected \\(fruit)\")\n                        .font(.largeTitle)\n                }\n            }\n            .navigationTitle(\"Fruits\")\n        }\n    }\n}",
                        language: "swift",
                        explanation: "NavigationStack provides a navigation container. List creates a scrollable list, and NavigationLink pushes a destination view when tapped. The id: \\.self parameter tells SwiftUI to use each string as its own identifier."
                    ),
                    CodeExample(
                        id: "ce_swiftui_1_2",
                        title: "Custom View with Binding",
                        code: "struct RatingView: View {\n    @Binding var rating: Int\n    let maxRating: Int = 5\n\n    var body: some View {\n        HStack {\n            ForEach(1...maxRating, id: \\.self) { index in\n                Image(systemName: index <= rating ? \"star.fill\" : \"star\")\n                    .foregroundStyle(.yellow)\n                    .onTapGesture { rating = index }\n            }\n        }\n    }\n}\n\n// Usage:\nstruct ParentView: View {\n    @State private var myRating = 3\n    var body: some View {\n        RatingView(rating: $myRating)\n    }\n}",
                        language: "swift",
                        explanation: "@Binding allows a child view to read and write a parent's @State property. The $ prefix creates a binding from a @State variable. This pattern is fundamental for building reusable SwiftUI components."
                    ),
                ],
                keyTakeaways: [
                    "@State manages local view state and triggers re-renders automatically; @Binding lets child views modify parent state.",
                    "Modifier order matters in SwiftUI because each modifier wraps the previous view in a new layer.",
                    "SwiftUI views are lightweight structs — extract subviews freely to keep code organized without performance concerns.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_swiftui_1_1",
                        question: "What does the @State property wrapper do in SwiftUI?",
                        options: [
                            "Makes the property accessible globally",
                            "Tells SwiftUI to manage the value and re-render the view when it changes",
                            "Makes the property thread-safe",
                            "Persists the value to UserDefaults",
                        ],
                        correctAnswer: 1,
                        explanation: "@State tells SwiftUI to store the value separately from the struct and watch it for changes. When the value changes, SwiftUI re-invokes the body property to update the UI."
                    ),
                    QuizQuestion(
                        id: "qq_swiftui_1_2",
                        question: "How do you pass a two-way reference to a @State property to a child view?",
                        options: [
                            "Using the & prefix",
                            "Using the $ prefix to create a Binding",
                            "Using @Published",
                            "Using inout parameter",
                        ],
                        correctAnswer: 1,
                        explanation: "The $ prefix on a @State variable produces a Binding<T>, which you pass to a child view's @Binding property. This lets the child read and write the parent's state."
                    ),
                    QuizQuestion(
                        id: "qq_swiftui_1_3",
                        question: "Why does the order of SwiftUI modifiers matter?",
                        options: [
                            "It affects compilation speed",
                            "Later modifiers override earlier ones",
                            "Each modifier wraps the previous view, so visual layering changes",
                            "It does not matter — order is irrelevant",
                        ],
                        correctAnswer: 2,
                        explanation: "Each modifier creates a new view wrapping the previous one. For example, .padding().background(.blue) adds padding first, then fills the padded area with blue. Reversing the order would only fill the text's frame with blue, then add transparent padding."
                    ),
                ],
                tags: ["swift", "swiftui", "state", "binding", "declarative-ui"],
                orderIndex: 1
            ),

            Lesson(
                id: "lesson_swift_concurrency_1",
                track: .swift,
                topic: "concurrency",
                title: "Swift Concurrency with async/await",
                difficulty: .hard,
                content: [
                    LessonSection(
                        id: "ls_concurrency_1_1",
                        heading: "Introduction to async/await",
                        body: "Swift's structured concurrency model, introduced in Swift 5.5, replaces callback-based asynchronous code with async/await syntax. An async function can suspend execution at await points without blocking its thread. The compiler checks that you only call async functions from async contexts, preventing common concurrency mistakes. This makes asynchronous code read like synchronous code while remaining fully non-blocking.",
                        codeSnippet: "func fetchUser(id: Int) async throws -> User {\n    let url = URL(string: \"https://api.example.com/users/\\(id)\")!\n    let (data, _) = try await URLSession.shared.data(from: url)\n    return try JSONDecoder().decode(User.self, from: data)\n}"
                    ),
                    LessonSection(
                        id: "ls_concurrency_1_2",
                        heading: "Tasks and Structured Concurrency",
                        body: "A Task represents a unit of asynchronous work. Structured concurrency means child tasks are scoped to their parent — if the parent is cancelled, all children are cancelled too. async let enables concurrent execution of independent async operations. TaskGroup allows dynamic numbers of concurrent tasks. This structured approach prevents resource leaks and makes cancellation predictable.",
                        codeSnippet: "func loadDashboard() async throws -> Dashboard {\n    async let profile = fetchProfile()\n    async let posts = fetchPosts()\n    async let notifications = fetchNotifications()\n\n    // All three requests run concurrently\n    return try await Dashboard(\n        profile: profile,\n        posts: posts,\n        notifications: notifications\n    )\n}"
                    ),
                    LessonSection(
                        id: "ls_concurrency_1_3",
                        heading: "Actors and Data Safety",
                        body: "Actors are reference types that protect their mutable state from concurrent access. Only one task can execute an actor's methods at a time. Accessing an actor's properties or methods from outside requires await because the caller may need to wait for the actor to become available. The @MainActor attribute ensures code runs on the main thread, which is essential for UI updates. Swift's compiler enforces these rules at build time, eliminating data races.",
                        codeSnippet: "actor BankAccount {\n    private var balance: Double = 0\n\n    func deposit(_ amount: Double) {\n        balance += amount\n    }\n\n    func getBalance() -> Double {\n        balance\n    }\n}\n\n// Usage — requires await from outside\nlet account = BankAccount()\nawait account.deposit(100)\nlet balance = await account.getBalance()"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_concurrency_1_1",
                        title: "Using async/await in SwiftUI",
                        code: "struct UserView: View {\n    @State private var user: User?\n    @State private var error: Error?\n\n    var body: some View {\n        Group {\n            if let user {\n                Text(user.name)\n            } else if let error {\n                Text(error.localizedDescription)\n            } else {\n                ProgressView()\n            }\n        }\n        .task {\n            do {\n                user = try await fetchUser(id: 1)\n            } catch {\n                self.error = error\n            }\n        }\n    }\n}",
                        language: "swift",
                        explanation: "The .task modifier launches an async task tied to the view's lifecycle. It is automatically cancelled when the view disappears. Results update @State properties, which triggers a UI re-render on the main thread."
                    ),
                ],
                keyTakeaways: [
                    "async/await makes asynchronous code linear and readable while the compiler enforces correct usage at build time.",
                    "Structured concurrency (async let, TaskGroup) ensures child tasks are cancelled when their parent scope exits.",
                    "Actors protect mutable state from data races, and @MainActor ensures UI updates happen on the main thread.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_concurrency_1_1",
                        question: "What does 'async let' accomplish in Swift?",
                        options: [
                            "Makes a variable lazy",
                            "Starts an async operation immediately and concurrently",
                            "Creates a thread-safe variable",
                            "Declares a variable that will be set later",
                        ],
                        correctAnswer: 1,
                        explanation: "async let starts executing the right-hand side immediately and concurrently with the current task. You await the result only when you actually need the value, allowing multiple operations to run in parallel."
                    ),
                    QuizQuestion(
                        id: "qq_concurrency_1_2",
                        question: "What problem do actors solve in Swift?",
                        options: [
                            "Memory management",
                            "Data races on shared mutable state",
                            "Slow network requests",
                            "Complex view hierarchies",
                        ],
                        correctAnswer: 1,
                        explanation: "Actors ensure that only one task accesses their mutable state at a time, preventing data races. The Swift compiler enforces this by requiring await when accessing actor members from outside the actor's isolation context."
                    ),
                ],
                tags: ["swift", "concurrency", "async-await", "actors", "structured-concurrency"],
                orderIndex: 2
            ),

            // ───────────────────────────────────────────────
            // GENERAL
            // ───────────────────────────────────────────────

            Lesson(
                id: "lesson_general_oop_1",
                track: .general,
                topic: "oop",
                title: "Object-Oriented Programming Principles",
                difficulty: .easy,
                content: [
                    LessonSection(
                        id: "ls_oop_1_1",
                        heading: "The Four Pillars of OOP",
                        body: "Object-oriented programming rests on four principles: Encapsulation, Abstraction, Inheritance, and Polymorphism. Encapsulation bundles data and methods together, hiding internal state behind a public interface. Abstraction hides complex implementation details and exposes only what is necessary. Inheritance lets a class derive from another, reusing and extending its behavior. Polymorphism allows objects of different types to be treated uniformly through a shared interface.",
                        codeSnippet: nil
                    ),
                    LessonSection(
                        id: "ls_oop_1_2",
                        heading: "Encapsulation and Access Control",
                        body: "Encapsulation protects an object's internal state from unintended modification. Both Swift and Dart provide access modifiers. In Swift, you use private, fileprivate, internal (default), and public. In Dart, prefixing a name with an underscore (_) makes it library-private. Good encapsulation means exposing only what external code needs and keeping everything else private.",
                        codeSnippet: "// Swift example\nclass BankAccount {\n    private var balance: Double = 0\n\n    func deposit(_ amount: Double) {\n        guard amount > 0 else { return }\n        balance += amount\n    }\n\n    func getBalance() -> Double {\n        return balance\n    }\n}"
                    ),
                    LessonSection(
                        id: "ls_oop_1_3",
                        heading: "Polymorphism in Practice",
                        body: "Polymorphism means 'many forms.' It allows you to write code that works with a general type, and the correct specific behavior is invoked at runtime. In Swift, this is achieved through protocol conformance and method overriding. In Dart, abstract classes and method overriding serve the same purpose. Polymorphism is the foundation of the Strategy, Observer, and many other design patterns.",
                        codeSnippet: "// Swift protocol polymorphism\nprotocol Shape {\n    func area() -> Double\n}\n\nstruct Circle: Shape {\n    let radius: Double\n    func area() -> Double { .pi * radius * radius }\n}\n\nstruct Rectangle: Shape {\n    let width, height: Double\n    func area() -> Double { width * height }\n}\n\nfunc printArea(_ shape: Shape) {\n    print(\"Area: \\(shape.area())\")\n}"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_oop_1_1",
                        title: "Inheritance vs Composition",
                        code: "// Inheritance (is-a relationship)\nclass Animal {\n    func speak() -> String { \"...\" }\n}\nclass Dog: Animal {\n    override func speak() -> String { \"Woof!\" }\n}\n\n// Composition (has-a relationship) — often preferred\nprotocol SoundMaker {\n    func makeSound() -> String\n}\nstruct BarkSound: SoundMaker {\n    func makeSound() -> String { \"Woof!\" }\n}\nstruct Pet {\n    let name: String\n    let soundMaker: SoundMaker\n}",
                        language: "swift",
                        explanation: "Inheritance creates tight coupling. Composition via protocols is more flexible — you can swap behaviors at runtime and avoid deep inheritance hierarchies. The general guideline is to favor composition over inheritance."
                    ),
                ],
                keyTakeaways: [
                    "The four OOP pillars — encapsulation, abstraction, inheritance, and polymorphism — work together to create modular, maintainable code.",
                    "Favor composition over inheritance to achieve flexible, loosely coupled designs.",
                    "Polymorphism through protocols/interfaces lets you write generic code that works with any conforming type.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_oop_1_1",
                        question: "Which OOP principle involves hiding internal implementation details behind a public interface?",
                        options: [
                            "Inheritance",
                            "Polymorphism",
                            "Encapsulation",
                            "Abstraction",
                        ],
                        correctAnswer: 2,
                        explanation: "Encapsulation bundles data and methods together and restricts direct access to internal state. External code interacts only through the public interface, protecting invariants."
                    ),
                    QuizQuestion(
                        id: "qq_oop_1_2",
                        question: "Why is composition often preferred over inheritance?",
                        options: [
                            "Composition is faster at runtime",
                            "Composition creates more flexible and loosely coupled designs",
                            "Inheritance is deprecated in modern languages",
                            "Composition uses less memory",
                        ],
                        correctAnswer: 1,
                        explanation: "Composition allows you to combine small, focused behaviors and swap them at runtime. Inheritance creates tight coupling between parent and child classes, making changes to the parent risky."
                    ),
                ],
                tags: ["oop", "encapsulation", "polymorphism", "inheritance", "composition"],
                orderIndex: 0
            ),

            Lesson(
                id: "lesson_general_design_patterns_1",
                track: .general,
                topic: "design_patterns",
                title: "Essential Design Patterns",
                difficulty: .medium,
                content: [
                    LessonSection(
                        id: "ls_dp_1_1",
                        heading: "What Are Design Patterns?",
                        body: "Design patterns are proven, reusable solutions to common software design problems. They are not ready-to-use code but rather templates for solving recurring challenges. The Gang of Four (GoF) categorized them into three groups: Creational (how objects are created), Structural (how objects are composed), and Behavioral (how objects communicate). Understanding patterns helps you communicate design ideas clearly and recognize established solutions.",
                        codeSnippet: nil
                    ),
                    LessonSection(
                        id: "ls_dp_1_2",
                        heading: "Singleton Pattern",
                        body: "The Singleton pattern ensures a class has only one instance and provides a global access point to it. It is commonly used for services like logging, analytics, and network managers. However, singletons can make testing difficult because they introduce global state. In modern development, dependency injection is often preferred over singletons for better testability.",
                        codeSnippet: "// Swift Singleton\nclass AnalyticsService {\n    static let shared = AnalyticsService()\n    private init() {} // Prevent external instantiation\n\n    func track(_ event: String) {\n        print(\"Tracked: \\(event)\")\n    }\n}"
                    ),
                    LessonSection(
                        id: "ls_dp_1_3",
                        heading: "Observer Pattern",
                        body: "The Observer pattern defines a one-to-many dependency between objects. When one object (the subject) changes state, all its dependents (observers) are notified automatically. This pattern is foundational to reactive programming. In Swift, Combine and the @Observable macro implement the observer pattern. In Flutter, ChangeNotifier and streams serve the same purpose. It decouples the subject from its observers, making the system more modular.",
                        codeSnippet: "// Dart Observer pattern with ChangeNotifier\nclass ThemeModel extends ChangeNotifier {\n  bool _isDark = false;\n  bool get isDark => _isDark;\n\n  void toggle() {\n    _isDark = !_isDark;\n    notifyListeners(); // Notify all observers\n  }\n}"
                    ),
                ],
                codeExamples: [
                    CodeExample(
                        id: "ce_dp_1_1",
                        title: "Strategy Pattern",
                        code: "// Define strategy interface\nprotocol SortStrategy {\n    func sort(_ array: inout [Int])\n}\n\nstruct QuickSort: SortStrategy {\n    func sort(_ array: inout [Int]) {\n        // Quick sort implementation\n        array.sort() // simplified\n    }\n}\n\nstruct MergeSort: SortStrategy {\n    func sort(_ array: inout [Int]) {\n        // Merge sort implementation\n        array.sort() // simplified\n    }\n}\n\n// Context that uses the strategy\nclass Sorter {\n    var strategy: SortStrategy\n    init(strategy: SortStrategy) {\n        self.strategy = strategy\n    }\n    func sort(_ array: inout [Int]) {\n        strategy.sort(&array)\n    }\n}",
                        language: "swift",
                        explanation: "The Strategy pattern defines a family of algorithms, encapsulates each one, and makes them interchangeable. The Sorter class delegates sorting to a strategy object, and you can swap algorithms at runtime without changing the calling code."
                    ),
                    CodeExample(
                        id: "ce_dp_1_2",
                        title: "Factory Pattern in Dart",
                        code: "abstract class Notification {\n  String get message;\n  void send();\n\n  factory Notification(String type, String msg) {\n    switch (type) {\n      case 'email':\n        return EmailNotification(msg);\n      case 'push':\n        return PushNotification(msg);\n      default:\n        throw ArgumentError('Unknown type: $type');\n    }\n  }\n}\n\nclass EmailNotification implements Notification {\n  @override\n  final String message;\n  EmailNotification(this.message);\n  @override\n  void send() => print('Email: $message');\n}\n\nclass PushNotification implements Notification {\n  @override\n  final String message;\n  PushNotification(this.message);\n  @override\n  void send() => print('Push: $message');\n}",
                        language: "dart",
                        explanation: "The Factory pattern centralizes object creation. Dart's factory constructors are a natural fit — the caller uses Notification('email', 'Hello') without knowing which concrete class is instantiated. This makes it easy to add new notification types without modifying calling code."
                    ),
                ],
                keyTakeaways: [
                    "Design patterns are reusable solutions to common problems — know the major ones (Singleton, Observer, Strategy, Factory) and when to apply them.",
                    "Singletons provide global access but can hinder testability; prefer dependency injection when possible.",
                    "The Observer pattern decouples subjects from observers and underpins reactive frameworks like Combine and Provider.",
                ],
                miniQuiz: [
                    QuizQuestion(
                        id: "qq_dp_1_1",
                        question: "Which design pattern ensures a class has only one instance?",
                        options: [
                            "Factory",
                            "Observer",
                            "Singleton",
                            "Strategy",
                        ],
                        correctAnswer: 2,
                        explanation: "The Singleton pattern restricts instantiation to a single instance and provides global access to it. In Swift, this is typically implemented with a static let shared property and a private init."
                    ),
                    QuizQuestion(
                        id: "qq_dp_1_2",
                        question: "What is the primary benefit of the Strategy pattern?",
                        options: [
                            "Ensures only one instance exists",
                            "Allows swapping algorithms at runtime without changing client code",
                            "Creates objects without specifying exact classes",
                            "Manages object lifecycle automatically",
                        ],
                        correctAnswer: 1,
                        explanation: "The Strategy pattern encapsulates algorithms behind a common interface, letting you swap implementations at runtime. The client code depends on the interface, not the concrete implementation."
                    ),
                    QuizQuestion(
                        id: "qq_dp_1_3",
                        question: "Which GoF category does the Observer pattern belong to?",
                        options: [
                            "Creational",
                            "Structural",
                            "Behavioral",
                            "Architectural",
                        ],
                        correctAnswer: 2,
                        explanation: "The Observer pattern is a Behavioral pattern because it defines how objects communicate — specifically, how a subject notifies multiple observers of state changes."
                    ),
                ],
                tags: ["design-patterns", "singleton", "observer", "strategy", "factory"],
                orderIndex: 1
            ),
        ]
    }

    // MARK: - Sample Exercises

    static var sampleExercises: [Exercise] {
        [
            // ── MCQ Exercises (8) ────────────────────────────

            Exercise(
                id: "ex_mcq_flutter_1",
                track: .flutter,
                topic: "widgets",
                type: .mcq,
                difficulty: .easy,
                title: "Widget Lifecycle",
                question: "Which method is called when a StatefulWidget is inserted into the widget tree for the first time?",
                codeSnippet: nil,
                options: ["build()", "initState()", "didChangeDependencies()", "dispose()"],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "initState() is called exactly once when the State object is first created. It runs before the first build() call and is the right place to initialize state that depends on the context or perform one-time setup.",
                xp: 10,
                tags: ["flutter", "widgets", "lifecycle"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 0
            ),

            Exercise(
                id: "ex_mcq_flutter_2",
                track: .flutter,
                topic: "state_management",
                type: .mcq,
                difficulty: .medium,
                title: "Provider Reading Methods",
                question: "In Flutter's Provider package, which method should you use inside a button's onPressed callback to access a provider without subscribing to changes?",
                codeSnippet: nil,
                options: ["context.watch<T>()", "context.read<T>()", "context.select<T, R>()", "Provider.of<T>(context)"],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "context.read<T>() reads the provider value once without subscribing to changes. It should be used in callbacks (like onPressed) where you want to trigger an action but do not need the widget to rebuild when the provider changes.",
                xp: 15,
                tags: ["flutter", "provider", "state-management"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 1
            ),

            Exercise(
                id: "ex_mcq_swift_1",
                track: .swift,
                topic: "swift_basics",
                type: .mcq,
                difficulty: .easy,
                title: "Optional Unwrapping",
                question: "Which is the safest way to unwrap an optional in Swift?",
                codeSnippet: nil,
                options: [
                    "Force unwrapping with !",
                    "Using if let or guard let",
                    "Implicitly unwrapped optionals",
                    "Type casting with as!",
                ],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "if let and guard let are the safest optional unwrapping techniques because they handle the nil case explicitly without risking a runtime crash. Force unwrapping (!) crashes if the value is nil.",
                xp: 10,
                tags: ["swift", "optionals", "safety"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 2
            ),

            Exercise(
                id: "ex_mcq_swift_2",
                track: .swift,
                topic: "swiftui",
                type: .mcq,
                difficulty: .medium,
                title: "SwiftUI Property Wrappers",
                question: "Which property wrapper should you use in SwiftUI to create a two-way connection to a @State property owned by a parent view?",
                codeSnippet: nil,
                options: ["@State", "@Binding", "@ObservedObject", "@Environment"],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "@Binding creates a two-way connection to a source of truth owned by another view. The parent passes it using the $ prefix (e.g., $myState), and the child can read and modify the value through the binding.",
                xp: 15,
                tags: ["swift", "swiftui", "property-wrappers"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 3
            ),

            Exercise(
                id: "ex_mcq_swift_3",
                track: .swift,
                topic: "concurrency",
                type: .mcq,
                difficulty: .hard,
                title: "Swift Actors",
                question: "What is the primary purpose of actors in Swift concurrency?",
                codeSnippet: nil,
                options: [
                    "To run code on the main thread",
                    "To protect shared mutable state from data races",
                    "To cancel long-running tasks",
                    "To decode JSON data asynchronously",
                ],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "Actors are reference types that serialize access to their mutable state, ensuring only one task can access the state at a time. This eliminates data races by design and is enforced by the Swift compiler.",
                xp: 20,
                tags: ["swift", "concurrency", "actors"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 4
            ),

            Exercise(
                id: "ex_mcq_general_1",
                track: .general,
                topic: "oop",
                type: .mcq,
                difficulty: .easy,
                title: "OOP Pillars",
                question: "Which OOP principle allows objects of different classes to be treated through a shared interface?",
                codeSnippet: nil,
                options: ["Encapsulation", "Abstraction", "Inheritance", "Polymorphism"],
                correctAnswer: 3,
                correctAnswerBool: nil,
                explanation: "Polymorphism allows different types to be used interchangeably through a common interface. For example, a function accepting a Shape protocol can work with Circle, Rectangle, or any other conforming type.",
                xp: 10,
                tags: ["oop", "polymorphism"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 5
            ),

            Exercise(
                id: "ex_mcq_general_2",
                track: .general,
                topic: "design_patterns",
                type: .mcq,
                difficulty: .medium,
                title: "Design Pattern Categories",
                question: "The Factory pattern belongs to which category of GoF design patterns?",
                codeSnippet: nil,
                options: ["Behavioral", "Structural", "Creational", "Architectural"],
                correctAnswer: 2,
                correctAnswerBool: nil,
                explanation: "The Factory pattern is a Creational pattern because it deals with object creation. It provides an interface for creating objects without specifying the exact class to instantiate.",
                xp: 15,
                tags: ["design-patterns", "factory", "gof"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 6
            ),

            Exercise(
                id: "ex_mcq_flutter_3",
                track: .flutter,
                topic: "dart_basics",
                type: .mcq,
                difficulty: .medium,
                title: "Dart Async Programming",
                question: "What does the 'await' keyword do in Dart?",
                codeSnippet: "Future<String> fetchData() async {\n  final response = await http.get(Uri.parse(url));\n  return response.body;\n}",
                options: [
                    "Blocks the current thread until the Future completes",
                    "Suspends the function execution until the Future completes, without blocking the thread",
                    "Creates a new isolate for the Future",
                    "Converts a synchronous function to asynchronous",
                ],
                correctAnswer: 1,
                correctAnswerBool: nil,
                explanation: "await suspends the current async function until the Future completes, but it does NOT block the thread. Other code can continue running on the same event loop. This is fundamental to Dart's single-threaded concurrency model.",
                xp: 15,
                tags: ["dart", "async", "future"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 7
            ),

            // ── True/False & Swipe Exercises (4) ─────────────

            Exercise(
                id: "ex_tf_flutter_1",
                track: .flutter,
                topic: "widgets",
                type: .trueFalse,
                difficulty: .easy,
                title: "Widget Immutability",
                question: "In Flutter, widgets are mutable objects that change their properties when the UI updates.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: false,
                explanation: "Widgets in Flutter are immutable. When the UI needs to change, Flutter creates a new widget instance rather than mutating the existing one. The framework then diffs the new and old widget trees to determine the minimal set of changes to apply to the render tree.",
                xp: 10,
                tags: ["flutter", "widgets", "immutability"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 8
            ),

            Exercise(
                id: "ex_tf_swift_1",
                track: .swift,
                topic: "swift_basics",
                type: .trueFalse,
                difficulty: .easy,
                title: "Swift Structs and Inheritance",
                question: "In Swift, structs support inheritance just like classes.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: false,
                explanation: "Structs in Swift do NOT support inheritance. Only classes support inheritance. However, both structs and classes can conform to protocols, which provides a form of polymorphism without inheritance.",
                xp: 10,
                tags: ["swift", "structs", "inheritance"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 9
            ),

            Exercise(
                id: "ex_swipe_swift_1",
                track: .swift,
                topic: "concurrency",
                type: .swipe,
                difficulty: .medium,
                title: "MainActor Requirement",
                question: "In Swift, all UI updates must be performed on the main thread, which @MainActor helps enforce at compile time.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: true,
                explanation: "@MainActor is a global actor that ensures code runs on the main thread. UIKit and SwiftUI require UI updates on the main thread. @MainActor lets the compiler verify this at build time, preventing runtime issues where UI updates happen on background threads.",
                xp: 15,
                tags: ["swift", "concurrency", "main-actor"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 10
            ),

            Exercise(
                id: "ex_swipe_general_1",
                track: .general,
                topic: "design_patterns",
                type: .swipe,
                difficulty: .easy,
                title: "Singleton Thread Safety",
                question: "The Singleton pattern guarantees thread safety by default in all programming languages.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: false,
                explanation: "The Singleton pattern does NOT guarantee thread safety by default. Thread-safe singletons require additional mechanisms like dispatch_once (Objective-C), static let (Swift, which IS thread-safe), or synchronized blocks (Java). In Swift, using 'static let shared = ...' is inherently thread-safe because Swift guarantees static properties are lazily initialized exactly once.",
                xp: 10,
                tags: ["design-patterns", "singleton", "thread-safety"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 11
            ),

            // ── Fill in the Blank Exercises (3) ──────────────

            Exercise(
                id: "ex_fill_flutter_1",
                track: .flutter,
                topic: "widgets",
                type: .fillBlank,
                difficulty: .easy,
                title: "StatelessWidget Build Method",
                question: "Complete the StatelessWidget implementation.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "A StatelessWidget requires overriding the build method which takes a BuildContext parameter and returns a Widget. The @override annotation indicates that you are implementing a method from the superclass.",
                xp: 10,
                tags: ["flutter", "widgets", "stateless"],
                codeTemplate: "class MyWidget extends ___ {\n  const MyWidget({super.key});\n\n  @override\n  Widget ___(___ context) {\n    return Text('Hello');\n  }\n}",
                blanks: ["___", "___", "___"],
                correctTokens: ["StatelessWidget", "build", "BuildContext"],
                wordBank: ["StatelessWidget", "StatefulWidget", "build", "create", "BuildContext", "State", "Widget"],
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 12
            ),

            Exercise(
                id: "ex_fill_swift_1",
                track: .swift,
                topic: "swiftui",
                type: .fillBlank,
                difficulty: .medium,
                title: "SwiftUI View with State",
                question: "Complete the SwiftUI view that uses state to toggle visibility.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "@State is used for local mutable state in SwiftUI. The $ prefix creates a Binding, and the body property uses 'some View' as its return type to enable opaque return types.",
                xp: 15,
                tags: ["swift", "swiftui", "state"],
                codeTemplate: "struct ToggleView: View {\n  ___ private var isVisible = true\n\n  var body: ___ View {\n    VStack {\n      Toggle(\"Show Text\", isOn: ___isVisible)\n      if isVisible {\n        Text(\"Hello!\")\n      }\n    }\n  }\n}",
                blanks: ["___", "___", "___"],
                correctTokens: ["@State", "some", "$"],
                wordBank: ["@State", "@Binding", "@Published", "some", "any", "AnyView", "$", "&", "@"],
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 13
            ),

            Exercise(
                id: "ex_fill_dart_1",
                track: .flutter,
                topic: "dart_basics",
                type: .fillBlank,
                difficulty: .medium,
                title: "Dart Null Safety",
                question: "Complete the code to safely handle nullable values.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "String? declares a nullable type. The ?. operator safely accesses members on a nullable value (returns null if the receiver is null). The ?? operator provides a fallback value when the left side is null.",
                xp: 15,
                tags: ["dart", "null-safety"],
                codeTemplate: "String___ name = getUserName();\nfinal length = name___length;\nfinal display = name ___ 'Anonymous';",
                blanks: ["___", "___", "___"],
                correctTokens: ["?", "?.", "??"],
                wordBank: ["?", "!", "?.", "!.", "??", "||", "&&"],
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 14
            ),

            // ── Reorder Exercises (2) ────────────────────────

            Exercise(
                id: "ex_reorder_swift_1",
                track: .swift,
                topic: "swift_basics",
                type: .reorder,
                difficulty: .medium,
                title: "Swift Network Request",
                question: "Arrange the lines to create a valid async function that fetches and decodes JSON.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "A Swift async throwing function first defines the signature, creates the URL, performs the network request with try await, decodes the response, and returns the result. The order follows a natural top-down data flow.",
                xp: 15,
                tags: ["swift", "networking", "async"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: [
                    "let user = try JSONDecoder().decode(User.self, from: data)",
                    "func fetchUser() async throws -> User {",
                    "return user",
                    "let (data, _) = try await URLSession.shared.data(from: url)",
                    "let url = URL(string: \"https://api.example.com/user\")!",
                    "}",
                ],
                correctOrder: [1, 4, 3, 0, 2, 5],
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 15
            ),

            Exercise(
                id: "ex_reorder_flutter_1",
                track: .flutter,
                topic: "widgets",
                type: .reorder,
                difficulty: .easy,
                title: "Flutter App Structure",
                question: "Arrange the lines to create a minimal Flutter app that displays 'Hello World'.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "A minimal Flutter app starts with the main() function calling runApp(), which takes a MaterialApp widget. The MaterialApp's home property is set to a Scaffold, which provides the basic screen structure. The Scaffold's body contains the content.",
                xp: 10,
                tags: ["flutter", "app-structure"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: [
                    "  body: Center(child: Text('Hello World')),",
                    "void main() => runApp(",
                    "  MaterialApp(",
                    "    home: Scaffold(",
                    "    ),",
                    "  ),",
                    ");",
                ],
                correctOrder: [1, 2, 3, 0, 4, 5, 6],
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 16
            ),

            // ── Match Pairs Exercise (1) ─────────────────────

            Exercise(
                id: "ex_match_general_1",
                track: .general,
                topic: "design_patterns",
                type: .matchPairs,
                difficulty: .medium,
                title: "Design Patterns and Their Purposes",
                question: "Match each design pattern with its primary purpose.",
                codeSnippet: nil,
                options: nil,
                correctAnswer: nil,
                correctAnswerBool: nil,
                explanation: "Singleton ensures one instance with global access. Observer notifies dependents of state changes. Factory creates objects without specifying exact classes. Strategy encapsulates interchangeable algorithms.",
                xp: 15,
                tags: ["design-patterns", "gof"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: ["Singleton", "Observer", "Factory", "Strategy"],
                rightColumn: ["Notify dependents of state changes", "Ensure a class has only one instance", "Encapsulate interchangeable algorithms", "Create objects without specifying exact classes"],
                correctPairs: [1, 0, 3, 2],
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 17
            ),

            // ── Predict Output Exercises (2) ─────────────────

            Exercise(
                id: "ex_predict_dart_1",
                track: .flutter,
                topic: "dart_basics",
                type: .predictOutput,
                difficulty: .medium,
                title: "Dart List Operations",
                question: "What does this code print?",
                codeSnippet: "void main() {\n  final numbers = [1, 2, 3, 4, 5];\n  final result = numbers\n      .where((n) => n.isOdd)\n      .map((n) => n * 10)\n      .toList();\n  print(result);\n}",
                options: ["[10, 30, 50]", "[20, 40]", "[10, 20, 30, 40, 50]", "[1, 3, 5]"],
                correctAnswer: 0,
                correctAnswerBool: nil,
                explanation: "First, where() filters to odd numbers: [1, 3, 5]. Then map() multiplies each by 10: [10, 30, 50]. The operations are chained and produce a new list without modifying the original.",
                xp: 15,
                tags: ["dart", "collections", "functional"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 18
            ),

            Exercise(
                id: "ex_predict_swift_1",
                track: .swift,
                topic: "swift_basics",
                type: .predictOutput,
                difficulty: .medium,
                title: "Swift Value Type Behavior",
                question: "What does this code print?",
                codeSnippet: "struct Counter {\n    var count = 0\n    mutating func increment() {\n        count += 1\n    }\n}\n\nvar a = Counter()\na.increment()\na.increment()\nvar b = a\nb.increment()\nprint(\"a: \\(a.count), b: \\(b.count)\")",
                options: ["a: 2, b: 3", "a: 3, b: 3", "a: 2, b: 2", "a: 3, b: 2"],
                correctAnswer: 0,
                correctAnswerBool: nil,
                explanation: "Counter is a struct (value type). After a.increment() twice, a.count is 2. 'var b = a' creates an independent copy with count = 2. b.increment() only affects b, making b.count = 3. a remains at 2.",
                xp: 15,
                tags: ["swift", "value-types", "structs"],
                codeTemplate: nil,
                blanks: nil,
                correctTokens: nil,
                wordBank: nil,
                shuffledLines: nil,
                correctOrder: nil,
                leftColumn: nil,
                rightColumn: nil,
                correctPairs: nil,
                bugLineIndex: nil,
                fixOptions: nil,
                correctFixIndex: nil,
                orderIndex: 19
            ),
        ]
    }

    // MARK: - Sample Interview Questions

    static var sampleInterviewQuestions: [InterviewQuestion] {
        [
            InterviewQuestion(
                id: "iq_flutter_1",
                track: .flutter,
                topic: "widgets",
                category: .conceptual,
                difficulty: .easy,
                title: "Widget Tree and Element Tree",
                question: "Explain the relationship between the Widget tree, Element tree, and RenderObject tree in Flutter. Why does Flutter use three separate trees?",
                modelAnswer: "Flutter uses three trees to separate concerns and optimize performance.\n\nThe **Widget tree** is the blueprint — it is an immutable description of the UI created in your build() methods. Widgets are lightweight and cheap to create. They are rebuilt frequently.\n\nThe **Element tree** is the instantiation of widgets. Each Element holds a reference to its corresponding Widget and manages the widget's position in the tree. Elements are persistent — they survive across rebuilds and are responsible for comparing old and new widgets to determine what changed.\n\nThe **RenderObject tree** handles layout, painting, and hit testing. RenderObjects are expensive to create and update, so Flutter only modifies them when the Element determines that a real change occurred.\n\nThis three-tree architecture means Flutter can cheaply recreate widget descriptions every frame while only updating the actual rendering layer when something genuinely changed. This is why Flutter achieves smooth 60/120 fps performance even with complex UIs.",
                followUpQuestions: [
                    "What role do Keys play in the Element tree, and when should you use them?",
                    "How does Flutter determine whether to update an existing Element or create a new one?",
                    "What is the difference between createElement() and createRenderObject()?",
                ],
                commonMistakes: [
                    "Confusing the Widget tree with the Element tree — widgets are immutable blueprints, elements are persistent instances.",
                    "Thinking that rebuilding widgets is expensive — widgets are lightweight structs designed to be recreated frequently.",
                    "Not understanding that RenderObjects are only updated when actual changes are detected, not on every rebuild.",
                ],
                codeSnippet: nil,
                tags: ["flutter", "widgets", "performance", "architecture"],
                orderIndex: 0
            ),

            InterviewQuestion(
                id: "iq_flutter_2",
                track: .flutter,
                topic: "state_management",
                category: .practical,
                difficulty: .medium,
                title: "Choosing a State Management Solution",
                question: "You are building a medium-sized e-commerce Flutter app. How would you choose a state management solution, and what factors would influence your decision?",
                modelAnswer: "The choice depends on several factors:\n\n**App complexity:** For simple apps, setState() and InheritedWidget suffice. For medium apps, Provider or Riverpod offer a good balance. For large apps with complex business logic, BLoC or Riverpod with code generation may be better.\n\n**Team familiarity:** Choose something the team can learn and maintain. Provider has the gentlest learning curve. BLoC requires understanding streams and events. Riverpod offers strong compile-time safety but has a steeper initial curve.\n\n**Testability:** BLoC and Riverpod excel here because business logic is fully separated from the UI. Provider is testable but requires more setup.\n\n**For the e-commerce app, I would choose Riverpod** because:\n1. It handles complex dependency graphs well (cart depends on auth, prices depend on locale)\n2. It provides compile-time safety — no runtime ProviderNotFoundException\n3. It supports both simple state (StateProvider) and complex async state (AsyncNotifierProvider)\n4. It makes testing straightforward with ProviderContainer overrides\n5. It handles disposal automatically, preventing memory leaks\n\nI would organize providers by feature (auth, cart, products, orders) and use AsyncNotifierProvider for API calls and NotifierProvider for local state like cart management.",
                followUpQuestions: [
                    "How would you handle global state like authentication status that many screens need?",
                    "What are the tradeoffs between Provider and Riverpod?",
                    "How would you structure state management for offline-first functionality?",
                ],
                commonMistakes: [
                    "Choosing the most popular solution without considering team skills and project requirements.",
                    "Over-engineering state management for simple apps — setState() is fine for truly local state.",
                    "Mixing multiple state management solutions in one app without a clear reason, leading to confusion.",
                ],
                codeSnippet: nil,
                tags: ["flutter", "state-management", "architecture", "riverpod"],
                orderIndex: 1
            ),

            InterviewQuestion(
                id: "iq_swift_1",
                track: .swift,
                topic: "swift_basics",
                category: .conceptual,
                difficulty: .easy,
                title: "Value Types vs Reference Types",
                question: "Explain the difference between value types and reference types in Swift. When would you choose one over the other?",
                modelAnswer: "**Value types** (struct, enum, tuple) are copied when assigned to a new variable or passed to a function. Each copy is independent — modifying one does not affect the other. Swift uses copy-on-write optimization for standard library types like Array and String, so copies are efficient.\n\n**Reference types** (class) are shared. Multiple variables can point to the same instance. Modifying through one reference affects all others. Classes also support inheritance and deinitializers.\n\n**Choose structs (value types) when:**\n- The data is relatively simple and self-contained\n- You want independent copies (no shared mutable state)\n- You are working with concurrent code (value types eliminate data races)\n- You do not need inheritance\n- You want the compiler to generate Equatable/Hashable conformance\n\n**Choose classes (reference types) when:**\n- You need shared mutable state (e.g., a shared cache or service)\n- You need inheritance hierarchies\n- You need identity (checking if two variables reference the exact same instance with ===)\n- You need deinitializers for cleanup\n- You are interfacing with Objective-C APIs\n\nSwift's standard guidance is to **default to structs** and only use classes when you have a specific reason.",
                followUpQuestions: [
                    "What is copy-on-write, and how does it make value types efficient?",
                    "How do value types interact with Swift's concurrency model and Sendable protocol?",
                    "Can you explain what happens in memory when you pass a struct vs a class to a function?",
                ],
                commonMistakes: [
                    "Thinking value types are always copied in memory — Swift uses copy-on-write for collections.",
                    "Using classes everywhere out of habit from other languages instead of defaulting to structs.",
                    "Forgetting that closures capture reference types by reference, which can cause retain cycles.",
                ],
                codeSnippet: nil,
                tags: ["swift", "value-types", "reference-types", "structs", "classes"],
                orderIndex: 0
            ),

            InterviewQuestion(
                id: "iq_swift_2",
                track: .swift,
                topic: "concurrency",
                category: .conceptual,
                difficulty: .hard,
                title: "Swift Structured Concurrency",
                question: "Explain structured concurrency in Swift. How do Task, async let, and TaskGroup differ, and when would you use each?",
                modelAnswer: "Structured concurrency means that concurrent tasks are organized in a hierarchy where child tasks are scoped to their parent. If a parent task is cancelled, all children are automatically cancelled. This prevents orphaned tasks and resource leaks.\n\n**Task** creates a new top-level task that runs independently. Use it to bridge from synchronous to asynchronous code (e.g., in a SwiftUI .task modifier or a button action). Tasks inherit the actor context of their creation point.\n\n**async let** creates a child task that runs concurrently with the current task. Use it when you have a known, fixed number of independent async operations to run in parallel:\n```swift\nasync let a = fetchA()\nasync let b = fetchB()\nlet result = try await (a, b)\n```\nIf you exit the scope before awaiting, the child task is implicitly cancelled and awaited.\n\n**TaskGroup** creates a dynamic number of child tasks. Use it when the number of concurrent operations is determined at runtime:\n```swift\nawait withTaskGroup(of: Image.self) { group in\n    for url in urls {\n        group.addTask { await downloadImage(url) }\n    }\n    for await image in group {\n        images.append(image)\n    }\n}\n```\n\n**When to use each:**\n- Task: Starting async work from sync context, fire-and-forget operations\n- async let: 2-5 independent parallel operations known at compile time\n- TaskGroup: Dynamic number of parallel operations, processing results as they complete",
                followUpQuestions: [
                    "What is the difference between Task and Task.detached?",
                    "How does cancellation propagate in structured concurrency?",
                    "How would you implement a rate limiter using TaskGroup?",
                ],
                commonMistakes: [
                    "Using Task.detached when a regular Task would suffice, losing actor context inheritance.",
                    "Not checking Task.isCancelled in long-running loops, making cancellation ineffective.",
                    "Creating too many tasks in a TaskGroup without throttling, overwhelming system resources.",
                ],
                codeSnippet: nil,
                tags: ["swift", "concurrency", "structured-concurrency", "task", "async-let"],
                orderIndex: 1
            ),

            InterviewQuestion(
                id: "iq_swift_3",
                track: .swift,
                topic: "swiftui",
                category: .practical,
                difficulty: .medium,
                title: "SwiftUI Data Flow",
                question: "Walk me through the different property wrappers in SwiftUI (@State, @Binding, @StateObject, @ObservedObject, @EnvironmentObject) and when you would use each one.",
                modelAnswer: "SwiftUI property wrappers manage the flow of data through the view hierarchy:\n\n**@State** — Owns simple, local, value-type state. The view is the single source of truth. Use for toggles, text field values, and UI-only state. Declared private because only the owning view should modify it.\n\n**@Binding** — A two-way reference to state owned by another view. Does not own the data. Use to let child views read and modify a parent's @State. Created with the $ prefix.\n\n**@StateObject** — Owns a reference-type ObservableObject. The view creates and owns the object. Use when the view is responsible for the lifecycle of an observable model. Only initialized once, even across view re-renders.\n\n**@ObservedObject** — Observes a reference-type ObservableObject but does NOT own it. The object is passed in from outside. Use when a parent creates the object and passes it to a child. Be careful: if the parent view recreates, the object may be recreated too.\n\n**@EnvironmentObject** — Reads an ObservableObject from the SwiftUI environment. No direct parent-to-child passing required. Use for app-wide state like user session, theme, or settings that many views need.\n\n**Decision framework:**\n- Simple value owned by this view -> @State\n- Value owned by parent, child needs read/write -> @Binding\n- This view creates an observable object -> @StateObject\n- Observable object passed from parent -> @ObservedObject\n- Observable object needed by many distant views -> @EnvironmentObject",
                followUpQuestions: [
                    "What happens if you accidentally use @ObservedObject where @StateObject should be used?",
                    "How does the new @Observable macro in Swift 5.9 change the data flow story?",
                    "How would you handle navigation state in a large SwiftUI app?",
                ],
                commonMistakes: [
                    "Using @ObservedObject instead of @StateObject for objects the view creates, causing unexpected reinitialization.",
                    "Making @State properties non-private, breaking the single-source-of-truth principle.",
                    "Using @EnvironmentObject everywhere instead of proper dependency injection, making the dependency graph implicit.",
                ],
                codeSnippet: nil,
                tags: ["swift", "swiftui", "property-wrappers", "data-flow"],
                orderIndex: 2
            ),

            InterviewQuestion(
                id: "iq_general_1",
                track: .general,
                topic: "oop",
                category: .conceptual,
                difficulty: .easy,
                title: "SOLID Principles",
                question: "Explain the SOLID principles and give an example of how violating one of them can lead to problems.",
                modelAnswer: "SOLID is an acronym for five design principles that make software more maintainable and flexible:\n\n**S — Single Responsibility Principle:** A class should have only one reason to change. Each class handles one concern.\n\n**O — Open/Closed Principle:** Software entities should be open for extension but closed for modification. Add new behavior through new code, not by changing existing code.\n\n**L — Liskov Substitution Principle:** Objects of a superclass should be replaceable with objects of a subclass without breaking the program.\n\n**I — Interface Segregation Principle:** Clients should not be forced to depend on interfaces they do not use. Prefer many small, focused interfaces over one large one.\n\n**D — Dependency Inversion Principle:** High-level modules should depend on abstractions, not concrete implementations.\n\n**Example violation — Single Responsibility:**\nImagine a UserManager class that handles user authentication, sends welcome emails, generates PDF reports, and logs analytics. If the email format changes, you must modify UserManager, risking bugs in authentication logic. By splitting into AuthService, EmailService, ReportGenerator, and AnalyticsLogger, each class has one reason to change and can be tested independently.\n\nViolating SRP leads to: large, hard-to-test classes; merge conflicts when multiple developers work on different features in the same file; and cascading bugs when a change in one area affects unrelated functionality.",
                followUpQuestions: [
                    "Can you give a concrete example of the Liskov Substitution Principle being violated?",
                    "How does the Dependency Inversion Principle relate to dependency injection?",
                    "Which SOLID principle do you find most important in practice, and why?",
                ],
                commonMistakes: [
                    "Confusing the Open/Closed Principle with never modifying code — it means designing for extension without modification.",
                    "Over-applying Interface Segregation and creating too many tiny interfaces that add complexity without benefit.",
                    "Thinking SOLID is only about classes — these principles apply to modules, functions, and system boundaries too.",
                ],
                codeSnippet: nil,
                tags: ["oop", "solid", "design-principles", "architecture"],
                orderIndex: 0
            ),

            InterviewQuestion(
                id: "iq_general_2",
                track: .general,
                topic: "design_patterns",
                category: .practical,
                difficulty: .medium,
                title: "Dependency Injection",
                question: "What is dependency injection, why is it important, and how would you implement it in a mobile app?",
                modelAnswer: "**Dependency injection (DI)** is a design pattern where an object receives its dependencies from external code rather than creating them itself. Instead of a class instantiating its own database or network service, those dependencies are 'injected' through the constructor, a setter, or a framework.\n\n**Why it matters:**\n1. **Testability** — You can inject mock dependencies in tests. A ViewModel that receives a protocol-typed repository can be tested with a mock repository that returns predictable data.\n2. **Loose coupling** — Classes depend on abstractions (protocols/interfaces), not concrete implementations. You can swap implementations without changing the dependent class.\n3. **Configurability** — Different environments (dev, staging, production) can inject different implementations.\n\n**Implementation approaches:**\n\n*Constructor injection (preferred):*\n```swift\nclass OrderViewModel {\n    private let repository: OrderRepository\n    init(repository: OrderRepository) {\n        self.repository = repository\n    }\n}\n```\n\n*In Flutter with Provider:*\n```dart\nProvider<OrderRepository>(\n  create: (_) => RemoteOrderRepository(apiClient),\n  child: Consumer<OrderRepository>(\n    builder: (_, repo, __) => OrderScreen(repository: repo),\n  ),\n)\n```\n\n*In Swift with protocols:*\nDefine a protocol (OrderRepository), create concrete implementations (RemoteOrderRepository, MockOrderRepository), and inject the appropriate one at the composition root — the place where you assemble the object graph, typically in the app's entry point or a dedicated DI container.",
                followUpQuestions: [
                    "What is the difference between constructor injection, property injection, and method injection?",
                    "How do DI containers/frameworks work, and are they always necessary?",
                    "How does dependency injection work with SwiftUI's environment system?",
                ],
                commonMistakes: [
                    "Creating dependencies inside the class instead of injecting them, making the class untestable.",
                    "Injecting concrete types instead of protocols/interfaces, defeating the purpose of DI.",
                    "Using a Service Locator (global registry) and calling it dependency injection — they are different patterns with different tradeoffs.",
                ],
                codeSnippet: nil,
                tags: ["design-patterns", "dependency-injection", "testability", "architecture"],
                orderIndex: 1
            ),

            InterviewQuestion(
                id: "iq_flutter_3",
                track: .flutter,
                topic: "dart_basics",
                category: .liveCoding,
                difficulty: .medium,
                title: "Implementing a Debouncer",
                question: "Implement a Debouncer class in Dart that delays execution of a callback until a specified duration has passed without the debouncer being called again. This is commonly used for search-as-you-type functionality.",
                modelAnswer: "A debouncer cancels the previous timer each time it is called and starts a new one. The callback only fires when the specified duration elapses without a new call:\n\n```dart\nimport 'dart:async';\n\nclass Debouncer {\n  final Duration delay;\n  Timer? _timer;\n\n  Debouncer({required this.delay});\n\n  void call(VoidCallback action) {\n    _timer?.cancel();\n    _timer = Timer(delay, action);\n  }\n\n  void dispose() {\n    _timer?.cancel();\n  }\n}\n```\n\nUsage in a search field:\n```dart\nfinal _debouncer = Debouncer(delay: Duration(milliseconds: 300));\n\nvoid onSearchChanged(String query) {\n  _debouncer.call(() {\n    // This only fires 300ms after the user stops typing\n    searchApi(query);\n  });\n}\n\n@override\nvoid dispose() {\n  _debouncer.dispose();\n  super.dispose();\n}\n```\n\nKey points:\n- Timer? is nullable because no timer exists initially\n- _timer?.cancel() safely cancels the previous timer if one exists\n- dispose() prevents memory leaks by cancelling any pending timer\n- The delay is configurable and typically 300-500ms for search",
                followUpQuestions: [
                    "How would you implement a throttler (fires at most once per duration) instead?",
                    "How would you make this work with async callbacks that return a Future?",
                    "How would you test this debouncer using fake async in Flutter tests?",
                ],
                commonMistakes: [
                    "Forgetting to cancel the timer in dispose(), causing callbacks to fire after the widget is unmounted.",
                    "Not making the timer nullable, which requires unnecessary initialization.",
                    "Using a fixed delay instead of making it configurable, reducing reusability.",
                ],
                codeSnippet: "import 'dart:async';\n\nclass Debouncer {\n  final Duration delay;\n  Timer? _timer;\n\n  Debouncer({required this.delay});\n\n  void call(VoidCallback action) {\n    _timer?.cancel();\n    _timer = Timer(delay, action);\n  }\n\n  void dispose() {\n    _timer?.cancel();\n  }\n}",
                tags: ["dart", "async", "debounce", "live-coding"],
                orderIndex: 2
            ),

            InterviewQuestion(
                id: "iq_general_3",
                track: .general,
                topic: "design_patterns",
                category: .systemDesign,
                difficulty: .hard,
                title: "Offline-First Mobile Architecture",
                question: "Design an offline-first architecture for a mobile app that needs to work without internet and sync data when connectivity is restored. What patterns and technologies would you use?",
                modelAnswer: "An offline-first architecture prioritizes local data and treats the network as an optimization rather than a requirement.\n\n**Core Architecture:**\n\n1. **Local Database as Source of Truth:**\n   - Use SQLite (via sqflite in Flutter or GRDB/Core Data in Swift) for structured data\n   - All reads come from the local database, ensuring instant UI response\n   - Writes go to the local database first, then sync to the server\n\n2. **Repository Pattern:**\n   - The Repository abstracts the data source from the rest of the app\n   - It decides whether to fetch from cache, local DB, or network\n   - ViewModels/Blocs never know where data comes from\n\n3. **Sync Engine:**\n   - Maintain a sync queue (pending operations table) for changes made offline\n   - Each entry contains: operation type (create/update/delete), entity data, timestamp, retry count\n   - When connectivity returns, process the queue in order\n   - Use optimistic UI updates — show the change immediately and reconcile later\n\n4. **Conflict Resolution:**\n   - Last-write-wins (simplest): Use timestamps; the latest change wins\n   - Server-wins: Server version always takes precedence on conflict\n   - Merge: Custom logic per entity type to merge changes\n   - Use version numbers or ETags to detect conflicts\n\n5. **Connectivity Monitoring:**\n   - Listen for connectivity changes (connectivity_plus in Flutter, NWPathMonitor in Swift)\n   - Trigger sync when connection is restored\n   - Implement exponential backoff for failed syncs\n\n**Technology Stack (Flutter):**\n- drift or sqflite for local storage\n- dio with interceptors for network layer\n- connectivity_plus for monitoring\n- workmanager for background sync\n\n**Technology Stack (Swift):**\n- Core Data or SwiftData for local storage\n- URLSession with background configurations\n- NWPathMonitor for connectivity\n- BGTaskScheduler for background sync",
                followUpQuestions: [
                    "How would you handle a situation where the same record is modified both offline and on the server?",
                    "How would you implement background sync on iOS given the system's restrictions on background execution?",
                    "How would you test this architecture, especially the sync and conflict resolution logic?",
                ],
                commonMistakes: [
                    "Treating the network as the source of truth, which breaks the app when offline.",
                    "Not implementing a proper sync queue, leading to lost offline changes.",
                    "Ignoring conflict resolution until it becomes a production issue with data corruption.",
                ],
                codeSnippet: nil,
                tags: ["system-design", "offline-first", "architecture", "sync"],
                orderIndex: 2
            ),

            InterviewQuestion(
                id: "iq_general_4",
                track: .general,
                topic: "oop",
                category: .behavioral,
                difficulty: .easy,
                title: "Handling Technical Disagreements",
                question: "Tell me about a time you disagreed with a teammate on a technical approach. How did you resolve it?",
                modelAnswer: "A strong answer follows the STAR format (Situation, Task, Action, Result):\n\n**Situation:** On a previous project, a teammate wanted to implement a complex Redux-like state management solution for a relatively simple app with about 10 screens.\n\n**Task:** I believed a simpler approach (Provider pattern) would be more appropriate given the app's scope and our tight deadline.\n\n**Action:**\n1. I listened fully to their reasoning — they were concerned about scalability if the app grew\n2. I acknowledged the validity of their concern\n3. I proposed we evaluate both approaches against our specific criteria: team familiarity, time to implement, testability, and future scalability\n4. We did a small time-boxed prototype (2 hours each) with both approaches\n5. We presented findings to the team and discussed tradeoffs objectively\n\n**Result:** We chose the simpler approach with an agreed-upon architectural boundary that would make migration easier if needed. The app shipped on time, and six months later the simpler solution was still serving us well.\n\n**Key principles demonstrated:**\n- Listen first, then share your perspective\n- Focus on objective criteria, not personal preferences\n- Use data (prototypes, benchmarks) to inform decisions\n- Be willing to be wrong and compromise\n- Document the decision and reasoning for future reference",
                followUpQuestions: [
                    "What would you do if the team chose the approach you disagreed with?",
                    "How do you balance technical idealism with practical deadlines?",
                    "How do you approach code reviews when you disagree with the author's approach?",
                ],
                commonMistakes: [
                    "Framing the story as 'I was right, they were wrong' — interviewers want to see collaboration, not ego.",
                    "Not demonstrating willingness to compromise or adapt your position based on new information.",
                    "Giving a vague answer without a specific, real example with concrete details.",
                ],
                codeSnippet: nil,
                tags: ["behavioral", "teamwork", "communication", "conflict-resolution"],
                orderIndex: 3
            ),
        ]
    }
}
