import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ============================================
  // DOCUMENT UPLOADS
  // ============================================

  // Upload document PDF
  Future<String> uploadDocument(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('documents')
          .child('$documentId.pdf');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': _userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Document upload failed: $e');
    }
  }

  // Upload thumbnail image
  Future<String> uploadThumbnail(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('thumbnails')
          .child('$documentId.jpg');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': _userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Thumbnail upload failed: $e');
    }
  }

  // Upload original image (for OCR processing)
  Future<String> uploadImage(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('images')
          .child('$documentId.jpg');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  // Delete document and associated files
  Future<void> deleteDocument(String documentId) async {
    try {
      // Delete PDF
      await _deleteFile('users/$_userId/documents/$documentId.pdf');

      // Delete thumbnail
      await _deleteFile('users/$_userId/thumbnails/$documentId.jpg');

      // Delete original image (if exists)
      await _deleteFile('users/$_userId/images/$documentId.jpg');
    } catch (e) {
      // Some files might not exist, which is okay
      print('Delete error (may be expected): $e');
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      // File might not exist
      print('File not found: $path');
    }
  }

  // ============================================
  // DOWNLOAD OPERATIONS
  // ============================================

  // Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  // Download file to device
  Future<File> downloadFile(String path, String localPath) async {
    try {
      final ref = _storage.ref(path);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // ============================================
  // METADATA OPERATIONS
  // ============================================

  // Get file metadata
  Future<FullMetadata> getMetadata(String path) async {
    try {
      return await _storage.ref(path).getMetadata();
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      final metadata = await getMetadata(path);
      return metadata.size ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // PREMIUM CLOUD BACKUP
  // ============================================

  // Upload to premium cloud backup
  Future<String> uploadToCloudBackup(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('premium')
          .child(_userId)
          .child('$documentId.pdf');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Cloud backup upload failed: $e');
    }
  }

  // List all user documents
  Future<List<Reference>> listDocuments() async {
    try {
      final result = await _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('documents')
          .listAll();

      return result.items;
    } catch (e) {
      throw Exception('Failed to list documents: $e');
    }
  }
}
