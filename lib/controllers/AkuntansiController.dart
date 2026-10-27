import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AkuntansiController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isLoading = false.obs;

  // ==========================================================
  // 1. VARIABEL LABA RUGI & LAPORAN HARIAN
  // ==========================================================
  var totalOmset = 0.obs;
  var totalHPP = 0.obs;
  var totalPengeluaran = 0.obs; // Uang keluar murni untuk Restock
  var labaBersih = 0.obs;
  var biayaOperasional = 0.obs; // Tetap 0 agar UI Laba Rugi aman

  var transactionsList = <Map<String, dynamic>>[].obs;
  var dailyLogs = <Map<String, dynamic>>[].obs;

  // ==========================================================
  // 2. VARIABEL ARUS KAS (CASH FLOW)
  // ==========================================================
  var kenaikanPenurunanPiutang = 0.obs;
  var kenaikanPenurunanPersediaan = 0.obs;
  var kasBersihOperasional = 0.obs;
  var kenaikanPenurunanKas = 0.obs;
  var saldoAwalKas = 0.obs;

  var investasiMasuk = 0.obs;
  var investasiKeluar = 0.obs;
  var kasBersihInvestasi = 0.obs;
  var pendanaanMasuk = 0.obs;
  var pendanaanKeluar = 0.obs;
  var kasBersihPendanaan = 0.obs;

  // ==========================================================
  // 3. VARIABEL NERACA (BALANCE SHEET)
  // ==========================================================
  var kasBesar = 0.obs;
  var bankMandiri = 0.obs;
  var piutangUsaha = 0.obs;
  var totalPersediaanBahan = 0.obs;
  var totalAsetLancar = 0.obs;
  var totalEkuitas = 0.obs;

  // ==========================================================
  // FILTER WAKTU
  // ==========================================================
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  var periodLabel = "Bulan Ini".obs;

  @override
  void onInit() {
    super.onInit();
    setMonth(DateTime.now());
  }

  void setMonth(DateTime date) {
    startDate.value = DateTime(date.year, date.month, 1, 0, 0, 0);
    endDate.value = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    periodLabel.value = DateFormat('MMMM yyyy', 'id_ID').format(date);
    fetchFinancialData();
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = DateTime(start.year, start.month, start.day, 0, 0, 0);
    endDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59);
    String startStr = DateFormat('dd MMM yyyy', 'id_ID').format(start);
    String endStr = DateFormat('dd MMM yyyy', 'id_ID').format(end);
    periodLabel.value = "$startStr - $endStr";
    fetchFinancialData();
  }

  void setAllTime() {
    startDate.value = DateTime(2000, 1, 1);
    endDate.value = DateTime(2100, 12, 31);
    periodLabel.value = "Semua Waktu (Keseluruhan)";
    fetchFinancialData();
  }

  // ==========================================================
  // LOGIKA UTAMA AKUNTANSI (SUPER CEPAT & AKURAT)
  // ==========================================================
  Future<void> fetchFinancialData() async {
    isLoading.value = true;
    try {
      String startStr = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(startDate.value);
      String endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate.value);

      int tempOmset = 0;
      int tempHPP = 0;
      int tempPiutang = 0;
      int tempPengeluaranRestock = 0;

      List<Map<String, dynamic>> tempTransactions = [];
      Map<String, Map<String, int>> dailyDataTemp = {};

      // ---------------------------------------------------------
      // A. MENGHITUNG NILAI ASET GUDANG (REAL-TIME)
      // ---------------------------------------------------------
      // Kita hanya butuh ingredients untuk mengecek nilai sisa harta di gudang
      var ingSnapshot = await _db.collection('ingredients').get();
      int realStokValue = 0;

      for (var doc in ingSnapshot.docs) {
        int price = (doc.data()['unit_price'] as num?)?.toInt() ?? 0;
        int stock = (doc.data()['stock'] as num?)?.toInt() ?? 0;
        realStokValue += (stock * price);
      }

      // ---------------------------------------------------------
      // B. MENGHITUNG OMSET, HPP, & PIUTANG (SNAPHSOT)
      // ---------------------------------------------------------
      var trxSnapshot = await _db
          .collection('transaksi')
          .where('transaction_date', isGreaterThanOrEqualTo: startStr)
          .where('transaction_date', isLessThanOrEqualTo: endStr)
          .orderBy('transaction_date', descending: true)
          .get();

      for (var doc in trxSnapshot.docs) {
        var data = doc.data();
        if (data['is_running_order'] == 0) {
          int bill = (data['total_bill'] as num?)?.toInt() ?? 0;

          // MENGGUNAKAN SNAPSHOT HPP DARI DATABASE TRANSAKSI
          // Jika nota lama belum punya total_hpp, kita beri fallback 40% dari harga jual
          int hpp =
              (data['total_hpp'] as num?)?.toInt() ?? (bill * 0.4).toInt();

          tempOmset += bill;
          tempHPP += hpp;
          tempTransactions.add(data);

          String method =
              data['payment_method']?.toString().toUpperCase() ?? 'TUNAI';
          if (method == 'KASBON' || method == 'TEMPO' || method == 'PIUTANG') {
            tempPiutang += bill;
          }

          // Pencatatan Log Harian
          String day = data['transaction_date'].toString().substring(0, 10);
          if (!dailyDataTemp.containsKey(day))
            dailyDataTemp[day] = {
              'omset': 0,
              'pengeluaran': 0,
              'hpp_harian': 0,
            };
          dailyDataTemp[day]!['omset'] = dailyDataTemp[day]!['omset']! + bill;
          dailyDataTemp[day]!['hpp_harian'] =
              dailyDataTemp[day]!['hpp_harian']! + hpp;
        }
      }

      // ---------------------------------------------------------
      // C. MENGHITUNG PENGELUARAN RESTOCK
      // ---------------------------------------------------------
      var expenseSnapshot = await _db
          .collection('restock_logs')
          .where('restock_date', isGreaterThanOrEqualTo: startStr)
          .where('restock_date', isLessThanOrEqualTo: endStr)
          .get();

      for (var doc in expenseSnapshot.docs) {
        var data = doc.data();
        int expense = (data['total_price'] as num?)?.toInt() ?? 0;
        tempPengeluaranRestock += expense;

        String day = data['restock_date'].toString().substring(0, 10);
        if (!dailyDataTemp.containsKey(day))
          dailyDataTemp[day] = {'omset': 0, 'pengeluaran': 0, 'hpp_harian': 0};
        dailyDataTemp[day]!['pengeluaran'] =
            dailyDataTemp[day]!['pengeluaran']! + expense;
      }

      // ---------------------------------------------------------
      // D. SET HASIL LABA RUGI & ARUS KAS & LIST UI
      // ---------------------------------------------------------
      transactionsList.value = tempTransactions;
      totalOmset.value = tempOmset;
      totalHPP.value = tempHPP;
      totalPengeluaran.value = tempPengeluaranRestock;
      biayaOperasional.value = 0;
      labaBersih.value = tempOmset - tempHPP;

      kenaikanPenurunanPiutang.value = -tempPiutang;
      kenaikanPenurunanPersediaan.value = tempHPP - tempPengeluaranRestock;
      kasBersihOperasional.value =
          labaBersih.value +
          kenaikanPenurunanPiutang.value +
          kenaikanPenurunanPersediaan.value;
      kenaikanPenurunanKas.value = kasBersihOperasional.value;

      var settingsSnap = await _db
          .collection('settings')
          .doc('accounting')
          .get();
      saldoAwalKas.value = settingsSnap.exists
          ? ((settingsSnap.data()?['saldo_awal_kas'] as num?)?.toInt() ?? 0)
          : 0;

      List<Map<String, dynamic>> tempLogs = [];
      dailyDataTemp.forEach((key, value) {
        tempLogs.add({
          'date': key,
          'omset': value['omset'],
          'pengeluaran':
              value['hpp_harian'], // Ubah agar log harian memotong HPP, bukan uang restock
          'laba': value['omset']! - value['hpp_harian']!,
        });
      });
      tempLogs.sort((a, b) => b['date'].compareTo(a['date']));
      dailyLogs.value = tempLogs;

      // =========================================================
      // E. MENGHITUNG NERACA (KUMULATIF DARI AWAL BUKA KAFE)
      // =========================================================
      var historicTrxSnapshot = await _db
          .collection('transaksi')
          .where('transaction_date', isLessThanOrEqualTo: endStr)
          .get();

      int kumulatifOmset = 0;
      int kumulatifPiutang = 0;
      int kumulatifBank = 0;
      int kumulatifHPP = 0;

      for (var doc in historicTrxSnapshot.docs) {
        var data = doc.data();
        if (data['is_running_order'] == 0) {
          int bill = (data['total_bill'] as num?)?.toInt() ?? 0;
          int hpp =
              (data['total_hpp'] as num?)?.toInt() ?? (bill * 0.4).toInt();

          kumulatifOmset += bill;
          kumulatifHPP += hpp;

          String method =
              data['payment_method']?.toString().toUpperCase() ?? 'TUNAI';
          if (method == 'QRIS' ||
              method.contains('TRANSFER') ||
              method.contains('BANK')) {
            kumulatifBank += bill;
          } else if (method == 'KASBON' ||
              method == 'TEMPO' ||
              method == 'PIUTANG') {
            kumulatifPiutang += bill;
          }
        }
      }

      var historicRestockSnapshot = await _db
          .collection('restock_logs')
          .where('restock_date', isLessThanOrEqualTo: endStr)
          .get();

      int kumulatifRestock = 0;
      for (var doc in historicRestockSnapshot.docs) {
        kumulatifRestock += ((doc.data()['total_price'] as num?)?.toInt() ?? 0);
      }

      // 1. SET ASET NERACA
      int kumulatifKenaikanKas =
          (kumulatifOmset - kumulatifPiutang) - kumulatifRestock;
      bankMandiri.value = kumulatifBank;
      kasBesar.value =
          (saldoAwalKas.value + kumulatifKenaikanKas) - kumulatifBank;
      piutangUsaha.value = kumulatifPiutang;
      totalPersediaanBahan.value = realStokValue;

      totalAsetLancar.value =
          kasBesar.value +
          bankMandiri.value +
          piutangUsaha.value +
          totalPersediaanBahan.value;

      // 2. SET EKUITAS (RUMUS AUTO-BALANCE)
      int kumulatifLabaBersih = kumulatifOmset - kumulatifHPP;
      int stokSistem = kumulatifRestock - kumulatifHPP;
      int selisihStok = realStokValue - stokSistem;

      totalEkuitas.value =
          saldoAwalKas.value + kumulatifLabaBersih + selisihStok;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data akuntansi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // HELPER FORMATTING
  // ==========================================================
  String formatRupiah(int number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    if (number < 0) {
      return "( ${formatCurrency.format(number.abs())} )";
    }
    return formatCurrency.format(number);
  }

  String formatDateDisplay(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (e) {
      return dateString;
    }
  }
}
