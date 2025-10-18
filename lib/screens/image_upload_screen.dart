import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<File> selectedImages = [];
  bool uploading = false;
  static const String imgbbApiKey = '6f68fb0d5dacf0ec2b615142d66e872b';
  String? uploadMessage; // persists server message in UI
  final List<String> uploadedImageUrls = [];

  // Function to pick multiple images
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picks = await picker.pickMultiImage();
    if (picks.isNotEmpty) {
      setState(() {
        selectedImages = picks.map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> uploadImage(File image) async {
    if (imgbbApiKey.isEmpty || imgbbApiKey == 'YOUR_API_KEY') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set your IMGBB API key first.')),
      );
      return;
    }

    final url = Uri.parse('https://api.imgbb.com/1/upload?key=' + imgbbApiKey);

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'x-api-key': imgbbApiKey});
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      if (!mounted) return;
      setState(() => uploading = true);
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (!mounted) return;
      setState(() {
        uploading = false;
        if (response.statusCode == 200) {
          uploadMessage = '✅ Image uploaded successfully';
          try {
            final Map<String, dynamic> parsed = jsonDecode(responseBody);
            final String? url = parsed['data']?['url']?.toString();
            if (url != null && url.isNotEmpty) {
              uploadedImageUrls.add(url);
            }
          } catch (_) {
            // ignore parse errors, message is enough
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Image uploaded successfully')),
            );
          }
        } else {
          uploadMessage = '❌ Upload failed: ' + responseBody;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Upload failed: ' + responseBody)),
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        uploading = false;
        uploadMessage = '❌ Upload error: ' + e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload error: ' + e.toString())),
        );
      }
    }
  }

  Future<void> uploadAllSelected() async {
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pick images first.')));
      return;
    }
    uploadMessage = null;
    uploadedImageUrls.clear();
    for (final file in selectedImages) {
      await uploadImage(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Images")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: selectedImages.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 100))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        final file = selectedImages[index];
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(file, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: uploading
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedImages.removeAt(index);
                                        });
                                      },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: uploading ? null : pickImages,
                    child: const Text('Pick Images'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: uploading || selectedImages.isEmpty
                        ? null
                        : uploadAllSelected,
                    child: uploading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Upload All'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (uploadMessage != null)
              Text(
                uploadMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: uploadMessage!.startsWith('✅')
                      ? Colors.green
                      : Colors.red,
                ),
              ),

            if (uploadedImageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: uploadedImageUrls.length,
                  itemBuilder: (context, index) {
                    final url = uploadedImageUrls[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(url, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
