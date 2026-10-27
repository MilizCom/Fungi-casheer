import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/AkuntansiController.dart';

class LaporanSheets {
  static void showFilterOptions(
    BuildContext context,
    AkuntansiController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Rentang Waktu Laporan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Colors.blue),
              title: const Text("Semua Waktu (Keseluruhan)"),
              onTap: () {
                controller.setAllTime();
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.orange),
              title: const Text("Bulan Ini"),
              onTap: () {
                controller.setMonth(DateTime.now());
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.green),
              title: const Text("Pilih Rentang Tanggal"),
              onTap: () async {
                Get.back();
                DateTime now = DateTime.now();
                DateTime safeStart = controller.startDate.value.year < 2010
                    ? now
                    : controller.startDate.value;
                DateTime safeEnd = controller.endDate.value.year > 2090
                    ? now
                    : controller.endDate.value;

                DateTimeRange? pickedRange = await showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(
                    start: safeStart,
                    end: safeEnd,
                  ),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100, 12, 31),
                );

                if (pickedRange != null) {
                  controller.setDateRange(pickedRange.start, pickedRange.end);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showTransactionDetailSheet(
    AkuntansiController controller,
    Map<String, dynamic> trx,
  ) {
    List<dynamic> items = trx['items'] ?? [];

    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Transaksi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),

            // Info Header Nota
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "No. Nota",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  trx['transaction_id'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Waktu",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  controller.formatDateDisplay(trx['transaction_date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pelanggan",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "${trx['customer_name']} (Meja ${trx['table_number']})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1.5, color: Colors.black12),
            const Text(
              "Daftar Item",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List Items
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var item = items[index];
                  int discount = item['discount'] ?? 0;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item['qty'] ?? 1}x",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['product_name'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if ((item['variant'] ?? '-') != '-')
                              Text(
                                "Varian: ${item['variant']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            if (discount > 0)
                              Text(
                                "Diskon: -${controller.formatRupiah(discount)}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        controller.formatRupiah(item['total'] ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Footer Total
            const Divider(height: 30, thickness: 1.5, color: Colors.black12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Metode Pembayaran",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  trx['payment_method'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.formatRupiah(trx['total_bill'] ?? 0),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static void showDailyLogSheet(
    BuildContext context,
    AkuntansiController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ringkasan Laba Harian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.dailyLogs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada transaksi.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: controller.dailyLogs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var log = controller.dailyLogs[index];
                    bool isProfit = log['laba'] >= 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      title: Text(
                        controller
                            .formatDateDisplay(log['date'])
                            .substring(0, 11),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Masuk: ${controller.formatRupiah(log['omset'])}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Keluar: ${controller.formatRupiah(log['pengeluaran'])}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Laba Bersih",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  controller.formatRupiah(log['laba']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isProfit
                                        ? Colors.blue[800]
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
