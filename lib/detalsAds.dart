import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot item;

  DetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    var images = item['Изображения'] as List<dynamic>;
    var fields = item.data() as Map<String, dynamic>;

    List<Widget> buildFieldWidgets() {
      List<Widget> fieldWidgets = [];
      fields.forEach((key, value) {
        if (key != 'Изображения') {
          if (value is Map<String, dynamic>) {
            value.forEach((subKey, subValue) {
              fieldWidgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$subKey: $subValue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            });
          } else {
            fieldWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '$key: $value',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }
        }
      });
      return fieldWidgets;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(fields['Имя товара'] ?? 'Подробная информация'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(images[index], fit: BoxFit.cover);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildFieldWidgets(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}