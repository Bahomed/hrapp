import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

// Helper class for RGB values
class _Rgb {
  final int r;
  final int g;
  final int b;
  _Rgb(this.r, this.g, this.b);
}

class Util{
  static img.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    final plane = cameraImage.planes[0];
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    // ✅ Create output image
    final img.Image image = img.Image(width: width, height: height);

    // ✅ Manually convert BGRA to RGB
    final Uint8List bytes = plane.bytes;
    final int bytesPerRow = plane.bytesPerRow;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int rowOffset = y * bytesPerRow;
        final int pixelOffset = rowOffset + (x * 4); // 4 bytes per pixel (BGRA)

        if (pixelOffset + 3 < bytes.length) {
          final int b = bytes[pixelOffset];
          final int g = bytes[pixelOffset + 1];
          final int r = bytes[pixelOffset + 2];
          final int a = bytes[pixelOffset + 3];

          // ✅ Set pixel as RGB (swapping B and R from BGRA)
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }

    return image;
  }

  static img.Image convertNV21(CameraImage image) {
    final width = image.width.toInt();
    final height = image.height.toInt();

    // Handle different Android camera formats
    if (image.planes.length == 1) {
      // Single plane NV21 format (most common)
      Uint8List yuv420sp = image.planes[0].bytes;
      final outImg = img.Image(height: height, width: width);
      final int frameSize = width * height;

      for (int j = 0, yp = 0; j < height; j++) {
        int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
        for (int i = 0; i < width; i++, yp++) {
          final int y = (0xff & yuv420sp[yp]) - 16;
          if ((i & 1) == 0) {
            v = (0xff & yuv420sp[uvp++]) - 128;
            u = (0xff & yuv420sp[uvp++]) - 128;
          }

          final _Rgb rgb = _yuvToRgb(y, u, v);
          outImg.setPixelRgb(i, j, rgb.r, rgb.g, rgb.b);
        }
      }
      return outImg;
    } else {
      // Multi-plane YUV format (YUV420 or similar)
      return convertYUV420ToImageStatic(image);
    }
  }

  // Static version of convertYUV420ToImage for internal use
  static img.Image convertYUV420ToImageStatic(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var h = 0; h < height; h++) {
      for (var w = 0; w < width; w++) {
        final uvIndex =
            uvPixelStride * (w ~/ 2) + uvRowStride * (h ~/ 2);
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        final _Rgb rgb = _yuvToRgb(y, u - 128, v - 128);
        image.setPixelRgb(w, h, rgb.r, rgb.g, rgb.b);
      }
    }
    return image;
  }

  static int yuv2rgbStatic(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  // TODO method to convert CameraImage to Image
  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        final _Rgb rgb = _yuvToRgb(y, u - 128, v - 128);
        image.setPixelRgb(w, h, rgb.r, rgb.g, rgb.b);
      }
    }
    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
    ((b << 16) & 0xff0000) |
    ((g << 8) & 0xff00) |
    (r & 0xff);
  }

  static _Rgb _yuvToRgb(int y, int u, int v) {
    // Normalize YUV like standard NV21 conversion
    int yVal = y + 16;
    int uVal = u;
    int vVal = v;

    if (yVal < 0) yVal = 0;

    int c = yVal - 16;
    int d = uVal;
    int e = vVal;

    int r = (298 * c + 409 * e + 128) >> 8;
    int g = (298 * c - 100 * d - 208 * e + 128) >> 8;
    int b = (298 * c + 516 * d + 128) >> 8;

    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return _Rgb(r, g, b);
  }
}
