import 'dart:math' as math;
import 'dart:typed_data';

class MathUtils {
  static double calculateCosineSimilarity(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      norm1 += vector1[i] * vector1[i];
      norm2 += vector2[i] * vector2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  static List<double> normalizeVector(List<double> vector) {
    final magnitude = math.sqrt(vector.map((x) => x * x).reduce((a, b) => a + b));
    if (magnitude == 0.0) return vector;
    return vector.map((x) => x / magnitude).toList();
  }

  static double calculateEuclideanDistance(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    double sum = 0.0;
    for (int i = 0; i < vector1.length; i++) {
      final diff = vector1[i] - vector2[i];
      sum += diff * diff;
    }

    return math.sqrt(sum);
  }

  static List<double> calculateMean(List<List<double>> vectors) {
    if (vectors.isEmpty) return [];

    final length = vectors.first.length;
    final mean = List.filled(length, 0.0);

    for (final vector in vectors) {
      for (int i = 0; i < length; i++) {
        mean[i] += vector[i];
      }
    }

    for (int i = 0; i < length; i++) {
      mean[i] /= vectors.length;
    }

    return mean;
  }

  static double calculateMagnitude(List<double> vector) {
    return math.sqrt(vector.map((x) => x * x).reduce((a, b) => a + b));
  }

  static List<double> subtractVectors(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    return List.generate(
      vector1.length,
          (index) => vector1[index] - vector2[index],
    );
  }

  static List<double> addVectors(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    return List.generate(
      vector1.length,
          (index) => vector1[index] + vector2[index],
    );
  }

  static List<double> scaleVector(List<double> vector, double scalar) {
    return vector.map((x) => x * scalar).toList();
  }

  static double dotProduct(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    double result = 0.0;
    for (int i = 0; i < vector1.length; i++) {
      result += vector1[i] * vector2[i];
    }

    return result;
  }

  static List<double> crossProduct(List<double> vector1, List<double> vector2) {
    if (vector1.length != 3 || vector2.length != 3) {
      throw ArgumentError('Cross product requires 3D vectors');
    }

    return [
      vector1[1] * vector2[2] - vector1[2] * vector2[1],
      vector1[2] * vector2[0] - vector1[0] * vector2[2],
      vector1[0] * vector2[1] - vector1[1] * vector2[0],
    ];
  }

  static double angleRadians(List<double> vector1, List<double> vector2) {
    final cosTheta = calculateCosineSimilarity(vector1, vector2);
    return math.acos(cosTheta.clamp(-1.0, 1.0));
  }

  static double angleDegrees(List<double> vector1, List<double> vector2) {
    return angleRadians(vector1, vector2) * 180.0 / math.pi;
  }

  static List<List<double>> transposeMatrix(List<List<double>> matrix) {
    if (matrix.isEmpty) return [];

    final rows = matrix.length;
    final cols = matrix.first.length;

    return List.generate(
      cols,
          (i) => List.generate(rows, (j) => matrix[j][i]),
    );
  }

  static List<List<double>> multiplyMatrices(
      List<List<double>> matrix1,
      List<List<double>> matrix2,
      ) {
    if (matrix1.isEmpty || matrix2.isEmpty) return [];
    if (matrix1.first.length != matrix2.length) {
      throw ArgumentError('Matrix dimensions incompatible for multiplication');
    }

    final rows1 = matrix1.length;
    final cols1 = matrix1.first.length;
    final cols2 = matrix2.first.length;

    return List.generate(
      rows1,
          (i) => List.generate(
        cols2,
            (j) {
          double sum = 0.0;
          for (int k = 0; k < cols1; k++) {
            sum += matrix1[i][k] * matrix2[k][j];
          }
          return sum;
        },
      ),
    );
  }
}