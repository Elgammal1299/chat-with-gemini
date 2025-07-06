import 'dart:io';
import 'package:chat_gemini_app/core/service/native_services.dart';
import 'package:image_picker/image_picker.dart';

class ImageManager {
  final NativeServices _nativeServices = NativeServices();
  File? _selectedImage;

  File? get selectedImage => _selectedImage;

  bool get hasSelectedImage => _selectedImage != null;

  Future<File?> pickImageFromCamera() async {
    print('📷 pickImageFromCamera called');
    try {
      final imagePath = await _nativeServices.pickImage(ImageSource.camera);
      print('📷 Camera result: ${imagePath?.path ?? 'null'}');

      if (imagePath != null) {
        _selectedImage = imagePath;
        print('📷 Selected image from camera: ${_selectedImage?.path}');
        return _selectedImage;
      }
      return null;
    } catch (e) {
      print('📷 Error picking image from camera: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    print('📷 pickImageFromGallery called');
    try {
      final imagePath = await _nativeServices.pickImage(ImageSource.gallery);
      print('📷 Gallery result: ${imagePath?.path ?? 'null'}');

      if (imagePath != null) {
        _selectedImage = imagePath;
        print('📷 Selected image from gallery: ${_selectedImage?.path}');
        return _selectedImage;
      }
      return null;
    } catch (e) {
      print('📷 Error picking image from gallery: $e');
      return null;
    }
  }

  void removeImage() {
    print('📷 removeImage called');
    _selectedImage = null;
  }

  void clearImage() {
    _selectedImage = null;
    print('📷 Image cleared');
  }

  Future<void> debugTestImageProcessing() async {
    print('🔍 Debug: Testing image processing');
    print('🔍 Selected image: ${_selectedImage?.path ?? 'null'}');

    if (_selectedImage != null) {
      try {
        final bytes = await _selectedImage!.readAsBytes();
        print('🔍 Image bytes: ${bytes.length} bytes');
        print('🔍 Image path: ${_selectedImage!.path}');
        print('🔍 Image exists: ${await _selectedImage!.exists()}');

        // Test MIME type detection
        String mimeType =
            _selectedImage!.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
        print('🔍 MIME type: $mimeType');

        print('🔍 Image processing test completed successfully');
      } catch (e) {
        print('🔍 Error testing image processing: $e');
      }
    } else {
      print('🔍 No image selected for testing');
    }
  }
}
