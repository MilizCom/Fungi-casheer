import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/restock_wizard_controller.dart';
import '../../models/ingredient_model.dart';
import 'package:intl/intl.dart';

class RestockStep2Page extends StatelessWidget {
  RestockStep2Page({super.key});

  final RestockWizardController controller =
      Get.find<RestockWizardController>();

  String formatRupiah(int number) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Pengisian Stok (Langkah 2/3)",
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
      body: Obx(() {
        if (controller.selectedIngredients.isEmpty)
          return const SizedBox.shrink();

        int currentIdx = controller.currentIndex.value;
        IngredientModel currentIng = controller.selectedIngredients[currentIdx];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER PROGRESS ---
              Text(
                "BAHAN ${currentIdx + 1} DARI ${controller.selectedIngredients.length}",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey[400],
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),

              // --- KARTU INFO STOK SAAT INI ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.blue[700],
                        ),
                      ),
                      title: Text(
                        currentIng.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "Stok Gudang: ${currentIng.stock} ${currentIng.unit}  •  Stok Bar: ${currentIng.barStock} ${currentIng.unit}",
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Harga Satuan",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            formatRupiah(currentIng.unitPrice),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.green[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- FORM INPUT PENGISIAN STOK ---
              const Text(
                "PENGISIAN STOK GUDANG:",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.qtyC,
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          controller.calculateUnitPrice(currentIng),
                      decoration: InputDecoration(
                        labelText: "Jumlah Tambahan",
                        suffixText: currentIng.unit,
                        prefixIcon: const Icon(Icons.add_shopping_cart_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.priceC,
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          controller.calculateUnitPrice(currentIng),
                      decoration: InputDecoration(
                        labelText: "Total Harga Beli (Rp)",
                        prefixIcon: const Icon(Icons.payments_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- PERINGATAN HPP & PENYESUAIAN KUSTOM ---
              // --- PERINGATAN HPP & PENYESUAIAN KUSTOM ---
              Obx(() {
                if (controller.showPriceWarning.value) {
                  return Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "REKOMENDASI PENYESUAIAN HPP",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Harga beli saat ini (${formatRupiah(controller.latestPurchaseUnitPrice.value)}/${currentIng.unit}) berbeda dengan harga lama (${formatRupiah(currentIng.unitPrice)}/${currentIng.unit}).\n\nUntuk menjaga keakuratan Neraca, sistem menyarankan penggunaan Harga Rata-Rata Tertimbang (Weighted Average Cost).",
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kotak Rekomendasi
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rekomendasi Harga Satuan Baru",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(
                                      controller.recommendedAveragePrice.value,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  controller.customUnitPriceC.text = controller
                                      .recommendedAveragePrice
                                      .value
                                      .toString();
                                  controller.onCustomPriceChanged(currentIng);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange[800],
                                  side: BorderSide(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                                child: const Text("Gunakan Ini"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Atau Ketik Harga Satuan Manual:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.customUnitPriceC,
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              controller.onCustomPriceChanged(currentIng),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- DAFTAR SIMULASI DAMPAK HPP MENU ---
                        if (controller.impactedProducts.isNotEmpty) ...[
                          Text(
                            "ESTIMASI DAMPAK HPP MENU:",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.red[900],
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.impactedProducts.map((impact) {
                            bool isPriceUp = impact.newHpp > impact.oldHpp;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPriceUp
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color: isPriceUp
                                        ? Colors.red
                                        : Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          impact.variantName == '-'
                                              ? impact.productName
                                              : "${impact.productName} (${impact.variantName})",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Memakai ${impact.amountUsed} ${currentIng.unit}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formatRupiah(impact.oldHpp),
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(impact.newHpp),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: isPriceUp
                                              ? Colors.red[700]
                                              : Colors.green[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      }),

      // --- BOTTOM NAVIGATION ---
      bottomNavigationBar: Obx(() {
        if (controller.selectedIngredients.isEmpty)
          return const SizedBox.shrink();

        bool isLast =
            controller.currentIndex.value ==
            controller.selectedIngredients.length - 1;

        // 👇 PERBAIKAN: Gunakan latestPurchaseUnitPrice sebagai validasi input
        int currentPurchasePrice = controller.latestPurchaseUnitPrice.value;
        bool isInputValid = currentPurchasePrice > 0;
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
                backgroundColor: isInputValid
                    ? Colors.green[700]
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: isInputValid
                  ? () => controller.saveDraftAndNext()
                  : null,
              child: Text(
                isLast ? "LIHAT RINGKASAN FINAL" : "SIMPAN DRAFT & LANJUT",
                style: TextStyle(
                  color: isInputValid ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w800,
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
