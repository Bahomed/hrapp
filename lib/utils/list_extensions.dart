// Temporary extension to fix compilation issues with removed tflite_flutter
extension ListExtension on List {
  List reshape(List<int> shape) {
    // Temporary implementation - just return the original list
    return this;
  }
}