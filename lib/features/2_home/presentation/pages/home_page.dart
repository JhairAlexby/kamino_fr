import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/home_provider.dart';
import '../widgets/generation_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppTheme.textBlack,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/Mapa.webp'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Buscador arriba
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 16,
                    child: _SearchBar(vm: vm),
                  ),
                  // Botón circular flotante (interés/sugerencias)
                  Positioned(
                    right: 24,
                    bottom: 120,
                    child: FloatingActionButton(
                      backgroundColor: AppTheme.primaryMint,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const GenerationModal(),
                        );
                      },
                      child: Icon(
                        Icons.explore,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                  // Panel: pegar al borde inferior (sin recorte)
                  Positioned.fill(
                    bottom: 0,
                    child: _RecommendationsSheet(vm: vm),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 76,
                backgroundColor: AppTheme.lightMintBackground,
                indicatorColor: AppTheme.primaryMint.withOpacity(0.20),
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return TextStyle(
                    color: selected
                        ? AppTheme.primaryMint
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: selected ? 13 : 12,
                    fontWeight: FontWeight.w600,
                  );
                }),
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return IconThemeData(
                    color: selected
                        ? AppTheme.primaryMint
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    size: selected ? 28 : 26,
                  );
                }),
              ),
              child: NavigationBar(
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: vm.currentTab,
                onDestinationSelected: vm.setTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Bitácoras',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final HomeProvider vm;
  const _SearchBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: vm.searchController,
        onChanged: vm.onSearchChanged,
        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        cursorColor: AppTheme.primaryMint,
        decoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryMint),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _RecommendationsSheet extends StatefulWidget {
  final HomeProvider vm;
  const _RecommendationsSheet({required this.vm});

  @override
  State<_RecommendationsSheet> createState() => _RecommendationsSheetState();
}

class _RecommendationsSheetState extends State<_RecommendationsSheet> {
  bool _showContent = false;
  static const double _revealThreshold = 0.18; // mostrar contenido al superar este tamaño

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.10, // más corto al estar escondido
      minChildSize: 0.08,
      maxChildSize: 0.50,
      snap: true,
      snapSizes: const [0.10, 0.30, 0.50],
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (n) {
            final shouldShow = n.extent >= _revealThreshold;
            if (shouldShow != _showContent) {
              setState(() => _showContent = shouldShow);
            }
            return false;
          },
          child: Container(
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Handle y título
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint, // color de la app
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Recomendaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Contenido: solo cuando esté expandido más allá del umbral
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 180),
                    crossFadeState: _showContent
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.vm.recommendations.length,
                      itemBuilder: (_, i) {
                        final rec = widget.vm.recommendations[i];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(rec.title),
                            subtitle: Text('${rec.category} • ${rec.distanceText}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.directions_outlined),
                              onPressed: () => widget.vm.onNavigateTo(rec),
                            ),
                            onTap: () => widget.vm.onSelect(rec),
                          ),
                        );
                      },
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}