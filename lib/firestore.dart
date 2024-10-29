import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constructor_ads.dart';

class AdsFireStore {
  String ads_type;
  String ads_subtype;
  String name;
  int price;
  String address;
  int year_release;
  int mileage;
  List<String> images;

  AdsFireStore(this.ads_type, this.ads_subtype, this.name, this.price, this.address,
      this.year_release, this.mileage, this.images);

  Future<void> addAdsFirestore() async {
    await FirebaseFirestore.instance.collection('ads').add({
      'Тип товара': ads_type,
      'Подтип товара': ads_subtype,
      'Имя товара': name,
      'Цена': price,
      'Адрес': address,
      'Характеристики': {
        'Год выпуска': year_release,
        'Пробег': mileage,
      },
      'Изображения': images,
    });
  }
}



