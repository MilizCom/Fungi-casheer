import 'package:admin_fungi/models/admin_product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_menu_controller.dart';
import '../controllers/admin_category_controller.dart'; // Import kategori dinamis

class AddProductWizardController extends GetxController {
  // Panggil Category Controller untuk mengambil data dari Firebase
  final AdminCategoryController categoryController = Get.put(
    AdminCategoryController(),
  );

  // === TAHAP 1: INFO DASAR ===
  final nameC = TextEditingController();
  final priceC = TextEditingController();

  // Variabel untuk Dropdown Kategori
  var selectedCategory = RxnString();
  var selectedSubCategory = RxnString();

  var hasVariants = false.obs;
  var variantPrices = <String, int>{}.obs;
  final varNameC = TextEditingController();
  final varPriceC = TextEditingController();

  // === TAHAP 2: RESEP ===
  var variantRecipes = <String, List<RecipeItem>>{}.obs;
  var currentVariantIndex = 0.obs;
  var variantKeys = <String>[].obs;

  void onCategoryChanged(String? val) {
    selectedCategory.value = val;
    selectedSubCategory.value =
        null; // Reset sub-kategori saat kategori utama berubah
  }

  void addVariant() {
    if (varNameC.text.isNotEmpty && varPriceC.text.isNotEmpty) {
      variantPrices[varNameC.text.trim()] = int.tryParse(varPriceC.text) ?? 0;
      varNameC.clear();
      varPriceC.clear();
    }
  }

  void removeVariant(String key) {
    variantPrices.remove(key);
  }

  void prepareRecipeStep() {
    variantKeys.clear();
    variantRecipes.clear();

    if (hasVariants.value && variantPrices.isNotEmpty) {
      variantKeys.addAll(variantPrices.keys);
      for (var key in variantKeys) {
        variantRecipes[key] = <RecipeItem>[];
      }
    } else {
      variantKeys.add("Default");
      variantRecipes["Default"] = <RecipeItem>[];
    }
    currentVariantIndex.value = 0;
  }

  Future<void> saveFinalProduct() async {
    try {
      final adminMenuC = Get.find<AdminMenuController>();

      Map<String, dynamic> formattedVariantRecipes = {};
      List<dynamic> formattedDefaultRecipe = [];

      if (hasVariants.value) {
        for (var key in variantKeys) {
          formattedVariantRecipes[key] = variantRecipes[key]!
              .map(
                (r) => {
                  'ingredient_id': r.ingredientId,
                  'ingredientId': r.ingredientId,
                  'amount': r.amount,
                },
              )
              .toList();
        }
      } else {
        formattedDefaultRecipe = variantRecipes["Default"]!
            .map(
              (r) => {
                'ingredient_id': r.ingredientId,
                'ingredientId': r.ingredientId,
                'amount': r.amount,
              },
            )
            .toList();
      }

      int basePrice = int.tryParse(priceC.text) ?? 0;

      await adminMenuC.addProduct(
        name: nameC.text.trim(),
        price: hasVariants.value ? 0 : basePrice,
        category:
            selectedCategory.value ?? "Tanpa Kategori", // Gunakan dari Dropdown
        subCategory:
            selectedSubCategory.value ?? "Tanpa Sub", // Gunakan dari Dropdown
        variantPrices: variantPrices,
        variantRecipes: formattedVariantRecipes,
        defaultRecipe: formattedDefaultRecipe,
      );

      Get.snackbar(
        "Sukses",
        "Produk & Resep berhasil ditambahkan ke menu!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.delete<AddProductWizardController>();
      Get.until(
        (route) => Get.currentRoute == '/AdminDashboard' || route.isFirst,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menyimpan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    priceC.dispose();
    varNameC.dispose();
    varPriceC.dispose();
    super.onClose();
  }
}
