import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String documentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
  final int fileSize;
  final bool isFavorite;
  final String? ocrText;
  final List<String> tags;

  DocumentModel({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.documentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.pageCount = 1,
    this.fileSize = 0,
    this.isFavorite = false,
    this.ocrText,
    this.tags = const [],
  });

  // From Firestore
  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      name: data['name'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      pageCount: data['pageCount'] ?? 1,
      fileSize: data['fileSize'] ?? 0,
      isFavorite: data['isFavorite'] ?? false,
      ocrText: data['ocrText'],
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'documentUrl': documentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pageCount': pageCount,
      'fileSize': fileSize,
      'isFavorite': isFavorite,
      'ocrText': ocrText,
      'tags': tags,
    };
  }

  DocumentModel copyWith({
    String? name,
    String? thumbnailUrl,
    String? documentUrl,
    DateTime? updatedAt,
    int? pageCount,
    int? fileSize,
    bool? isFavorite,
    String? ocrText,
    List<String>? tags,
  }) {
    return DocumentModel(
      id: id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageCount: pageCount ?? this.pageCount,
      fileSize: fileSize ?? this.fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
      ocrText: ocrText ?? this.ocrText,
      tags: tags ?? this.tags,
    );
  }
}
