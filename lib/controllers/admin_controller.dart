import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../models/admin_model.dart';
import '../models/admin_product_model.dart';

class AdminController extends GetxController {
  // === DATA RAW ===
  var allTransactions = <TransactionModel>[].obs;
  var allVoids = <VoidModel>[].obs;

  // === DATA FILTERED (Tampil di Layar) ===
  var filteredTransactions = <TransactionModel>[].obs;
  var filteredVoids = <VoidModel>[].obs;

  // === STATISTIK ===
  var dailyStats = <String, int>{}.obs;
  var topTables = <TableStat>[].obs;
  var topProducts = <ProductStat>[].obs;
  var paymentMethodStats = <String, int>{}.obs;

  var totalOmzet = 0.obs;
  var totalTrxCount = 0.obs;
  var totalVoidLost = 0.obs;
  var averageBill = 0.obs;

  // === UI STATE ===
  var isLoading = true.obs;
  var isUploadingSpreadsheet = false.obs;
  var historySearchQuery = ''.obs;
  var historyPaymentFilter = 'Semua'.obs;

  // === FILTER DATE SETTINGS ===
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  var filterLabel = "Hari Ini".obs;
  DateTime? customStartDate;
  DateTime? customEndDate;

  static const String url =
      "https://script.google.com/macros/s/AKfycbzJDQZAuJTdCecUU5rsXfSLy4tM0WYsEjWnIGSMby4KUE5zE1SZ3tMSHNuWBUNX5Bib/exec";

  @override
  void onInit() {
    super.onInit();
    setFilterToday();
    fetchDataFromFirebase();
  }

