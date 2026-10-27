import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/ingredient_model.dart';
import '../models/admin_product_model.dart';

class IngredientController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var ingredients = <IngredientModel>[].obs;
  var isLoading = false.obs;
  var isSyncing = false.obs;
  var lastSyncTimeDisplay = "Belum pernah".obs;

  @override
  void onInit() {
    super.onInit();
    bindIngredients();
    fetchLastSyncTime();
  }

  // ==========================================================
  // 1. MONITOR STOK BAHAN BAKU (REAL-TIME)
  // ==========================================================
  void bindIngredients() {
    _firestore.collection('ingredients').snapshots().listen((snapshot) {
      var list = snapshot.docs
          .map((doc) => IngredientModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sort berdasarkan stok terendah lebih dulu
      list.sort((a, b) => a.stock.compareTo(b.stock));
      ingredients.assignAll(list);
    });
  }

  // ==========================================================
  // 2. CEK WAKTU TERAKHIR SYNC
  // ==========================================================
  Future<void> fetchLastSyncTime() async {
    try {
      var doc = await _firestore
          .collection('system_settings')
          .doc('stock_sync')
          .get();
      if (doc.exists) {
        String lastTime = doc.data()?['last_checked_at'] ?? '';
        if (lastTime.isNotEmpty) {
          try {
            DateTime dt = DateTime.parse(lastTime);
            lastSyncTimeDisplay.value =
                "${dt.day}/${dt.month} ${dt.hour}:${dt.minute}";
          } catch (e) {
            lastSyncTimeDisplay.value = lastTime;
          }
        }
      } else {
        await setInitialSyncPoint();
      }
    } catch (e) {
      print("Error fetchLastSyncTime: $e");
    }
  }

  Future<void> setInitialSyncPoint() async {
    String now = DateTime.now().toString().substring(0, 19);
    await _firestore.collection('system_settings').doc('stock_sync').set({
      'last_checked_at': now,
    });
    lastSyncTimeDisplay.value = "Reset (Baru Saja)";
  }

  // ==========================================================
  // 3. LOGIKA SYNC DENGAN "TRIPLE LOCK" (ANTI DOUBLE)
  // ==========================================================
  Future<void> syncStockFromTransactions() async {
    if (isSyncing.value) {
      print("⚠️ Sync sedang berjalan, permintaan kedua ditolak.");
      return;
    }

    isSyncing.value = true;

    try {
      var settingsDoc = await _firestore
          .collection('system_settings')
          .doc('stock_sync')
          .get();
      String lastCheck =
          settingsDoc.data()?['last_checked_at'] ?? DateTime.now().toString();

      QuerySnapshot trxSnapshot = await _firestore
          .collection('transaksi')
          .where('transaction_date', isGreaterThan: lastCheck)
          .orderBy('transaction_date', descending: false)
          .get();

      if (trxSnapshot.docs.isEmpty) {
        Get.snackbar(
          "Info",
          "Tidak ada transaksi baru.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        isSyncing.value = false;
        return;
      }

      WriteBatch batch = _firestore.batch();
      int processedCount = 0;

      QuerySnapshot productSnapshot = await _firestore
          .collection('products')
          .get();
      Map<String, AdminProductModel> productMapByName = {};
      for (var doc in productSnapshot.docs) {
        var p = AdminProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        productMapByName[p.name.toLowerCase().trim()] = p;
      }

      for (var doc in trxSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> items = data['items'] ?? [];

        for (var item in items) {
          String productName = (item['product_name'] ?? '')
              .toString()
              .toLowerCase()
              .trim();
          String variantName = (item['variant'] ?? '-').toString().trim();
          int qtySold = (item['qty'] ?? 0) as int;

          if (productMapByName.containsKey(productName)) {
            var productMaster = productMapByName[productName]!;
            List<RecipeItem> targetRecipe = [];

            if (variantName != '-' &&
                productMaster.variantRecipes.containsKey(variantName)) {
              targetRecipe = productMaster.variantRecipes[variantName]!;
            } else {
              targetRecipe = productMaster.recipe;
            }

            if (targetRecipe.isNotEmpty) {
              for (var recipeItem in targetRecipe) {
                int totalDeduct = recipeItem.amount * qtySold;
                DocumentReference ingRef = _firestore
                    .collection('ingredients')
                    .doc(recipeItem.ingredientId);

                batch.update(ingRef, {
                  'stock': FieldValue.increment(-totalDeduct),
                });
              }
            }
          }
        }
        processedCount++;
      }

      if (trxSnapshot.docs.isNotEmpty) {
        String newLastCheck = trxSnapshot.docs.last['transaction_date'];
        batch.set(_firestore.collection('system_settings').doc('stock_sync'), {
          'last_checked_at': newLastCheck,
        });
      }

      if (processedCount > 0) {
        await batch.commit();
        fetchLastSyncTime();
        Get.snackbar(
          "Sukses",
          "$processedCount transaksi diproses & stok dipotong.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Info",
          "Semua transaksi baru sudah terhitung sebelumnya (Aman).",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal sync: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  // ==========================================================
  // 4. CRUD BAHAN BAKU (SAVE INGREDIENT REGULER)
  // ==========================================================
  Future<void> saveIngredient({
    String? id,
    required String name,
    required String unit,
    required int stock,
    int minStock = 10,
    int minBarStock = 10,
    bool optionalStock = false,
  }) async {
    isLoading.value = true;
    try {
      if (id == null) {
        IngredientModel newIng = IngredientModel(
          id: '',
          name: name,
          unit: unit,
          stock: stock,
          barStock: 0,
          minStock: minStock,
          minBarStock: minBarStock,
          optionalStock: optionalStock,
          unitPrice: 0,
        );

        await _firestore.collection('ingredients').add({
          ...newIng.toMap(),
          'is_mixed': false, // Penanda bahwa ini bahan baku mentah
        });
      } else {
        await _firestore.collection('ingredients').doc(id).update({
          'name': name,
          'unit': unit,
          'min_stock': minStock,
          'min_bar_stock': minBarStock,
          'optional_stock': optionalStock,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================================================
  // 5. RESTOCK & HARGA RATA-RATA TERTIMBANG (WAC)
  // ========================================================================
  Future<void> restockIngredient({
    required IngredientModel ingredient,
    required int addedQty,
    required int totalPrice,
  }) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final db = FirebaseFirestore.instance;
      DocumentReference ingRef = db
          .collection('ingredients')
          .doc(ingredient.id);
      DocumentReference logRef = db.collection('restock_logs').doc();

      await db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ingRef);

        if (!snapshot.exists) {
          throw Exception("Data bahan baku tidak ditemukan di database!");
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int stokLama = (data['stock'] as num?)?.toInt() ?? 0;
        int hargaSatuanLama = (data['unit_price'] as num?)?.toInt() ?? 0;

        if (stokLama < 0) stokLama = 0;

        int totalNilaiLama = stokLama * hargaSatuanLama;
        int totalNilaiBaru = totalPrice;

        int stokTotalSekarang = stokLama + addedQty;
        int hargaRataRataBaru = 0;

        if (stokTotalSekarang > 0) {
          hargaRataRataBaru =
              (totalNilaiLama + totalNilaiBaru) ~/ stokTotalSekarang;
        }

        transaction.update(ingRef, {
          'stock': stokTotalSekarang,
          'unit_price': hargaRataRataBaru,
        });

        transaction.set(logRef, {
          'ingredient_id': ingredient.id,
          'ingredient_name': ingredient.name,
          'qty_added': addedQty,
          'unit': ingredient.unit,
          'total_price': totalPrice,
          'unit_price': hargaRataRataBaru,
          'restock_date': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
          'restock_by': 'Admin',
        });
      });

      Get.back();
      Get.snackbar(
        "Berhasil",
        "Stok ditambah dan Harga Modal diperbarui otomatis.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan saat menambah stok: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==========================================================
  // 6. MANAJEMEN RESEP PRODUK
  // ==========================================================
  Future<void> saveRecipeToProduct(
    String productId,
    List<RecipeItem> newRecipe, {
    String? variantName,
  }) async {
    try {
      if (variantName != null && variantName != "Default") {
        await _firestore.collection('products').doc(productId).update({
          'variant_recipes.$variantName': newRecipe
              .map((e) => e.toMap())
              .toList(),
        });
      } else {
        await _firestore.collection('products').doc(productId).update({
          'recipe': newRecipe.map((e) => e.toMap()).toList(),
        });
      }
      Get.snackbar(
        "Sukses",
        "Resep ${variantName ?? 'Default'} berhasil disimpan",
      );
    } catch (e) {
      Get.snackbar("Gagal", "$e");
    }
  }

  // ==========================================================
  // 7. EXPORT STOK KE GOOGLE SPREADSHEET
  // ==========================================================
  Future<void> exportStockToSpreadsheet() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (ingredients.isEmpty) {
        Get.back();
        Get.snackbar("Info", "Data stok kosong, tidak ada yang diexport.");
        return;
      }

      List<Map<String, dynamic>> stockData = ingredients.map((ing) {
        return {
          "name": ing.name,
          "unit": ing.unit,
          "stock": ing.stock,
          "min": ing.minStock,
        };
      }).toList();

      Map<String, dynamic> payload = {
        "reportType": "stock",
        "filterLabel": "Semua Stok",
        "items": stockData,
      };

      const String url =
          "https://script.google.com/macros/s/AKfycbzJDQZAuJTdCecUU5rsXfSLy4tM0WYsEjWnIGSMby4KUE5zE1SZ3tMSHNuWBUNX5Bib/exec";

      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: {"Content-Type": "text/plain"},
      );

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 302) {
        Get.snackbar(
          "Sukses",
          "Laporan Stok berhasil dikirim ke Spreadsheet!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw "Server error: ${response.statusCode}";
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        "Gagal",
        "Gagal export stok: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==========================================================
  // 8. CRUD BAHAN CAMPURAN (SEMI-FINISHED GOODS)
  // ==========================================================
  Future<void> saveMixedIngredient({
    String? id,
    required String name,
    required String unit,
    int minStock = 10,
    int minBarStock = 10,
    bool optionalStock = false,
    required int defaultYield, // Parameter baru
    required List<Map<String, dynamic>> composition,
  }) async {
    isLoading.value = true;
    try {
      if (id == null) {
        Map<String, dynamic> newMixedIng = {
          'name': name,
          'unit': unit,
          'stock': 0,
          'bar_stock': 0,
          'min_stock': minStock,
          'min_bar_stock': minBarStock,
          'optional_stock': optionalStock,
          'unit_price': 0,
          'is_mixed': true,
          'default_yield': defaultYield, // Simpan ke database
          'composition': composition,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('ingredients').add(newMixedIng);
      } else {
        await _firestore.collection('ingredients').doc(id).update({
          'name': name,
          'unit': unit,
          'min_stock': minStock,
          'min_bar_stock': minBarStock,
          'optional_stock': optionalStock,
          'default_yield': defaultYield, // Update ke database
          'composition': composition,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan bahan campuran: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
