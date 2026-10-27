import 'package:admin_fungi/views/HppMonitorPage.dart';
import 'package:admin_fungi/views/inventorys/restock_step3_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ingredient_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductImpact {
  final String productName;
  final String variantName;
  final int amountUsed;
  final int oldHpp;
  final int newHpp;

  ProductImpact({
    required this.productName,
    required this.variantName,
    required this.amountUsed,
    required this.oldHpp,
    required this.newHpp,
  });
}

class RestockWizardController extends GetxController {
  var selectedIngredients = <IngredientModel>[].obs;
  var searchQuery = ''.obs;

  var currentIndex = 0.obs;
  var pendingRestockData = <String, Map<String, dynamic>>{}.obs;

  final qtyC = TextEditingController();
  final priceC = TextEditingController();
  final customUnitPriceC = TextEditingController();

  // State Deteksi Harga
  var latestPurchaseUnitPrice = 0.obs; // Harga beli SATUAN saat ini saja
  var recommendedAveragePrice = 0.obs; // Harga rata-rata (Moving Average)
  var showPriceWarning = false.obs;
  var impactedProducts = <ProductImpact>[].obs;
  var isSaving = false.obs;

  // --- FINALISASI KE FIREBASE (BATCH WRITE) ---
  Future<void> commitRestock() async {
    isSaving.value = true;
    final db = FirebaseFirestore.instance;
    final batch = db.batch(); // Memulai Batch Write

    try {
      for (var entry in pendingRestockData.entries) {
        String ingId = entry.key;
        var data = entry.value;
        IngredientModel ing = data['ingredient'];
        int qtyAdded = data['qty'];
        int totalPrice = data['total_price'];
        int finalUnitPrice = data['final_unit_price'];

        // 1. UPDATE STOK & HARGA DI KOLEKSI INGREDIENTS
        DocumentReference ingRef = db.collection('ingredients').doc(ingId);
        batch.update(ingRef, {
          'stock': FieldValue.increment(qtyAdded),
          'unit_price': finalUnitPrice,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // 2. BUAT CATATAN RIWAYAT DI KOLEKSI RESTOCK_LOGS
        DocumentReference logRef = db.collection('restock_logs').doc();
        batch.set(logRef, {
          'ingredient_id': ingId,
          'ingredient_name': ing.name,
          'qty_added': qtyAdded,
          'unit': ing.unit,
          'total_price': totalPrice,
          'old_unit_price': ing.unitPrice,
          'new_unit_price': finalUnitPrice,
          'restock_by':
              'Admin Fungi', // Sesuaikan dengan nama user login jika ada
          'restock_date': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Eksekusi semua perintah secara bersamaan
      await batch.commit();

      // Bersihkan memori dan kembali ke Dashboard Inventory
      clearSelection();
      Get.until(
        (route) => Get.currentRoute == '/InventoryDashboard' || route.isFirst,
      );

      Get.snackbar(
        "Berhasil",
        "Semua stok dan riwayat telah diperbarui dengan aman!",
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error Sistem",
        "Gagal menyimpan data: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void toggleSelection(IngredientModel ing) {
    bool exists = selectedIngredients.any((element) => element.id == ing.id);
    if (exists) {
      selectedIngredients.removeWhere((element) => element.id == ing.id);
    } else {
      selectedIngredients.add(ing);
    }
  }

  bool isSelected(IngredientModel ing) {
    return selectedIngredients.any((element) => element.id == ing.id);
  }

  // --- LOGIKA CERDAS: KALKULASI RATA-RATA TERTIMBANG (WAC) ---
  void calculateUnitPrice(IngredientModel currentIng) {
    int addedQty = int.tryParse(qtyC.text) ?? 0;
    int totalPrice = int.tryParse(priceC.text) ?? 0;

    if (addedQty > 0 && totalPrice > 0) {
      // 1. Harga satuan khusus pembelian HARI INI
      latestPurchaseUnitPrice.value = (totalPrice / addedQty).round();

      // 2. RUMUS MOVING AVERAGE COST (AKUNTANSI)
      int totalOldStock = currentIng.stock + currentIng.barStock;
      int oldTotalValue = totalOldStock * currentIng.unitPrice;
      int newTotalValue = oldTotalValue + totalPrice;
      int newTotalStock = totalOldStock + addedQty;

      if (newTotalStock > 0) {
        recommendedAveragePrice.value = (newTotalValue / newTotalStock).round();
      } else {
        recommendedAveragePrice.value = latestPurchaseUnitPrice.value;
      }

      // Tampilkan peringatan HANYA jika harga beli HARI INI berbeda dengan harga lama
      showPriceWarning.value =
          latestPurchaseUnitPrice.value != currentIng.unitPrice;

      // Otomatis isikan kolom kustom dengan harga REKOMENDASI (Rata-rata)
      customUnitPriceC.text = recommendedAveragePrice.value.toString();

      if (showPriceWarning.value) {
        _calculateHppImpact(currentIng, recommendedAveragePrice.value);
      } else {
        impactedProducts.clear();
      }
    } else {
      latestPurchaseUnitPrice.value = 0;
      recommendedAveragePrice.value = 0;
      showPriceWarning.value = false;
      impactedProducts.clear();
    }
  }

  void onCustomPriceChanged(IngredientModel currentIng) {
    int customPrice =
        int.tryParse(customUnitPriceC.text) ?? recommendedAveragePrice.value;
    showPriceWarning.value = customPrice != currentIng.unitPrice;
    if (showPriceWarning.value) {
      _calculateHppImpact(currentIng, customPrice);
    } else {
      impactedProducts.clear();
    }
  }

  void _calculateHppImpact(IngredientModel currentIng, int newUnitPrice) {
    impactedProducts.clear();
    if (!Get.isRegistered<HppMonitorController>())
      Get.put(HppMonitorController());

    final hppC = Get.find<HppMonitorController>();
    int priceDelta = newUnitPrice - currentIng.unitPrice;

    for (var hppDetail in hppC.productHppList) {
      var matchedIngredient = hppDetail.recipeBreakdown.firstWhereOrNull(
        (r) => r.ingredientName == currentIng.name,
      );

      if (matchedIngredient != null) {
        int hppDifference = matchedIngredient.amount * priceDelta;
        int projectedNewHpp = hppDetail.totalHpp + hppDifference;

        impactedProducts.add(
          ProductImpact(
            productName: hppDetail.productName,
            variantName: hppDetail.variantName,
            amountUsed: matchedIngredient.amount,
            oldHpp: hppDetail.totalHpp,
            newHpp: projectedNewHpp,
          ),
        );
      }
    }
  }

  void saveDraftAndNext() {
    IngredientModel currentIng = selectedIngredients[currentIndex.value];
    int finalPrice = showPriceWarning.value
        ? (int.tryParse(customUnitPriceC.text) ?? recommendedAveragePrice.value)
        : currentIng.unitPrice;

    pendingRestockData[currentIng.id] = {
      'ingredient': currentIng,
      'qty': int.tryParse(qtyC.text) ?? 0,
      'total_price': int.tryParse(priceC.text) ?? 0,
      'final_unit_price': finalPrice, // Menggunakan harga yang sudah diamankan
    };

    qtyC.clear();
    priceC.clear();
    customUnitPriceC.clear();
    latestPurchaseUnitPrice.value = 0;
    recommendedAveragePrice.value = 0;
    showPriceWarning.value = false;
    impactedProducts.clear();

    if (currentIndex.value < selectedIngredients.length - 1) {
      currentIndex.value++;
    } else {
      // 👇 UBAH BAGIAN INI 👇
      Get.to(() => RestockStep3Page());
    }
  }

  void clearSelection() {
    selectedIngredients.clear();
    pendingRestockData.clear();
    searchQuery.value = '';
    currentIndex.value = 0;
  }

  @override
  void onClose() {
    qtyC.dispose();
    priceC.dispose();
    customUnitPriceC.dispose();
    clearSelection();
    super.onClose();
  }
}
