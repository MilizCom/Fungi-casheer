import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ==========================================================
// 1. MODEL KATEGORI
// ==========================================================
class CategoryModel {
  final String id;
  final String name;
  final List<String> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.subCategories,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      subCategories: List<String>.from(data['sub_categories'] ?? []),
    );
  }
}

// ==========================================================
// 2. CONTROLLER KATEGORI
// ==========================================================
class AdminCategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindCategories();
  }

  // --- BACA DATA (REALTIME) ---
  void _bindCategories() {
    _firestore.collection('categories').orderBy('name').snapshots().listen((
      snap,
    ) {
      categories.value = snap.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList();
      isLoading.value = false;
    });
  }

  // --- TAMBAH KATEGORI UTAMA ---
  Future<void> addCategory(String name) async {
    try {
      if (name.trim().isEmpty) return;

      // Cek duplikasi
      bool exists = categories.any(
        (cat) => cat.name.toLowerCase() == name.trim().toLowerCase(),
      );
      if (exists) {
        Get.snackbar(
          "Peringatan",
          "Kategori '$name' sudah ada!",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      await _firestore.collection('categories').add({
        'name': name.trim(),
        'sub_categories': [],
      });
      Get.back(); // Tutup dialog
      Get.snackbar(
        "Sukses",
        "Kategori utama ditambahkan.",
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- HAPUS KATEGORI UTAMA ---
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      Get.back();
      Get.snackbar(
        "Dihapus",
        "Kategori utama telah dihapus.",
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // --- TAMBAH SUB KATEGORI ---
  Future<void> addSubCategory(String catId, String subName) async {
    try {
      if (subName.trim().isEmpty) return;
      await _firestore.collection('categories').doc(catId).update({
        'sub_categories': FieldValue.arrayUnion([subName.trim()]),
      });
      Get.back(); // Tutup dialog
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // --- HAPUS SUB KATEGORI ---
  Future<void> deleteSubCategory(String catId, String subName) async {
    try {
      await _firestore.collection('categories').doc(catId).update({
        'sub_categories': FieldValue.arrayRemove([subName]),
      });
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }
}
