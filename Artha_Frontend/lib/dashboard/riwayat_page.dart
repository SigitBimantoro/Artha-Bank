import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color pageBg = Color(0xFFFAFAFC);

  final List<String> _filters = const [
    'Semua',
    'Top Up',
    'Pembayaran',
    'Isi Saldo',
    'Wishlist',
  ];

  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getHistory();
      if (!mounted) return;
      if (res['success'] == true && res['data'] != null) {
        final data = res['data']['data'];
        setState(() {
          _transactions = data is List ? data : [];
        });
      }
    } catch (e) {
      debugPrint('Error load riwayat: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredTransactions {
    final result = _transactions.where((trx) {
      final type = (trx['transaction_type'] ?? '').toString().toUpperCase();
      final mutasi = (trx['mutasi'] ?? '').toString().toUpperCase();

      switch (_selectedFilter) {
        case 'Top Up':
          return type == 'TOPUP';
        case 'Pembayaran':
          return type == 'PULSA' || type == 'PLN';
        case 'Isi Saldo':
          return type == 'TRANSFER' && mutasi == 'MASUK';
        case 'Wishlist':
          return type == 'SAVING_IN' || type == 'SAVING_OUT';
        default:
          return true;
      }
    }).toList();

    result.sort((a, b) {
      final dateA = _parseTanggal(a['tanggal']);
      final dateB = _parseTanggal(b['tanggal']);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return result;
  }

  Map<String, List<dynamic>> get _groupedTransactions {
    final groups = <String, List<dynamic>>{};
    for (final trx in _filteredTransactions) {
      final date = _parseTanggal(trx['tanggal']);
      final header = date == null ? 'Riwayat' : _formatMonthHeader(date);
      groups.putIfAbsent(header, () => []).add(trx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 28, 28, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  const Text(
                    'Riwayat',
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: 'Poppins',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 72,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 18),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final selected = filter == _selectedFilter;
                  return _buildFilterChip(filter, selected);
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _loadHistory,
                      child: _groupedTransactions.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.fromLTRB(30, 72, 30, 0),
                              children: const [
                                Center(
                                  child: Text(
                                    'Belum ada riwayat',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              padding: const EdgeInsets.only(top: 14),
                              children: _buildGroupedList(),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        height: 50,
        constraints: const BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
          border: Border.all(color: primaryColor, width: 2.4),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : primaryColor,
            fontFamily: 'Poppins',
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final widgets = <Widget>[];
    _groupedTransactions.forEach((month, transactions) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(42, 28, 30, 18),
          child: Text(
            month,
            style: const TextStyle(
              color: primaryColor,
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
      widgets.add(const Divider(height: 1, color: Color(0xFFCFCFCF)));
      for (final trx in transactions) {
        widgets.add(_buildTransactionRow(trx));
        widgets.add(const Divider(height: 1, color: Color(0xFFCFCFCF)));
      }
    });
    widgets.add(const SizedBox(height: 28));
    return widgets;
  }

  Widget _buildTransactionRow(dynamic trx) {
    final view = _TransactionView.from(trx);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 24),
      constraints: const BoxConstraints(minHeight: 136),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: view.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(view.icon, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  view.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  view.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  view.dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            view.amountText,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: view.amountColor,
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static DateTime? _parseTanggal(dynamic value) {
    final raw = (value ?? '').toString();
    if (raw.isEmpty) return null;

    final datePart = raw.split(',').first.trim();
    final parts = datePart.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;

    final day = int.tryParse(parts[0]);
    final month = _monthNumbers[parts[1].toLowerCase()];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  static String _formatMonthHeader(DateTime date) {
    return '${_monthNames[date.month]} ${date.year}';
  }

  static String _formatDateOnly(dynamic value) {
    final raw = (value ?? '').toString();
    final datePart = raw.split(',').first.trim();
    return datePart.isEmpty ? '-' : datePart;
  }

  static String _formatRupiah(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  static const Map<int, String> _monthNames = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };

  static const Map<String, int> _monthNumbers = {
    'jan': 1,
    'januari': 1,
    'feb': 2,
    'februari': 2,
    'mar': 3,
    'maret': 3,
    'apr': 4,
    'april': 4,
    'mei': 5,
    'may': 5,
    'jun': 6,
    'juni': 6,
    'jul': 7,
    'juli': 7,
    'agu': 8,
    'ags': 8,
    'agustus': 8,
    'aug': 8,
    'sep': 9,
    'september': 9,
    'okt': 10,
    'oct': 10,
    'oktober': 10,
    'nov': 11,
    'november': 11,
    'des': 12,
    'dec': 12,
    'desember': 12,
  };
}

class _TransactionView {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color green = Color(0xFF19D65F);
  static const Color red = Color(0xFFFF333F);
  static const Color orange = Color(0xFFFF8A24);
  static const Color blue = Color(0xFF168BEA);

  final String title;
  final String subtitle;
  final String dateText;
  final String amountText;
  final Color amountColor;
  final Color iconColor;
  final IconData icon;

  const _TransactionView({
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.amountText,
    required this.amountColor,
    required this.iconColor,
    required this.icon,
  });

  factory _TransactionView.from(dynamic trx) {
    final type = (trx['transaction_type'] ?? '').toString().toUpperCase();
    final mutasi = (trx['mutasi'] ?? '').toString().toUpperCase();
    final notes = (trx['notes'] ?? '').toString();
    final amount = trx['amount'] is num ? trx['amount'] as num : 0;
    final date = RiwayatPageStateAccess.formatDate(trx['tanggal']);

    String title = 'Transaksi';
    String subtitle = notes.isEmpty ? '-' : notes;
    Color iconColor = blue;
    IconData icon = Icons.receipt_long;
    Color amountColor = mutasi == 'MASUK' ? green : red;
    String amountText =
        '${mutasi == 'MASUK' ? '+' : '-'}Rp ${RiwayatPageStateAccess.rupiah(amount)}';

    if (type == 'TOPUP') {
      title = 'Isi saldo';
      subtitle = notes.isEmpty ? 'Top Up' : notes;
      iconColor = green;
      icon = Icons.arrow_downward;
      amountColor = green;
      amountText = '+Rp ${RiwayatPageStateAccess.rupiah(amount)}';
    } else if (type == 'PULSA' || type == 'PLN') {
      title = 'Pembayaran';
      subtitle = type == 'PLN'
          ? 'Listrik PLN'
          : (notes.isEmpty ? 'Pulsa' : notes);
      iconColor = red;
      icon = Icons.arrow_upward;
      amountColor = red;
      amountText = '-Rp ${RiwayatPageStateAccess.rupiah(amount)}';
    } else if (type == 'SAVING_IN') {
      title = 'Saldo ke Wishlist';
      subtitle = 'Wishlist';
      iconColor = orange;
      icon = Icons.swap_horiz;
      amountColor = primaryColor;
      amountText = 'Rp ${RiwayatPageStateAccess.rupiah(amount)}';
    } else if (type == 'SAVING_OUT') {
      title = 'Uang Masuk';
      subtitle = 'Wishlist';
      iconColor = green;
      icon = Icons.call_received;
      amountColor = green;
      amountText = '+Rp ${RiwayatPageStateAccess.rupiah(amount)}';
    } else if (type == 'TRANSFER') {
      if (mutasi == 'MASUK') {
        title = 'Uang Masuk';
        subtitle = notes.isEmpty ? 'Transfer' : notes;
        iconColor = green;
        icon = Icons.call_received;
        amountColor = green;
        amountText = '+Rp ${RiwayatPageStateAccess.rupiah(amount)}';
      } else {
        title = 'Kirim ke Bank';
        subtitle = notes.isEmpty ? 'Transfer' : notes;
        iconColor = blue;
        icon = Icons.north_east;
        amountColor = red;
        amountText = '-Rp ${RiwayatPageStateAccess.rupiah(amount)}';
      }
    }

    return _TransactionView(
      title: title,
      subtitle: subtitle,
      dateText: date,
      amountText: amountText,
      amountColor: amountColor,
      iconColor: iconColor,
      icon: icon,
    );
  }
}

class RiwayatPageStateAccess {
  static String formatDate(dynamic value) =>
      _RiwayatPageState._formatDateOnly(value);
  static String rupiah(num value) => _RiwayatPageState._formatRupiah(value);
}
