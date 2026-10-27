import 'package:admin_fungi/controllers/add_product_wizard_controller.dart';
import 'package:admin_fungi/models/admin_product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ingredient_model.dart';
import '../../controllers/ingredient_controller.dart';

class Step2RecipePage extends StatelessWidget {
  Step2RecipePage({super.key});

  final AddProductWizardController controller =
      Get.find<AddProductWizardController>(); // 👇 UBAH MENJADI SEPERTI INI 👇
  final IngredientController ingController =
      Get.isRegistered<IngredientController>()
      ? Get.find<IngredientController>()
      : Get.put(IngredientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Komposisi Resep (Langkah 2/2)",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        int currentIndex = controller.currentVariantIndex.value;
        String currentKey = controller.variantKeys[currentIndex];
        List<RecipeItem> currentRecipe = controller.variantRecipes[currentKey]!;

        return Column(
          children: [
            // --- HEADER INFO VARIAN ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blueGrey[800],
              child: Column(
                children: [
                  Text(
                    "MERACIK RESEP UNTUK",
                    style: TextStyle(
                      color: Colors.blueGrey[300],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentKey == "Default"
                        ? "Semua Pesanan (Tanpa Varian)"
                        : "Varian: $currentKey",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tahap ${currentIndex + 1} dari ${controller.variantKeys.length}",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST BAHAN BAKU ---
            Expanded(
              child: currentRecipe.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Resep masih kosong.",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: currentRecipe.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var item = currentRecipe[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.ingredientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${item.amount} Takaran",
                                    style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      currentRecipe.removeAt(index);
                                      controller.variantRecipes.refresh();
                                    },
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      // --- TOMBOL BAWAH ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade600, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add_circle_outline, color: Colors.blue[700]),
                label: Text(
                  "TAMBAH BAHAN BAKU",
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showAddIngredientSheet(context),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              bool isLast =
                  controller.currentVariantIndex.value ==
                  (controller.variantKeys.length - 1);
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast
                        ? Colors.green[700]
                        : Colors.orange[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (isLast) {
                      controller.saveFinalProduct();
                    } else {
                      controller.currentVariantIndex.value++;
                    }
                  },
                  child: Text(
                    isLast
                        ? "SELESAI & SIMPAN PRODUK"
                        : "LANJUT VARIAN BERIKUTNYA",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Bottom sheet cerdas untuk mencari dan menambah bahan baku
  void _showAddIngredientSheet(BuildContext context) {
    RxList<IngredientModel> filteredList = <IngredientModel>[].obs;
    filteredList.assignAll(ingController.ingredients);
    TextEditingController searchC = TextEditingController();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pilih Bahan Baku",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: searchC,
                decoration: InputDecoration(
                  hintText: "Cari bahan...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  if (val.isEmpty) {
                    filteredList.assignAll(ingController.ingredients);
                  } else {
                    filteredList.assignAll(
                      ingController.ingredients
                          .where(
                            (ing) => ing.name.toLowerCase().contains(
                              val.toLowerCase(),
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredList.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var ing = filteredList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        ing.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text("Gudang: ${ing.stock} ${ing.unit}"),
                      trailing: const Icon(
                        Icons.add_circle_rounded,
                        color: Colors.green,
                        size: 28,
                      ),
                      onTap: () {
                        Get.back(); // Tutup sheet pencarian
                        _inputAmount(ing); // Buka input angka
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _inputAmount(IngredientModel ing) {
    final amountC = TextEditingController();
    Get.defaultDialog(
      title: "Takaran ${ing.name}",
      titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: TextField(
          controller: amountC,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "0",
            suffixText: ing.unit,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "Simpan Bahan",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green[700],
      textCancel: "Batal",
      cancelTextColor: Colors.grey[600],
      onConfirm: () {
        int amount = int.tryParse(amountC.text) ?? 0;
        if (amount > 0) {
          String currentKey =
              controller.variantKeys[controller.currentVariantIndex.value];
          controller.variantRecipes[currentKey]!.add(
            RecipeItem(
              ingredientId: ing.id,
              ingredientName: ing.name,
              amount: amount,
            ),
          );
          controller.variantRecipes.refresh();
          Get.back();
        }
      },
    );
  }
}
