import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ekranlar/anaekran.dart';
import 'ekranlar/faturalarekrani.dart';
import 'ekranlar/odemelerekrani.dart';
import 'ekranlar/ayarlarekrani.dart';
import 'ekranlar/evarkadaslariekrani.dart';
import 'widgetlar/global/customappbar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    AnaEkran(),
    FaturalarEkrani(),
    OdemelerEkrani(),
    AyarlarEkrani(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Faturalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Ödemeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
      drawer: _CustomDrawer(
        currentIndex: _currentIndex,
        onItemTap: _onNavTap,
      ),
    );
  }
}

class _CustomDrawer extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTap;

  const _CustomDrawer({
    Key? key,
    required this.currentIndex,
    required this.onItemTap,
  }) : super(key: key);

  @override
  State<_CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<_CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'EvArkadaşım',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ortak Gider Yönetimi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Ana Sayfa'),
            selected: widget.currentIndex == 0,
            selectedTileColor: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            onTap: () {
              widget.onItemTap(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_outlined),
            title: const Text('Faturalar'),
            selected: widget.currentIndex == 1,
            selectedTileColor: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            onTap: () {
              widget.onItemTap(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Ev Arkadaşları'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EvArkadaslariEkrani(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Ödemeler'),
            selected: widget.currentIndex == 2,
            selectedTileColor: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            onTap: () {
              widget.onItemTap(2);
              Navigator.pop(context);
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            selected: widget.currentIndex == 3,
            selectedTileColor: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            onTap: () {
              widget.onItemTap(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EvArkadaşım',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'Ev arkadaşlarınızla giderlerinizi kolay ve adil bir şekilde yönetin.',
      children: [
        const SizedBox(height: 16),
        Text(
          'Yapımcı: Abdullah Omar Ali',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Durum: Production Ready',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
