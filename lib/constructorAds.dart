import 'dart:io' as io;
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'firestore.dart';
import 'package:transparent_image/transparent_image.dart';


class FirestoreDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
      ),
      body: FirestoreDataList(),
    );
  }
}

class FirestoreDataList extends StatefulWidget {
  @override
  State<FirestoreDataList> createState() => _FirestoreDataListState();
}

class _FirestoreDataListState extends State<FirestoreDataList> {
  String? selectedTag;
  String? selectedTransport;
  List<dynamic> imageFiles = []; // Список для хранения файлов изображений
  List<String> uploadedImageUrls =
      []; // Список для хранения URL загруженных изображений

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  Future<dynamic> getImageFromUser() async {
    if (kIsWeb) {
      final inputElement = html.FileUploadInputElement();
      inputElement.accept = 'image/*';
      inputElement.click();
      await inputElement.onChange.first;
      final file = inputElement.files?.first;
      return file;
    } else {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return io.File(pickedFile.path);
      }
      return null;
    }
  }

  Future<String?> uploadImage(dynamic imageFile, String adsname) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'Ads/${adsname}/${kIsWeb ? Path.basename(imageFile.name) : Path.basename(imageFile.path)}');
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = storageReference.putBlob(imageFile);
      } else {
        uploadTask = storageReference.putFile(imageFile);
      }
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  Future<void> deleteImage(String imageUrl) async {
    setState(() {
      uploadedImageUrls.remove(imageUrl);
    });
  }

  Future<void> uploadAllImages(String adsname) async {
    List<String> newUploadedUrls = [];
    for (var imageFile in imageFiles) {
      String? imageUrl = await uploadImage(imageFile, adsname);
      if (imageUrl != null) {
        newUploadedUrls.add(imageUrl);
      }
    }
    setState(() {
      uploadedImageUrls.addAll(newUploadedUrls);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tags').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data found'));
        }

        final documents = snapshot.data!.docs;
        final tags = documents.map((doc) => doc.id).toList();

        if (selectedTag == null && tags.isNotEmpty) {
          selectedTag = tags[0];
        }

        final data = documents.firstWhere((doc) => doc.id == selectedTag).data()
            as Map<String, dynamic>;
        final List<dynamic> arrayData = data['Категории транспорта'] ?? [];

        if (selectedTransport == null && arrayData.isNotEmpty) {
          selectedTransport = arrayData[0].toString();
        }

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedTag,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTag = newValue;
                    selectedTransport =
                        null; // Reset transport when tag changes
                  });
                },
                items: tags.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            if (arrayData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedTransport,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTransport = newValue;
                    });
                  },
                  items:
                      arrayData.map<DropdownMenuItem<String>>((dynamic value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
            if (selectedTag == 'Транспорт' &&
                selectedTransport == 'Автомобили') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Имя товара',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Цена',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Характеристики'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Год выпуска',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _mileageController,
                  decoration: InputDecoration(
                    labelText: 'Пробег',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
            Wrap(
              children: [
                ...uploadedImageUrls.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: entry.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await deleteImage(entry.value);
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                )),
                ...imageFiles.map((file) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      kIsWeb
                          ? FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: html.Url.createObjectUrlFromBlob(file),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                          : Image.file(file, width: 100, height: 100),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imageFiles.remove(file);
                            });
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      var imageFile = await getImageFromUser();
                      if (imageFile != null) {
                        setState(() {
                          imageFiles.add(imageFile);
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await uploadAllImages(_nameController.text);
                  var adsauto = AdsFireStore(
                      selectedTag!,
                      selectedTransport!,
                      _nameController.text,
                      int.tryParse(_priceController.text)!,
                      _addressController.text,
                      int.tryParse(_yearController.text)!,
                      int.tryParse(_mileageController.text)!,
                      uploadedImageUrls);
                  adsauto.addAdsFirestore();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All images uploaded')));
                },
                child: Text('Завершить'),
              ),
            ),
          ],
        );
      },
    );
  }
}
