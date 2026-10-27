// import 'package:admin_fungi/controllers/AkuntansiController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PengeluaranLainPage extends StatelessWidget {
//   PengeluaranLainPage({super.key});

//   final AkuntansiController controller = Get.find<AkuntansiController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text(
//           "Pengeluaran Lainnya",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // 1. FILTER DATA KHUSUS "KELUAR"
//         var expenses = controller.customRecords
//             .where((record) => record['type'] == 'Keluar')
//             .toList();

//         // 2. HITUNG TOTAL PENGELUARAN LAINNYA
//         int totalExpense = expenses.fold(0, (sum, item) {
//           int amount = (item['amount'] as num?)?.toInt() ?? 0;
//           return sum + amount;
//         });

//         return Column(
//           children: [
//             // HEADER TOTAL PENGELUARAN
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(25),
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.red.shade600, Colors.red.shade400],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.red.withOpacity(0.4),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Total Pengeluaran Lain",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     controller.formatRupiah(totalExpense),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Periode: Sesuai filter di Dashboard Utama",
//                     style: TextStyle(color: Colors.white54, fontSize: 11),
//                   ),
//                 ],
//               ),
//             ),

//             // LIST PENGELUARAN
//             Expanded(
//               child: expenses.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.separated(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       itemCount: expenses.length,
//                       separatorBuilder: (context, index) =>
//                           const SizedBox(height: 12),
//                       itemBuilder: (context, index) {
//                         var item = expenses[index];
//                         int amount = (item['amount'] as num?)?.toInt() ?? 0;
//                         bool isIncluded = item['is_included'] ?? false;
//                         String category =
//                             item['cash_flow_category'] ?? 'Operasional';

//                         return Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: Colors.grey.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.shade50,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_upward,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               const SizedBox(width: 15),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item['title'] ?? '-',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       "${controller.formatDateDisplay(item['date'])} • $category",
//                                       style: const TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       controller.formatRupiah(amount),
//                                       style: TextStyle(
//                                         color: Colors.red[700],
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Switch(
//                                     value: isIncluded,
//                                     activeColor: Colors.blue,
//                                     onChanged: (val) =>
//                                         controller.toggleCustomIncluded(
//                                           item['id'],
//                                           isIncluded,
//                                         ),
//                                   ),
//                                   const Text(
//                                     "Masuk ke Laba",
//                                     style: TextStyle(
//                                       fontSize: 9,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete_outline,
//                                       color: Colors.red,
//                                       size: 20,
//                                     ),
//                                     onPressed: () => _confirmDelete(item['id']),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         );
//       }),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Colors.red[700],
//         onPressed: () => _showAddDialog(context),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "Catat Pengeluaran",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.outbox, size: 60, color: Colors.grey),
//           SizedBox(height: 15),
//           Text(
//             "Belum ada catatan pengeluaran lain.",
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDelete(String id) {
//     Get.defaultDialog(
//       title: "Hapus Catatan?",
//       middleText: "Data ini akan dihapus secara permanen.",
//       textConfirm: "Hapus",
//       textCancel: "Batal",
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.red,
//       onConfirm: () {
//         controller.deleteCustomRecord(id);
//         Get.back();
//       },
//     );
//   }

//   void _showAddDialog(BuildContext context) {
//     final titleC = TextEditingController();
//     final amountC = TextEditingController();
//     String selectedCategory = 'Operasional'; // Default

//     Get.bottomSheet(
//       Container(
//         padding: EdgeInsets.only(
//           top: 20,
//           left: 20,
//           right: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: SingleChildScrollView(
//           child: StatefulBuilder(
//             builder: (context, setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Pengeluaran Baru",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 15),

//                   // 👇 TAMBAHKAN BANNER INFO INI 👇
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.blue.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.info_outline,
//                           color: Colors.blue,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             "Jangan catat belanja Bahan Baku di sini. Pengeluaran bahan baku sudah otomatis tercatat saat Anda melakukan Restock di menu Inventaris.",
//                             style: TextStyle(
//                               color: Colors.blue[800],
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: titleC,
//                     autofocus: true,
//                     decoration: const InputDecoration(
//                       labelText: "Tujuan Pengeluaran",
//                       hintText: "Contoh: Bayar Listrik, Gaji, Beli Mesin",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.description),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: amountC,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: "Nominal (Rp)",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.money_off),
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // DROPDOWN KATEGORI ARUS KAS
//                   const Text(
//                     "Kategori Arus Kas:",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: selectedCategory,
//                         isExpanded: true,
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'Operasional',
//                             child: Text("Operasional (Listrik, Gaji, Sewa)"),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Investasi',
//                             child: Text("Investasi (Beli Aset / Mesin)"),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Pendanaan',
//                             child: Text("Pendanaan (Prive / Bayar Utang)"),
//                           ),
//                         ],
//                         onChanged: (val) {
//                           setState(() {
//                             selectedCategory = val!;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 25),

//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red[700],
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (titleC.text.trim().isEmpty ||
//                             amountC.text.trim().isEmpty) {
//                           Get.snackbar(
//                             "Gagal",
//                             "Semua kolom wajib diisi!",
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                           );
//                           return;
//                         }

//                         int amount =
//                             int.tryParse(
//                               amountC.text.replaceAll(RegExp(r'[^0-9]'), ''),
//                             ) ??
//                             0;
//                         if (amount > 0) {
//                           // Catatan: Tipe dipatenkan "Keluar"
//                           controller.addCustomRecord(
//                             titleC.text.trim(),
//                             "Keluar",
//                             amount,
//                             selectedCategory,
//                           );
//                           Get.back();
//                         }
//                       },
//                       child: const Text(
//                         "SIMPAN PENGELUARAN",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }
// }
