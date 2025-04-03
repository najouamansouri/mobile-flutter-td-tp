import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:show_app_frontend/config/api_config.dart';

class UpdateShowPage extends StatefulWidget {
  final Map<String, dynamic> show;
  
  const UpdateShowPage({super.key, required this.show});

  @override
  _UpdateShowPageState createState() => _UpdateShowPageState();
}

class _UpdateShowPageState extends State<UpdateShowPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing show data
    _titleController = TextEditingController(text: widget.show['title']);
    _descriptionController = TextEditingController(text: widget.show['description']);
    _selectedCategory = widget.show['category'];
    _currentImagePath = widget.show['image'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _updateShow() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and description are required!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    var request = http.MultipartRequest(
      'PUT', 
      Uri.parse('${ApiConfig.baseUrl}/shows/${widget.show['id']}')
    );
    
    // Add text fields
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['category'] = _selectedCategory;
    
    // Add image file if a new one was selected
    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }

    var response = await request.send();
    setState(() => _isUploading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Show updated successfully!")),
      );
      Navigator.pop(context, true); // Return true to trigger a refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update show")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Show"), 
        backgroundColor: Colors.blueAccent
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(value: "movie", child: Text("Movie")),
                DropdownMenuItem(value: "anime", child: Text("Anime")),
                DropdownMenuItem(value: "serie", child: Text("Series")),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 20),
            const Text("Current Image:"),
            const SizedBox(height: 5),
            _imageFile == null
                ? _currentImagePath != null
                    ? Image.network(
                        ApiConfig.baseUrl + _currentImagePath!,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text("Cannot load image")),
                      )
                    : const Center(child: Text("No Image Available"))
                : Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateShow,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      child: const Text("Update Show", style: TextStyle(color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}