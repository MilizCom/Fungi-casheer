import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RestockHistoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var logs = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToRestockLogs();
  }

  void _listenToRestockLogs() {
    _db
        .collection('restock_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            logs.value = snapshot.docs.map((doc) {
              var data = doc.data();
              data['doc_id'] = doc.id;
              return data;
            }).toList();
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar("Error", "Gagal memuat riwayat: $e");
          },
        );
  }

  // --- Helper Format Mata Uang ---
  String formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // --- Helper Format Tanggal ---
  String formatDate(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (e) {
      return dateString;
    }
  }
}
