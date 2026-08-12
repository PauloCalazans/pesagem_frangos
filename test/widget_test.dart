import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the first weighing step on startup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    mPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Pesagem'), findsOneWidget);
    expect(find.text('Sexo'), findsOneWidget);
    expect(find.text('AVANÇAR'), findsOneWidget);
  });
}
