import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===========================================================================
// 1. CONTROLLER PEMANTAUAN
// ===========================================================================
class MonitorBarController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var ingredients = <Map<String, dynamic>>[].obs;
  var isStoreOpen = false.obs;
  var totalBarItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToBarStock();
  }

  // Menggunakan Snapshot agar Admin bisa melihat perubahan secara REAL-TIME
  // saat Kasir melakukan transaksi atau membuka/menutup shift.
  void _listenToBarStock() {
    _firestore.collection('ingredients').snapshots().listen((snapshot) {
      int tempTotalBar = 0;
      List<Map<String, dynamic>> tempList = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        int barStock = (data['bar_stock'] as num?)?.toInt() ?? 0;
        int stock = (data['stock'] as num?)?.toInt() ?? 0;

        tempTotalBar += barStock;

        tempList.add({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'unit': data['unit'] ?? 'pcs',
          'stock': stock,
          'bar_stock': barStock,
        });
      }

      // Urutkan berdasarkan Abjad
      tempList.sort(
        (a, b) => a['name'].toString().compareTo(b['name'].toString()),
      );

      ingredients.value = tempList;
      totalBarItems.value = tempTotalBar;

      // Logika: Jika ada barang yang dialokasikan di Bar, berarti toko sedang BUKA
      isStoreOpen.value = tempTotalBar > 0;
    });
  }
}

// ===========================================================================
// 2. UI HALAMAN PEMANTAUAN STOK BAR
// ===========================================================================
class MonitorBarPage extends StatelessWidget {
  MonitorBarPage({super.key});

  final MonitorBarController controller = Get.put(MonitorBarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background modern
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pantau Shift & Stok Bar',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // --- HEADER STATUS SHIFT ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Obx(() {
              bool isOpen = controller.isStoreOpen.value;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOpen ? Icons.storefront_rounded : Icons.lock_rounded,
                      color: isOpen
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "STATUS OPERASIONAL",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOpen
                              ? "Kasir Aktif (Shift Buka)"
                              : "Kasir Terkunci (Shift Tutup)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isOpen ? Colors.green[800] : Colors.red[800],
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOpen
                              ? "Ada bahan baku di meja bar."
                              : "Semua stok sudah ditarik ke gudang.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),

          // --- LABEL DAFTAR BAHAN ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ALOKASI STOK SAAT INI",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey,
                    letterSpacing: 1.0,
                  ),
                ),
                Obx(
                  () => Text(
                    "Total: ${controller.totalBarItems.value} Unit",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LIST BAHAN BAKU ---
          Expanded(
            child: Obx(() {
              if (controller.ingredients.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: controller.ingredients.length,
                itemBuilder: (context, index) {
                  var item = controller.ingredients[index];
                  bool isAtBar = item['bar_stock'] > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAtBar
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                        width: isAtBar ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Gudang: ${item['stock']} ${item['unit']}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isAtBar
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "DI MEJA BAR",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isAtBar
                                    ? Colors.green[700]
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${item['bar_stock']} ${item['unit']}",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isAtBar
                                    ? Colors.green[800]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
