import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/document_model.dart';

class DocumentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;
  DocumentModel? _selectedDocument;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DocumentModel? get selectedDocument => _selectedDocument;

  // Initialize and listen to documents
  void initialize() {
    _firestoreService.getDocumentsStream().listen((documents) {
      _documents = documents;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load documents: $error';
      print('Documents stream error: $error');
      notifyListeners();
    });
  }

  // Load documents once
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Documents will be updated via the stream
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new document
  Future<bool> addDocument(DocumentModel document, File pdfFile,
      File thumbnailFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload PDF
      final pdfUrl = await _storageService.uploadDocument(pdfFile, document.id);

      // Upload thumbnail
      final thumbnailUrl =
          await _storageService.uploadThumbnail(thumbnailFile, document.id);

      // Create document with URLs
      final updatedDocument = document.copyWith(
        documentUrl: pdfUrl,
        thumbnailUrl: thumbnailUrl,
      );

      // Save to Firestore
      await _firestoreService.addDocument(updatedDocument);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add document: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get single document
  Future<DocumentModel?> getDocument(String documentId) async {
    try {
      return await _firestoreService.getDocument(documentId);
    } catch (e) {
      _errorMessage = 'Failed to get document: $e';
      notifyListeners();
      return null;
    }
  }

  // Update document
  Future<bool> updateDocument(
      String documentId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateDocument(documentId, updates);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update document: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete from Storage
      await _storageService.deleteDocument(documentId);

      // Delete from Firestore
      await _firestoreService.deleteDocument(documentId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete document: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String documentId, bool isFavorite) async {
    try {
      await _firestoreService.toggleFavorite(documentId, !isFavorite);
    } catch (e) {
      _errorMessage = 'Failed to toggle favorite: $e';
      notifyListeners();
    }
  }

  // Update document name
  Future<bool> updateDocumentName(String documentId, String name) async {
    try {
      await _firestoreService.updateDocumentName(documentId, name);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update name: $e';
      notifyListeners();
      return false;
    }
  }

  // Add tags
  Future<bool> addTags(String documentId, List<String> tags) async {
    try {
      await _firestoreService.addTags(documentId, tags);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add tags: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove tag
  Future<bool> removeTag(String documentId, String tag) async {
    try {
      await _firestoreService.removeTag(documentId, tag);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove tag: $e';
      notifyListeners();
      return false;
    }
  }

  // Search documents
  Future<List<DocumentModel>> searchDocuments(String query) async {
    try {
      return await _firestoreService.searchDocuments(query);
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      notifyListeners();
      return [];
    }
  }

  // Set selected document
  void setSelectedDocument(DocumentModel? document) {
    _selectedDocument = document;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get favorites
  Stream<List<DocumentModel>> getFavorites() {
    return _firestoreService.getFavoriteDocuments();
  }

  // Get documents by tag
  Stream<List<DocumentModel>> getDocumentsByTag(String tag) {
    return _firestoreService.getDocumentsByTag(tag);
  }

  // Download document
  Future<File?> downloadDocument(String documentId, String localPath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final document = await _firestoreService.getDocument(documentId);
      if (document == null) {
        _errorMessage = 'Document not found';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final file = await _storageService.downloadFile(
          document.documentUrl, localPath);
      _isLoading = false;
      notifyListeners();
      return file;
    } catch (e) {
      _errorMessage = 'Download failed: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
