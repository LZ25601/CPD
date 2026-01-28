import 'package:flutter/material.dart';
import 'dart:io';
import 'models/fragrance.dart';
import 'database/database_helper.dart';

class FragranceDetailScreen extends StatelessWidget {
  final Fragrance fragrance;

  const FragranceDetailScreen({super.key, required this.fragrance});

  Future<void> _deleteFragrance(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fragrance'),
        content: Text('Are you sure you want to delete ${fragrance.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await DatabaseHelper.instance.delete(fragrance.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fragrance deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fragrance.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteFragrance(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            if (fragrance.imagePath != null)
              Hero(
                tag: 'fragrance_${fragrance.id}',
                child: Image.file(
                  File(fragrance.imagePath!),
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              )
            else
              _buildPlaceholder(),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  Text(
                    fragrance.brand,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    fragrance.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Size
                  if (fragrance.size != null) ...[
                    _buildInfoRow(
                      icon: Icons.straighten,
                      label: 'Size',
                      value: '${fragrance.size} ml',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Notes
                  if (fragrance.notes != null && fragrance.notes!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.notes,
                      label: 'Notes',
                      value: fragrance.notes!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (fragrance.description != null && fragrance.description!.isNotEmpty) ...[
                    const Divider(height: 32),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fragrance.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child: Icon(
        Icons.local_mall,
        size: 100,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}