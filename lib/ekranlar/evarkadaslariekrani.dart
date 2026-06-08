import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../servisler/firebaseservice.dart';
import '../servisler/supabaseservice.dart';
import '../componentler/evarkadasicard.dart';
import '../widgetlar/global/customappbar.dart';
import '../modeller/evarkadasi_model.dart';

class EvArkadaslariEkrani extends StatefulWidget {
  const EvArkadaslariEkrani({Key? key}) : super(key: key);

  @override
  State<EvArkadaslariEkrani> createState() => _EvArkadaslariEkraniState();
}

class _EvArkadaslariEkraniState extends State<EvArkadaslariEkrani> {
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  void _showAddEvArkadasiDialog() {
    final adController = TextEditingController();
    final soyadController = TextEditingController();
    final emailController = TextEditingController();
    final telefonController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Ev Arkadaşı'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fotoğraf seçme
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = image;
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: selectedImage == null
                        ? Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              selectedImage as dynamic,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: soyadController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                if (adController.text.isNotEmpty &&
                    soyadController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  String fotoUrl = '';

                  if (selectedImage != null) {
                    try {
                      final uploadedUrl = await _supabaseService
                          .uploadProfilePhoto(
                        imageFile: selectedImage!,
                        userId: DateTime.now().toString(),
                      )
                          .then((url) => url ?? '');
                      fotoUrl = uploadedUrl;
                    } catch (e) {
                      debugPrint('Fotoğraf yüklemede hata: $e');
                    }
                  }

                  final evArkadasi = EvArkadasiModel(
                    id: DateTime.now().toString(),
                    ad: adController.text,
                    soyad: soyadController.text,
                    email: emailController.text,
                    telefon: telefonController.text,
                    fotoUrl: fotoUrl,
                  );

                  await _firebaseService.addEvArkadasi(evArkadasi);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ev arkadaşı başarıyla eklendi')),
                    );
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, EvArkadasiModel evArkadasi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil'),
        content: Text(
            '${evArkadasi.adSoyad} adlı kişiyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _firebaseService.deleteEvArkadasi(evArkadasi.id);
              if (evArkadasi.fotoUrl.isNotEmpty) {
                _supabaseService.deleteImage(evArkadasi.fotoUrl);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ev arkadaşı silindi')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ev Arkadaşları',
      ),
      body: StreamBuilder<List<EvArkadasiModel>>(
        stream: _firebaseService.streamEvArkadaşları(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final evArkadaşları = snapshot.data ?? [];

          if (evArkadaşları.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24, top: 16),
            itemCount: evArkadaşları.length,
            itemBuilder: (context, index) {
              return EvArkadasiCard(
                evArkadasi: evArkadaşları[index],
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Düzenleme yakında...')),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, evArkadaşları[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEvArkadasiDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ev Arkadaşı Ekle'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Ev Arkadaşı Bulunamadı',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir ev arkadaşı eklemek için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
