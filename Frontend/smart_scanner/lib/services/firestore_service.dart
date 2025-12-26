import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  // Get user data stream (real-time updates)
  Stream<UserModel?> getUserStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Get user data once
  Future<UserModel?> getUser() async {
    final doc = await _firestore.collection('users').doc(_userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  // ============================================
  // DOCUMENT OPERATIONS
  // ============================================

  // Get documents stream (real-time updates)
  Stream<List<DocumentModel>> getDocumentsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).toList());
  }

  // Get single document
  Future<DocumentModel?> getDocument(String documentId) async {
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(documentId)
        .get();

    return doc.exists ? DocumentModel.fromFirestore(doc) : null;
  }

  // Add document
  Future<void> addDocument(DocumentModel document) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(document.id)
        .set(document.toFirestore());
  }

  // Update document
  Future<void> updateDocument(
      String documentId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = Timestamp.now();
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(documentId)
        .update(updates);
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(documentId)
        .delete();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String documentId, bool isFavorite) async {
    await updateDocument(documentId, {'isFavorite': isFavorite});
  }

  // Update document name
  Future<void> updateDocumentName(String documentId, String name) async {
    await updateDocument(documentId, {'name': name});
  }

  // Add tags to document
  Future<void> addTags(String documentId, List<String> tags) async {
    await updateDocument(documentId, {
      'tags': FieldValue.arrayUnion(tags),
    });
  }

  // Remove tag from document
  Future<void> removeTag(String documentId, String tag) async {
    await updateDocument(documentId, {
      'tags': FieldValue.arrayRemove([tag]),
    });
  }

  // Search documents
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    return snapshot.docs
        .map((doc) => DocumentModel.fromFirestore(doc))
        .toList();
  }

  // Get favorite documents
  Stream<List<DocumentModel>> getFavoriteDocuments() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .where('isFavorite', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  // Get documents by tag
  Stream<List<DocumentModel>> getDocumentsByTag(String tag) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }
}