  // ========================================================================
  // 1. FETCH DATA (MENDUKUNG SKEMA VOID_LOGS TERBARU)
  // ========================================================================
  Future<void> fetchDataFromFirebase() async {
    try {
      isLoading.value = true;
      final firestore = FirebaseFirestore.instance;

      // A. Ambil Transaksi
      var trxSnapshot = await firestore
          .collection('transaksi')
          .orderBy('transaction_date', descending: true)
          .get();

      allTransactions.value = trxSnapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      // B. Ambil Void (Dari collection 'void_logs' yang baru)
      var voidSnapshot = await firestore
          .collection('void_logs')
          .orderBy('void_at', descending: true)
          .get();

      List<VoidModel> parsedVoids = [];

      for (var doc in voidSnapshot.docs) {
        var data = doc.data();
        String voidType = data['void_type'] ?? '';
        String reason = data['void_reason'] ?? data['reason'] ?? 'Tanpa Alasan';
        String trxId = data['transaction_id'] ?? '-';

        // Parsing Tanggal yang Aman
        String cancelDate = '';
        if (data['void_at'] != null && data['void_at'] is Timestamp) {
          cancelDate = (data['void_at'] as Timestamp).toDate().toString();
        } else {
          cancelDate = data['cancel_date'] ?? DateTime.now().toString();
        }

        // Mapping Data Void Full Order (Semua Item dalam 1 Nota dibatalkan)
        if (voidType == 'Full Order') {
          List<dynamic> items = data['items'] ?? [];
          for (var item in items) {
            String variantStr =
                item['variant'] != null && item['variant'] != '-'
                ? ' (${item['variant']})'
                : '';
            parsedVoids.add(
              VoidModel.fromFirestore({
                'transaction_id': trxId,
                'product_name': "${item['product_name'] ?? 'Item'}$variantStr"
                    .trim(),
                'qty': item['qty'] ?? 0,
                'total_lost': item['total'] ?? 0,
                'reason': reason,
                'cancel_date': cancelDate,
              }, doc.id),
            );
          }
        }
        // Mapping Data Void Single Item (Hanya 1 Item dari nota yang dibatalkan)
        else if (voidType == 'Single Item') {
          var item = data['item_canceled'] ?? {};
          String variantStr = item['variant'] != null && item['variant'] != '-'
              ? ' (${item['variant']})'
              : '';
          parsedVoids.add(
            VoidModel.fromFirestore({
              'transaction_id': trxId,
              'product_name': "${item['product_name'] ?? 'Item'}$variantStr"
                  .trim(),
              'qty': item['qty'] ?? 0,
              'total_lost': item['total'] ?? 0,
              'reason': reason,
              'cancel_date': cancelDate,
            }, doc.id),
          );
        }
        // Fallback untuk data lama jika masih ada yang terselip
        else {
          parsedVoids.add(VoidModel.fromFirestore(data, doc.id));
        }
      }

      allVoids.value = parsedVoids;
      filterTransactions();
    } catch (e) {
      print("Error Fetch: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================================================
  // 2. LOGIKA FILTER & STATISTIK
  // ========================================================================
  void filterTransactions() {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end;

    if (filterLabel.value == 'Hari Ini') {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (filterLabel.value == 'Kemarin') {
      DateTime yesterday = now.subtract(const Duration(days: 1));
      start = DateTime(yesterday.year, yesterday.month, yesterday.day);
      end = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
        59,
      );
    } else if (filterLabel.value == 'Bulan Ini') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (filterLabel.value == 'Custom' &&
        customStartDate != null &&
        customEndDate != null) {
      start = DateTime(
        customStartDate!.year,
        customStartDate!.month,
        customStartDate!.day,
      );
      end = DateTime(
        customEndDate!.year,
        customEndDate!.month,
        customEndDate!.day,
        23,
        59,
        59,
      );
    } else {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    filteredTransactions.value = allTransactions.where((trx) {
      try {
        DateTime trxDate = DateTime.parse(trx.transactionDate);
        return trxDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            trxDate.isBefore(end.add(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    filteredVoids.value = allVoids.where((item) {
      try {
        DateTime voidDate =
            DateTime.tryParse(item.cancelDate) ?? DateTime.now();
        return voidDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            voidDate.isBefore(end.add(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    calculateStatistics();
  }

  void calculateStatistics() {
    int omzet = 0;
    int voidLost = 0;

    Map<String, int> tempDaily = {};
    Map<String, int> tableFreqMap = {};
    Map<String, int> tableRevMap = {};
    Map<String, int> payMethodMap = {};
    Map<String, int> prodQtyMap = {};
    Map<String, int> prodRevMap = {};

    for (var trx in filteredTransactions) {
      omzet += trx.totalBill;

      String dateKey = trx.transactionDate.length >= 10
          ? trx.transactionDate.substring(0, 10)
          : trx.transactionDate;
      tempDaily[dateKey] = (tempDaily[dateKey] ?? 0) + trx.totalBill;

      String table = trx.tableNumber;
      if (table != '-' && table.isNotEmpty) {
        tableFreqMap[table] = (tableFreqMap[table] ?? 0) + 1;
        tableRevMap[table] = (tableRevMap[table] ?? 0) + trx.totalBill;
      }

      String pm = trx.paymentMethod;
      payMethodMap[pm] = (payMethodMap[pm] ?? 0) + 1;

      for (var item in trx.items) {
        String name = item['product_name'] ?? item['name'] ?? 'Unknown';
        if (item['variant'] != null && item['variant'] != '-') {
          name += " (${item['variant']})";
        }

        int qty = int.tryParse(item['qty'].toString()) ?? 0;
        int total = int.tryParse(item['total'].toString()) ?? 0;

        prodQtyMap[name] = (prodQtyMap[name] ?? 0) + qty;
        prodRevMap[name] = (prodRevMap[name] ?? 0) + total;
      }
    }

    for (var v in filteredVoids) {
      voidLost += v.totalLost;
    }

    var sortedKeys = tempDaily.keys.toList()..sort();
    Map<String, int> sortedDaily = {
      for (var key in sortedKeys) key: tempDaily[key]!,
    };
    dailyStats.value = sortedDaily;

    List<TableStat> tempTables = [];
    tableFreqMap.forEach((key, freq) {
      tempTables.add(TableStat(key, freq, tableRevMap[key] ?? 0));
    });
    tempTables.sort((a, b) => b.frequency.compareTo(a.frequency));
    topTables.value = tempTables.take(10).toList();

    List<ProductStat> tempTop = [];
    prodQtyMap.forEach((key, qty) {
      tempTop.add(ProductStat(key, qty, prodRevMap[key] ?? 0));
    });
    tempTop.sort((a, b) => b.qtySold.compareTo(a.qtySold));
    topProducts.value = tempTop;

    totalOmzet.value = omzet;
    totalVoidLost.value = voidLost;
    totalTrxCount.value = filteredTransactions.length;
    averageBill.value = filteredTransactions.isEmpty
        ? 0
        : (omzet / filteredTransactions.length).round();
    paymentMethodStats.value = payMethodMap;
  }

  void setFilterToday() {
    filterLabel.value = "Hari Ini";
    filterTransactions();
  }

  void setFilterYesterday() {
    filterLabel.value = "Kemarin";
    filterTransactions();
  }

  void setFilterThisMonth() {
    filterLabel.value = "Bulan Ini";
    filterTransactions();
  }

  void setCustomRange(DateTime start, DateTime end) {
    customStartDate = start;
    customEndDate = end;
    filterLabel.value = "Custom";
    filterTransactions();
  }

  // ========================================================================
  // 3. FUNGSI VOID TRANSAKSI (SINKRONISASI DENGAN VOID_LOGS BARU)
  // ========================================================================
  Future<void> voidTransaction(TransactionModel trx, String reason) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final firestore = FirebaseFirestore.instance;

      QuerySnapshot productSnapshot = await firestore
          .collection('products')
          .get();
      Map<String, AdminProductModel> productMap = {};
      for (var doc in productSnapshot.docs) {
        var p = AdminProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        productMap[p.name.toLowerCase().trim()] = p;
      }

      await firestore.runTransaction((transaction) async {
        DocumentReference trxRef = firestore
            .collection('transaksi')
            .doc(trx.docId);
        DocumentSnapshot snapshot = await transaction.get(trxRef);

        if (!snapshot.exists) {
          trxRef = firestore.collection('history_transaksi').doc(trx.docId);
          snapshot = await transaction.get(trxRef);
          if (!snapshot.exists) {
            throw Exception("Dokumen transaksi tidak ditemukan!");
          }
        }

        // Kembalikan Stok ke Gudang
        for (var item in trx.items) {
          String pName = (item['product_name'] ?? item['name'] ?? '')
              .toString()
              .toLowerCase()
              .trim();
          String variant = (item['variant'] ?? '-').toString();
          int qty = int.tryParse(item['qty'].toString()) ?? 0;

          if (productMap.containsKey(pName)) {
            var productMaster = productMap[pName]!;
            List<RecipeItem> targetRecipe = [];

            if (variant != '-' &&
                productMaster.variantRecipes.containsKey(variant)) {
              targetRecipe = productMaster.variantRecipes[variant]!;
            } else {
              targetRecipe = productMaster.recipe;
            }

            for (var rItem in targetRecipe) {
              DocumentReference ingRef = firestore
                  .collection('ingredients')
                  .doc(rItem.ingredientId);
              transaction.update(ingRef, {
                'stock': FieldValue.increment(rItem.amount * qty),
              });
            }
          }
        }

        // Catat ke format void_logs yang baru
        DocumentReference voidRef = firestore.collection('void_logs').doc();
        transaction.set(voidRef, {
          "transaction_id": trx.transactionId,
          "customer_name": trx.customerName,
          "void_reason": reason,
          "void_type": "Full Order",
          "void_by": "Admin",
          "void_at": FieldValue.serverTimestamp(),
          "items": trx.items,
        });

        transaction.delete(trxRef);
      });

      Get.back();
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        "Sukses",
        "Transaksi berhasil dibatalkan dan stok dikembalikan.",
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );

      await fetchDataFromFirebase();
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print("Error Void: $e");
      Get.snackbar(
        "Gagal",
        "$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========================================================================
  // 4. EXPORT EXCEL & SPREADSHEET
  // ========================================================================
  Future<void> exportToExcel() async {
    if (filteredTransactions.isEmpty) {
      Get.snackbar(
        "Gagal",
        "Data kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      var excel = Excel.createExcel();

      for (var table in excel.tables.keys) {
        excel.delete(table);
      }

      Sheet sheet = excel['Laporan Penjualan'];
      CellValue txt(dynamic v) => TextCellValue(v?.toString() ?? '-');
      CellValue num(int? v) => IntCellValue(v ?? 0);

      sheet.appendRow([
        txt('No'),
        txt('Tanggal'),
        txt('Jam'),
        txt('ID Trx'),
        txt('Meja'),
        txt('Pelanggan'),
        txt('Detail Menu'),
        txt('Metode'),
        txt('Total'),
      ]);

      for (var i = 0; i < filteredTransactions.length; i++) {
        var trx = filteredTransactions[i];
        String date = "-", time = "-";
        try {
          DateTime dt = DateTime.parse(trx.transactionDate);
          date = DateFormat('yyyy-MM-dd').format(dt);
          time = DateFormat('HH:mm').format(dt);
        } catch (_) {
          date = trx.transactionDate;
        }

        String itemsString = trx.items
            .map((e) {
              String name = e['product_name'] ?? e['name'] ?? '-';
              if (e['variant'] != null && e['variant'] != '-')
                name += " (${e['variant']})";
              return "$name x${e['qty']}";
            })
            .join(', ');

        sheet.appendRow([
          num(i + 1),
          txt(date),
          txt(time),
          txt(trx.transactionId),
          txt(trx.tableNumber),
          txt(trx.customerName),
          txt(itemsString),
          txt(trx.paymentMethod),
          num(trx.totalBill),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes == null) throw "Gagal encoding Excel";

      var directory = await getTemporaryDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String filePath = "${directory.path}/Laporan_Fungi_$timestamp.xlsx";

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Fungi Bites - $timestamp');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal export: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSpreadsheet() async {
    try {
      isUploadingSpreadsheet.value = true;
      if (filteredTransactions.isEmpty) {
        Get.snackbar("Info", "Data kosong.");
        return;
      }

      List<Map<String, dynamic>> flatDataToSend = [];
      for (var trx in filteredTransactions) {
        String dateOnly = trx.transactionDate.substring(0, 10);
        String timeOnly = trx.transactionDate.length > 16
            ? trx.transactionDate.substring(11, 16)
            : "-";

        for (var item in trx.items) {
          flatDataToSend.add({
            "id": trx.transactionId,
            "date": dateOnly,
            "time": timeOnly,
            "customer": trx.customerName,
            "table": trx.tableNumber,
            "type": trx.orderType,
            "method": trx.paymentMethod,
            "product": item['product_name'] ?? item['name'] ?? "-",
            "variant": item['variant'] ?? "-",
            "price": item['price'] ?? 0,
            "qty": item['qty'] ?? 0,
            "discount": item['discount'] ?? 0,
            "total": item['total'] ?? 0,
          });
        }
      }

      Map<String, dynamic> payload = {
        "reportType": "sales",
        "filterLabel": filterLabel.value,
        "items": flatDataToSend,
      };

      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: {"Content-Type": "text/plain"},
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        Get.snackbar(
          "Sukses",
          "Data terkirim ke Google Spreadsheet.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Gagal", "$e");
    } finally {
      isUploadingSpreadsheet.value = false;
    }
  }

  Future<void> updateVoidSpreadsheet() async {
    try {
      isUploadingSpreadsheet.value = true;
      if (filteredVoids.isEmpty) {
        Get.snackbar("Info", "Data Void kosong.");
        return;
      }

      List<Map<String, dynamic>> flatDataToSend = [];
      for (var v in filteredVoids) {
        String dateOnly = "-";
        String timeOnly = "-";
        try {
          DateTime dt = DateTime.parse(v.cancelDate);
          dateOnly = DateFormat('yyyy-MM-dd').format(dt);
          timeOnly = DateFormat('HH:mm').format(dt);
        } catch (_) {
          dateOnly = v.cancelDate;
        }

        flatDataToSend.add({
          "date": dateOnly,
          "time": timeOnly,
          "product": v.productName,
          "qty": v.qty,
          "lost": v.totalLost,
          "reason": v.reason,
          "trxId": v.transactionId,
        });
      }

      Map<String, dynamic> payload = {
        "reportType": "void",
        "filterLabel": filterLabel.value,
        "items": flatDataToSend,
      };

      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: {"Content-Type": "text/plain"},
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        Get.snackbar(
          "Sukses",
          "Laporan Pembatalan (Void) berhasil dikirim!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error Upload Void: $e");
      Get.snackbar(
        "Gagal",
        "Gagal upload void: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingSpreadsheet.value = false;
    }
  }

  Future<void> updateTransaction(
    String trxId,
    String newMethod,
    String newTable,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(trxId)
          .update({'payment_method': newMethod, 'table_number': newTable});
      Get.back();
      Get.snackbar(
        "Sukses",
        "Data diperbarui",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchDataFromFirebase();
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "$e");
    }
  }

  // --- Helpers UI ---
  List<TransactionModel> get displayedHistory {
    return filteredTransactions.where((trx) {
      bool matchSearch = true;
      if (historySearchQuery.value.isNotEmpty) {
        String query = historySearchQuery.value.toLowerCase();
        matchSearch =
            trx.customerName.toLowerCase().contains(query) ||
            trx.tableNumber.toLowerCase().contains(query);
      }
      bool matchPayment = true;
      if (historyPaymentFilter.value != 'Semua') {
        matchPayment = trx.paymentMethod == historyPaymentFilter.value;
      }
      return matchSearch && matchPayment;
    }).toList();
  }

  void setHistorySearch(String val) => historySearchQuery.value = val;
  void setHistoryPaymentFilter(String val) => historyPaymentFilter.value = val;
  String formatRupiah(int number) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);
}
