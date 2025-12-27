import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/document_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/document_model.dart';
import '../utils/helpers.dart';
import '../utils/image_helper.dart';
import '../utils/constants.dart';
import '../services/pdf_service.dart';

class EditorScreen extends StatefulWidget {
  final String imagePath;

  const EditorScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  File? _currentImage;
  bool _isProcessing = false;
  String _selectedFilter = 'Original';
  int _rotation = 0;

  @override
  void initState() {
    super.initState();
    _currentImage = File(widget.imagePath);
  }

  Future<void> _applyFilter(String filter) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _selectedFilter = filter;
    });

    try {
      File processedImage;

      switch (filter) {
        case 'Grayscale':
          processedImage = await ImageHelper.applyGrayscale(_currentImage!);
          break;
        case 'Black & White':
          processedImage = await ImageHelper.applyBlackAndWhite(_currentImage!);
          break;
        case 'Auto':
          processedImage = await ImageHelper.autoEnhance(_currentImage!);
          break;
        case 'Original':
        default:
          processedImage = File(widget.imagePath);
          break;
      }

      setState(() {
        _currentImage = processedImage;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to apply filter', isError: true);
      }
    }
  }

  Future<void> _rotateImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final rotated = await ImageHelper.rotateImage(_currentImage!, 90);
      setState(() {
        _currentImage = rotated;
        _rotation = (_rotation + 90) % 360;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to rotate image', isError: true);
      }
    }
  }

  Future<void> _saveDocument() async {
    if (_isProcessing || _currentImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    Helpers.showLoadingDialog(context, message: 'Saving document...');

    try {
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      final pdfService = PdfService();

      // Generate unique ID
      const uuid = Uuid();
      final documentId = uuid.v4();

      // Create thumbnail
      final thumbnail = await ImageHelper.createThumbnail(_currentImage!);

      // Generate PDF
      final pdfFile = await pdfService.createPdfFromImage(_currentImage!, documentId);

      // Create document model
      final now = DateTime.now();
      final document = DocumentModel(
        id: documentId,
        name: 'Scan ${Helpers.formatDate(now)}',
        thumbnailUrl: '', // Will be set after upload
        documentUrl: '', // Will be set after upload
        createdAt: now,
        updatedAt: now,
        pageCount: 1,
        fileSize: await pdfFile.length(),
      );

      // Upload document
      final success = await documentProvider.addDocument(
        document,
        pdfFile,
        thumbnail,
      );

      if (mounted) {
        Helpers.hideLoadingDialog(context);
      }

      if (success) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Document saved successfully!');
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        if (mounted) {
          Helpers.showErrorDialog(
            context,
            'Save Failed',
            documentProvider.errorMessage ?? 'Failed to save document',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showErrorDialog(
          context,
          'Error',
          'Failed to save document: $e',
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _performOcr() async {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    if (!subscriptionProvider.isPremium) {
      Helpers.showErrorDialog(
        context,
        'Premium Feature',
        'OCR text extraction requires a Premium subscription.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    Helpers.showLoadingDialog(context, message: 'Extracting text...');

    try {
      // Upload image and get URL (simplified - in real app upload to storage first)
      final ocrText = await subscriptionProvider.performOcr('image_url_here');

      if (mounted) {
        Helpers.hideLoadingDialog(context);

        if (ocrText != null && ocrText.isNotEmpty) {
          _showOcrResult(ocrText);
        } else {
          Helpers.showSnackBar(context, 'No text found in document');
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showErrorDialog(
          context,
          'OCR Failed',
          subscriptionProvider.errorMessage ?? 'Failed to extract text',
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showOcrResult(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Text'),
        content: SingleChildScrollView(
          child: SelectableText(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Helpers.copyToClipboard(context, text),
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Edit Document'),
        actions: [
          if (_currentImage != null)
            TextButton(
              onPressed: _isProcessing ? null : _saveDocument,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Center(
              child: _currentImage == null
                  ? const CircularProgressIndicator()
                  : _isProcessing
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(_currentImage!),
                            Container(
                              color: Colors.black54,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : InteractiveViewer(
                          child: Image.file(_currentImage!),
                        ),
            ),
          ),

          // Tools
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Filter buttons
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: AppConstants.imageFilters.length,
                    itemBuilder: (context, index) {
                      final filter = AppConstants.imageFilters[index];
                      final isSelected = _selectedFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _applyFilter(filter),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(color: Colors.white, width: 2)
                                      : null,
                                ),
                                child: _getFilterIcon(filter),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.blue : Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(color: Colors.grey),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.rotate_right,
                      label: 'Rotate',
                      onTap: _rotateImage,
                    ),
                    _buildActionButton(
                      icon: Icons.text_fields,
                      label: 'OCR',
                      onTap: _performOcr,
                      isPremium: true,
                    ),
                    _buildActionButton(
                      icon: Icons.crop,
                      label: 'Crop',
                      onTap: () {
                        Helpers.showSnackBar(context, 'Crop feature coming soon!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFilterIcon(String filter) {
    IconData icon;
    switch (filter) {
      case 'Grayscale':
        icon = Icons.filter_b_and_w;
        break;
      case 'Black & White':
        icon = Icons.contrast;
        break;
      case 'Auto':
        icon = Icons.auto_fix_high;
        break;
      case 'Original':
      default:
        icon = Icons.image;
        break;
    }

    return Icon(icon, color: Colors.white, size: 28);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: _isProcessing ? Colors.grey : Colors.white,
                size: 32,
              ),
              if (isPremium)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _isProcessing ? Colors.grey : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
