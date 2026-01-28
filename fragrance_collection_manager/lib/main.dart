import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/fragrance.dart';
import 'dart:io';
import 'add_fragrance_screen.dart';
import 'fragrance_detail_screen.dart';
import 'notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await _requestPermissions();

  await NotificationService.instance.initialize();
  await NotificationService.instance.scheduleDailyNotification();
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  await Permission.camera.request();
  await Permission.notification.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fragrance Collection',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Fragrance> fragrances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFragrances();
  }

  Future<void> _sendRandomFragranceNotification() async {
    if (fragrances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add some fragrances first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await NotificationService.instance.showRandomFragranceNotification();
  }

  Future<void> _loadFragrances() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.readAllFragrances();
    setState(() {
      fragrances = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fragrance Collection'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: _sendRandomFragranceNotification,
            tooltip: 'Get random suggestion',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fragrances.isEmpty
              ? _buildEmptyState()
              : _buildFragranceGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFragranceScreen(),
            ),
          );
          _loadFragrances();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No fragrances yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first fragrance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFragranceGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: fragrances.length,
      itemBuilder: (context, index) {
        final fragrance = fragrances[index];
        return _buildFragranceCard(fragrance);
      },
    );
  }

  Widget _buildFragranceCard(Fragrance fragrance) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FragranceDetailScreen(fragrance: fragrance),
          ),
        );
        _loadFragrances();
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: fragrance.imagePath != null
                    ? Image.file(
                        File(fragrance.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fragrance.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fragrance.brand,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fragrance.size != null)
                    Text(
                      '${fragrance.size} ml',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.local_mall,
        size: 50,
        color: Colors.grey[400],
      ),
    );
  }
}