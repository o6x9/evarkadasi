import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../servisler/firebaseservice.dart';
import '../servisler/sharedpreferencesservice.dart';
import '../componentler/ozetcard.dart';
import '../componentler/faturacard.dart';
import '../widgetlar/global/customappbar.dart';
import '../modeller/fatura_model.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final FirebaseService _firebaseService = FirebaseService();
  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  late DateTime now;
  late DateTime monthStart;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    monthStart = DateTime(now.year, now.month, 1);
  }

  double _calculateTotalExpenses(List<FaturaModel> faturalar) {
    return faturalar.fold(0, (sum, fatura) => sum + fatura.tutar);
  }

  double _calculateMonthlyExpenses(List<FaturaModel> faturalar) {
    return faturalar
        .where((f) =>
            f.tarih.year == now.year &&
            f.tarih.month == now.month)
        .fold(0, (sum, fatura) => sum + fatura.tutar);
  }

  Map<String, double> _getExpensesByCategory(List<FaturaModel> faturalar) {
    final Map<String, double> categories = {};
    for (var fatura in faturalar) {
      categories.update(
        fatura.kategori,
        (value) => value + fatura.tutar,
        ifAbsent: () => fatura.tutar,
      );
    }
    return categories;
  }

  List<PieChartSectionData> _getPieChartSections(
      Map<String, double> categories) {
    final total = categories.values.fold(0.0, (sum, val) => sum + val);
    if (total == 0) return [];

    final colors = [
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    int index = 0;
    return categories.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final section = PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[index % colors.length],
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      index++;
      return section;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'EvArkadaşım',
      ),
      body: StreamBuilder<List<FaturaModel>>(
        stream: _firebaseService.streamFaturalar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final faturalar = snapshot.data ?? [];
          final totalExpenses = _calculateTotalExpenses(faturalar);
          final monthlyExpenses = _calculateMonthlyExpenses(faturalar);
          final categoriesMap = _getExpensesByCategory(faturalar);
          final recentFaturalar = faturalar.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Section
                _buildWelcomeHeader(context),
                const SizedBox(height: 24),

                // Özet Kartlar
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OzetCard(
                      label: 'Toplam Gider',
                      value: currencyFormat.format(totalExpenses),
                      icon: Icons.trending_up,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    OzetCard(
                      label: 'Bu Ayki Gider',
                      value: currencyFormat.format(monthlyExpenses),
                      icon: Icons.calendar_today,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    OzetCard(
                      label: 'Bekleyen Borç',
                      value: currencyFormat.format(totalExpenses * 0.3),
                      icon: Icons.schedule,
                      backgroundColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                    OzetCard(
                      label: 'Ev Arkadaşı',
                      value: '3',
                      icon: Icons.people,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Kategori Pie Chart
                if (categoriesMap.isNotEmpty) ...[
                  Text(
                    'Giderlerin Dağılımı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: _getPieChartSections(categoriesMap),
                        centerSpaceRadius: 0,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Kategori Açıklaması
                if (categoriesMap.isNotEmpty) ...[
                  Text(
                    'Kategori Detayı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...categoriesMap.entries.map((entry) {
                    final total = categoriesMap.values
                        .fold(0.0, (sum, val) => sum + val);
                    final percentage = (entry.value / total) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],

                // Son Faturalar
                Text(
                  'Son Faturalar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (recentFaturalar.isEmpty)
                  _buildEmptyState(context)
                else
                  Column(
                    children: recentFaturalar
                        .map((fatura) => FaturaCard(
                              fatura: fatura,
                              onTap: () {
                                // Navigate to detail
                              },
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Günaydın'
        : now.hour < 18
            ? 'İyi Öğlenler'
            : 'İyi Akşamlar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Ortak Giderler Yöneticinize Hoş Geldiniz',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Fatura Yok',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir fatura eklemek için başlayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(150, 32),
        const SizedBox(height: 24),
        _shimmerBox(double.infinity, 100),
        const SizedBox(height: 16),
        _shimmerBox(double.infinity, 100),
        const SizedBox(height: 16),
        _shimmerBox(double.infinity, 100),
      ],
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
