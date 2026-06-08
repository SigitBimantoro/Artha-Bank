import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateWishlistPage extends StatefulWidget {
  const CreateWishlistPage({super.key});

  @override
  State<CreateWishlistPage> createState() => _CreateWishlistPageState();
}

class _CreateWishlistPageState extends State<CreateWishlistPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color panelColor = Color(0xFF5357D4);

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _autoDebitNominalController =
      TextEditingController();
  final FocusNode _namaFocus = FocusNode();

  bool _autoDebit = false;
  bool _periodeExpanded = false;
  bool _scheduleExpanded = false;
  bool _scheduleManualMode = false;
  bool _isSubmitting = false;
  String _selectedPeriode = 'MONTHLY';
  String _selectedSchedule = 'Pilih jadwal';
  final TextEditingController _scheduleInputController =
      TextEditingController();
  late DateTime _selectedScheduleDate;
  late DateTime _draftScheduleDate;
  late DateTime _visibleMonth;
  final List<Map<String, String>> _periodeOptions = [
    {'label': 'Harian', 'value': 'DAILY'},
    {'label': 'Mingguan', 'value': 'WEEKLY'},
    {'label': 'Bulanan', 'value': 'MONTHLY'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedScheduleDate = DateTime.now().add(const Duration(days: 1));
    _draftScheduleDate = _selectedScheduleDate;
    _visibleMonth = DateTime(
      _selectedScheduleDate.year,
      _selectedScheduleDate.month,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _namaFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetController.dispose();
    _autoDebitNominalController.dispose();
    _scheduleInputController.dispose();
    _namaFocus.dispose();
    super.dispose();
  }

  double _parseNominal(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _dayName(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }

  String _formatSchedule(DateTime date) {
    return '${_dayName(date)}, ${date.day} ${_monthName(date.month)} ${date.year}';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _openScheduleManual() {
    setState(() {
      _scheduleManualMode = true;
      _scheduleInputController.text = '';
      _scheduleExpanded = true;
    });
  }

  DateTime? _tryParseManualSchedule(String value) {
    final input = value.trim();
    final parts = input.split(RegExp(r'[-/]'));
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  Future<void> _submit() async {
    final nama = _namaController.text.trim();
    final target = _parseNominal(_targetController.text);
    final autoDebitNominal = _parseNominal(_autoDebitNominalController.text);
    final autoDebitPeriode = _autoDebit ? _selectedPeriode : 'NONE';

    if (nama.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan target wishlist wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final res = await ApiService.createSaving(
      namaTarget: nama,
      targetNominal: target,
      autoDebitNominal: _autoDebit ? autoDebitNominal : 0,
      autoDebitPeriode: autoDebitPeriode,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal membuat wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          cursorColor: primaryColor,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: primaryColor.withValues(alpha: 0.65),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPicker() {
    const weekdayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final gridStart = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );
    final dates = List.generate(42, (index) {
      return gridStart.add(Duration(days: index));
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Tanggal',
            style: TextStyle(
              color: primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _scheduleManualMode
                      ? _formatSchedule(_draftScheduleDate)
                      : _formatSchedule(_draftScheduleDate),
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              _buildCalendarIconButton(Icons.chevron_left, () {
                setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  );
                });
              }),
              const SizedBox(width: 10),
              _buildCalendarIconButton(Icons.chevron_right, () {
                setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                });
              }),
              const SizedBox(width: 10),
              _buildCalendarIconButton(
                Icons.edit_outlined,
                _openScheduleManual,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                Row(
                  children: weekdayLabels.map((label) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF929292),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dates.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final isCurrentMonth = date.month == _visibleMonth.month;
                    final isSelected = _isSameDate(date, _draftScheduleDate);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _draftScheduleDate = date;
                          _visibleMonth = DateTime(date.year, date.month);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isCurrentMonth
                                      ? primaryColor
                                      : const Color(0xFF4A4A4A)),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _scheduleInputController,
                keyboardType: TextInputType.datetime,
                cursorColor: primaryColor,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Masukan Tanggal',
                  hintStyle: TextStyle(
                    color: primaryColor.withValues(alpha: 0.45),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ),
            crossFadeState: _scheduleManualMode
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _draftScheduleDate = _selectedScheduleDate;
                      _visibleMonth = DateTime(
                        _selectedScheduleDate.year,
                        _selectedScheduleDate.month,
                      );
                      _scheduleManualMode = false;
                      _scheduleInputController.clear();
                      _scheduleExpanded = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_scheduleManualMode) {
                        final parsed = _tryParseManualSchedule(
                          _scheduleInputController.text,
                        );
                        if (parsed != null) {
                          _selectedScheduleDate = parsed;
                          _draftScheduleDate = parsed;
                          _visibleMonth = DateTime(parsed.year, parsed.month);
                          _scheduleManualMode = false;
                          _scheduleInputController.clear();
                        }
                      } else {
                        _selectedScheduleDate = _draftScheduleDate;
                      }
                      _selectedSchedule = _formatSchedule(
                        _selectedScheduleDate,
                      );
                      _scheduleExpanded = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Oke',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildAutoDebitToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 22, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Auto-Debit',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Switch(
                value: _autoDebit,
                activeThumbColor: Colors.white,
                activeTrackColor: primaryColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFA6A6A6),
                onChanged: (value) => setState(() => _autoDebit = value),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Periode Auto debit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _periodeExpanded = !_periodeExpanded),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: _periodeExpanded
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              )
                            : BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _periodeOptions.firstWhere(
                                (opt) => opt['value'] == _selectedPeriode,
                              )['label']!,
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Icon(
                            _periodeExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: primaryColor,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: Column(
                        children: _periodeOptions.map((opt) {
                          final isSelected = _selectedPeriode == opt['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPeriode = opt['value']!;
                                _periodeExpanded = false;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 22,
                              ),
                              child: Text(
                                opt['label']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF4A4A4A)
                                      : const Color(0xFF4A4A4A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    crossFadeState: _periodeExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 180),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Jadwal Auto-Debit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() {
                      _draftScheduleDate = _selectedScheduleDate;
                      _visibleMonth = DateTime(
                        _selectedScheduleDate.year,
                        _selectedScheduleDate.month,
                      );
                      _scheduleExpanded = !_scheduleExpanded;
                    }),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedSchedule,
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildCalendarPicker(),
                    ),
                    crossFadeState: _scheduleExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nominal Auto-Debit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _autoDebitNominalController,
                      keyboardType: TextInputType.number,
                      cursorColor: primaryColor,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukan Nominal',
                        hintStyle: TextStyle(
                          color: Color(0xFF8E90E7),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: _autoDebit
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildBackButton(),
                      const Expanded(
                        child: Text(
                          'Buat Wishlist',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 54),
                  _buildTextField(
                    label: 'Nama Wishlist',
                    controller: _namaController,
                    focusNode: _namaFocus,
                    hintText: 'Meja Belajar',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Target Wishlist',
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    hintText: 'Rp200.000',
                  ),
                  const SizedBox(height: 22),
                  _buildAutoDebitToggle(),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.65,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Buat Wishlist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
