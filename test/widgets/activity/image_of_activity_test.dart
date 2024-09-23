// File: test/widgets/image_of_activity_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/activity/image_of_activity.dart';

void main() {
  testWidgets('ImageOfActivity displays image with gradient overlay',
      (WidgetTester tester) async {
    // Arrange
    const imagePath = 'assets/activities/default_image.webp';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ImageOfActivity(imagePath: imagePath),
        ),
      ),
    );

    // Assert: Image.asset is present with correct path
    expect(find.byType(Image), findsOneWidget);
    final imageWidget = tester.widget<Image>(find.byType(Image));
    expect(imageWidget.image, isA<AssetImage>());
    final AssetImage assetImage = imageWidget.image as AssetImage;
    expect(assetImage.assetName, imagePath);

    // Assert: Gradient overlay is present
    expect(find.byType(Positioned), findsNWidgets(1));
    // Optionally, check if the gradient container is present
    expect(find.byType(Container), findsNWidgets(1)); // Gradient container
  });
}
