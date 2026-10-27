import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/admin_product_model.dart';

class AdminMenuController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var products = <AdminProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindProducts();
  }

  // 1. LIHAT SEMUA PRODUK (REALTIME)
  void bindProducts() {
    isLoading.value = true;
    _firestore.collection('products').orderBy('name').snapshots().listen((
      snapshot,
    ) {
      products.value = snapshot.docs
          .map((doc) => AdminProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
      isLoading.value = false;
    });
  }

  // Di dalam AdminMenuController.dart
  Future<void> addProduct({
    required String name,
    required int price,
    required String category,
    required String subCategory, // <-- TAMBAHKAN INI
    Map<String, int> variantPrices = const {},
    Map<String, dynamic> variantRecipes = const {},
    List<dynamic> defaultRecipe = const [],
  }) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'category': category,
        'subCategory':
            subCategory, // <-- TAMBAHKAN INI (Pastikan sesuai kolom Firebase)
        'image_path': '',
        'variantPrices': variantPrices,
        'variantRecipes': variantRecipes,
        'recipe': defaultRecipe,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 3. EDIT PRODUK (Nama, Harga, Kategori)
  Future<void> updateProduct(
    String id,
    String name,
    int price,
    String category,
  ) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': name,
        'price': price,
        'category': category,
      });
      Get.back(); // Tutup dialog/sheet
      Get.snackbar(
        "Sukses",
        "Data produk diperbarui",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // 4. HAPUS PRODUK
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      Get.snackbar(
        "Dihapus",
        "Produk telah dihapus dari menu",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }
}
