import 'package:flutter/foundation.dart';

class DocumentProvider with ChangeNotifier {
  List<dynamic> _documents = [];
  bool _isLoading = false;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;

  Future<void> loadDocuments() async {
    // TODO: Implement document loading from Firestore
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDocument(dynamic document) async {
    // TODO: Implement add document
    _documents.add(document);
    notifyListeners();
  }

  Future<void> deleteDocument(String documentId) async {
    // TODO: Implement delete document
    notifyListeners();
  }
}
