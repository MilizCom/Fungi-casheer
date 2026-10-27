import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ============================================================================
// 1. CONTROLLER PEMANTAUAN HPP
// ============================================================================
class HppMonitorController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // List untuk menampung hasil kalkulasi UI
  var productHppList = <HppDetailModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHppData();
  }

  Future<void> fetchHppData() async {
    isLoading.value = true;
    try {
      // 1. Ambil semua bahan baku (Ingredients) untuk mendapatkan unit_price terkini
      var ingSnapshot = await _db.collection('ingredients').get();
      Map<String, Map<String, dynamic>> ingredientsMaster = {};

      for (var doc in ingSnapshot.docs) {
        var data = doc.data();
        ingredientsMaster[doc.id] = {
          'name': data['name'] ?? 'Bahan Tidak Diketahui',
          'unit': data['unit'] ?? 'pcs',
          'unit_price': (data['unit_price'] as num?)?.toInt() ?? 0,
        };
      }

      // 2. Ambil semua produk dan resepnya
      var prodSnapshot = await _db.collection('products').get();
      List<HppDetailModel> tempList = [];

      for (var doc in prodSnapshot.docs) {
        var pData = doc.data();
        String productName = pData['name'] ?? 'Produk Unknown';
        int basePrice = (pData['price'] as num?)?.toInt() ?? 0;
        String category = pData['category'] ?? '-';

        // Cek apakah punya Varian
        Map<String, dynamic>? variantRecipes =
            pData['variant_recipes'] ?? pData['variantRecipes'];
        Map<String, dynamic>? variantData =
            pData['variant_data'] ?? pData['variantPrices'];

        if (variantRecipes != null && variantRecipes.isNotEmpty) {
          // --- JIKA PUNYA VARIAN (Pisahkan per varian) ---
          variantRecipes.forEach((variantName, recipeArray) {
            int variantSellPrice = variantData?[variantName] ?? basePrice;
            _calculateAndAddToList(
              tempList,
              ingredientsMaster,
              productName,
              variantName,
              category,
              variantSellPrice,
              recipeArray as List<dynamic>,
            );
          });
        } else {
          // --- JIKA TIDAK PUNYA VARIAN (Gunakan resep default) ---
          List<dynamic> defaultRecipe = pData['recipe'] ?? [];
          _calculateAndAddToList(
            tempList,
            ingredientsMaster,
            productName,
            '-',
            category,
            basePrice,
            defaultRecipe,
          );
        }
      }

      // Urutkan berdasarkan Abjad
      tempList.sort((a, b) => a.productName.compareTo(b.productName));
      productHppList.value = tempList;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data HPP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi internal untuk menghitung dan menyusun data presentasi
  void _calculateAndAddToList(
    List<HppDetailModel> list,
    Map<String, Map<String, dynamic>> ingMaster,
    String prodName,
    String variant,
    String category,
    int sellPrice,
    List<dynamic> recipeRaw,
  ) {
    int totalHpp = 0;
    List<RecipeBreakdown> breakdown = [];

    if (recipeRaw.isNotEmpty) {
      for (var r in recipeRaw) {
        String ingId = r['ingredientId'] ?? r['ingredient_id'] ?? '';
        int amount = (r['amount'] as num?)?.toInt() ?? 0;

        if (ingMaster.containsKey(ingId)) {
          var ingData = ingMaster[ingId]!;
          String ingName = ingData['name'];
          String unit = ingData['unit'];
          int unitPrice = ingData['unit_price'];
          int cost = amount * unitPrice;

          totalHpp += cost;
          breakdown.add(
            RecipeBreakdown(
              ingredientName: ingName,
              amount: amount,
              unit: unit,
              unitPrice: unitPrice,
              totalCost: cost,
            ),
          );
        }
      }
    } else {
      // Fallback jika belum diisi resep
      totalHpp = (sellPrice * 0.4).toInt();
      breakdown.add(
        RecipeBreakdown(
          ingredientName: "Estimasi Default (Belum Ada Resep)",
          amount: 1,
          unit: "paket",
          unitPrice: totalHpp,
          totalCost: totalHpp,
        ),
      );
    }

    list.add(
      HppDetailModel(
        productName: prodName,
        variantName: variant,
        category: category,
        sellingPrice: sellPrice,
        totalHpp: totalHpp,
        recipeBreakdown: breakdown,
      ),
    );
  }

  // Getter untuk pencarian
  List<HppDetailModel> get filteredList {
    if (searchQuery.value.isEmpty) return productHppList;
    return productHppList
        .where(
          (p) =>
              p.productName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              p.category.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  String formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }
}

// ============================================================================
// 2. MODEL DATA KHUSUS UI PEMANTAUAN
// ============================================================================
class HppDetailModel {
  final String productName;
  final String variantName;
  final String category;
  final int sellingPrice;
  final int totalHpp;
  final List<RecipeBreakdown> recipeBreakdown;

  HppDetailModel({
    required this.productName,
    required this.variantName,
    required this.category,
    required this.sellingPrice,
    required this.totalHpp,
    required this.recipeBreakdown,
  });

  int get marginLaba => sellingPrice - totalHpp;
  double get marginPersen =>
      sellingPrice > 0 ? (marginLaba / sellingPrice) * 100 : 0;
}

class RecipeBreakdown {
  final String ingredientName;
  final int amount;
  final String unit;
  final int unitPrice;
  final int totalCost;

  RecipeBreakdown({
    required this.ingredientName,
    required this.amount,
    required this.unit,
    required this.unitPrice,
    required this.totalCost,
  });
}

// ============================================================================
// 3. UI HALAMAN PEMANTAUAN HPP
// ============================================================================
class HppMonitorPage extends StatelessWidget {
  HppMonitorPage({super.key});

  final HppMonitorController controller = Get.put(HppMonitorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Pemantauan HPP Produk",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Cari nama produk atau kategori...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        var list = controller.filteredList;

        if (list.isEmpty) {
          return const Center(
            child: Text(
              "Tidak ada produk ditemukan.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHppData,
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              bool isProfitable = item.marginLaba > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0.5,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (item.variantName != '-') ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "Varian: ${item.variantName}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Harga Jual",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              controller.formatRupiah(item.sellingPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Modal (HPP)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              controller.formatRupiah(item.totalHpp),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BEDAH RESEP & MODAL:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // LIST BAHAN BAKU
                          ...item.recipeBreakdown.map(
                            (resep) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.arrow_right,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resep.ingredientName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "${resep.amount} ${resep.unit}  x  ${controller.formatRupiah(resep.unitPrice)} /${resep.unit}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    controller.formatRupiah(resep.totalCost),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 25, thickness: 1),

                          // RINGKASAN LABA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Modal (HPP)",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                controller.formatRupiah(item.totalHpp),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Estimasi Laba Kotor",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${item.marginPersen.toStringAsFixed(1)}% ",
                                    style: TextStyle(
                                      color: isProfitable
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    controller.formatRupiah(item.marginLaba),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isProfitable
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
