import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/restock_wizard_controller.dart';
import 'package:intl/intl.dart';

class RestockStep3Page extends StatelessWidget {
  RestockStep3Page({super.key});

  final RestockWizardController controller =
      Get.find<RestockWizardController>();

  String formatRupiah(int number) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);

  @override
  Widget build(BuildContext context) {
    // Menghitung Total Keseluruhan Pengeluaran Restock
    int grandTotal = 0;
    for (var data in controller.pendingRestockData.values) {
      grandTotal += (data['total_price'] as int);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Ringkasan Final (Langkah 3/3)",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TINJAU KEMBALI DATA RESTOCK",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),

            // --- LIST DRAFT BARANG ---
            ...controller.pendingRestockData.values.map((data) {
              var ing = data['ingredient'];
              int qty = data['qty'];
              int totalPrice = data['total_price'];
              int oldPrice = ing.unitPrice;
              int newPrice = data['final_unit_price'];
              bool isPriceChanged = oldPrice != newPrice;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_task_rounded,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ing.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ditambah: $qty ${ing.unit}",
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (isPriceChanged) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.insights_rounded,
                                  size: 12,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Harga Satuan Baru: ${formatRupiah(newPrice)}",
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Subtotal",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          formatRupiah(totalPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // --- KARTU GRAND TOTAL ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL BELANJA:",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    formatRupiah(grandTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM BAR: TOMBOL SIMPAN ---
      bottomNavigationBar: Obx(() {
        return Container(
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
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.commitRestock(),
              child: controller.isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "KONFIRMASI & SIMPAN STOK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
