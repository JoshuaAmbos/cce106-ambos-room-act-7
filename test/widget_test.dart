import 'package:flutter_test/flutter_test.dart';
import 'package:ambos_room7/main.dart';

void main() {
  testWidgets('App starts with Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
