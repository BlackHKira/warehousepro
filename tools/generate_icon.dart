import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Draw gradient background
  for (int y = 0; y < size; y++) {
    final t = y / size;
    final r = (29 * (1 - t) + 37 * t).round();
    final g = (78 * (1 - t) + 99 * t).round();
    final b = (216 * (1 - t) + 235 * t).round();
    final color = img.ColorRgb8(r, g, b);
    for (int x = 0; x < size; x++) {
      image.setPixel(x, y, color);
    }
  }

  final white = img.ColorRgba8(255, 255, 255, 255);
  final shadowColor = img.ColorRgba8(255, 255, 255, 50);

  // ---- Roof (triangle) ----
  final roofVerts = [
    img.Point(size ~/ 2, size ~/ 5),
    img.Point(size ~/ 4, size * 8 ~/ 20 + 20),
    img.Point(size * 3 ~/ 4, size * 8 ~/ 20 + 20),
  ];
  img.fillPolygon(image, vertices: roofVerts, color: white);

  // ---- Building body ----
  final bodyLeft = size ~/ 4;
  final bodyRight = size * 3 ~/ 4;
  final bodyTop = size * 8 ~/ 20;
  final bodyBottom = size - size ~/ 6;

  img.fillRect(image, x1: bodyLeft, y1: bodyTop, x2: bodyRight, y2: bodyBottom, color: white);

  // ---- Door ----
  final doorW = size ~/ 8;
  final doorH = size ~/ 5;
  final doorLeft = (size - doorW) ~/ 2;
  final doorRight = (size + doorW) ~/ 2;
  final doorTop = bodyBottom - doorH;
  img.fillRect(image, x1: doorLeft, y1: doorTop, x2: doorRight, y2: bodyBottom, color: shadowColor);

  // Door arch (half-circle)
  final doorCenter = size ~/ 2;
  final doorArchRadius = doorW ~/ 2;
  for (int y = doorTop - doorArchRadius; y <= doorTop; y++) {
    for (int x = doorLeft; x <= doorRight; x++) {
      final dx = x - doorCenter;
      final dy = y - doorTop;
      if (dx * dx + dy * dy <= doorArchRadius * doorArchRadius) {
        image.setPixel(x, y, shadowColor);
      }
    }
  }

  // ---- Windows ----
  final winW = size ~/ 16;
  final winH = size ~/ 14;
  final winY = bodyTop + size ~/ 10;

  img.fillRect(
    image,
    x1: bodyLeft + size ~/ 10,
    y1: winY,
    x2: bodyLeft + size ~/ 10 + winW,
    y2: winY + winH,
    color: shadowColor,
  );
  img.fillRect(
    image,
    x1: bodyRight - size ~/ 10 - winW,
    y1: winY,
    x2: bodyRight - size ~/ 10,
    y2: winY + winH,
    color: shadowColor,
  );

  int px(img.Point p) => p.x.toInt();
  int py(img.Point p) => p.y.toInt();
  img.drawLine(image, x1: px(roofVerts[0]), y1: py(roofVerts[0]), x2: px(roofVerts[1]), y2: py(roofVerts[1]), color: white, thickness: 4);
  img.drawLine(image, x1: px(roofVerts[0]), y1: py(roofVerts[0]), x2: px(roofVerts[2]), y2: py(roofVerts[2]), color: white, thickness: 4);
  img.drawLine(image, x1: px(roofVerts[1]), y1: py(roofVerts[1]), x2: px(roofVerts[2]), y2: py(roofVerts[2]), color: white, thickness: 4);

  // Shadow strip
  for (int x = bodyLeft; x < bodyRight; x++) {
    for (int shade = 0; shade < 4; shade++) {
      final y = bodyBottom - 1 - shade;
      image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 40 - shade * 8));
    }
  }

  // Save
  final dir = Directory('assets');
  if (!dir.existsSync()) dir.createSync();

  final png = img.encodePng(image);
  File('assets/icon.png').writeAsBytesSync(png);
  print('App icon generated: assets/icon.png');
}
