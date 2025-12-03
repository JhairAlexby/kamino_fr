import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class MyRoutesPage extends StatelessWidget {
  const MyRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados de rutas/lugares visitados
    final visitedPlaces = [
      {
        'name': 'Parque Central',
        'date': '02/12/2023',
        'image': 'assets/images/3dmapa.png',
        'distance': '2.5 km',
        'hasLog': true, // Simulación: ya tiene bitácora
      },
      {
        'name': 'Museo de Arte Moderno',
        'date': '28/11/2023',
        'image': 'assets/images/3dmapa.png',
        'distance': '5.1 km',
        'hasLog': false, // Simulación: no tiene bitácora
      },
      {
        'name': 'Jardín Botánico',
        'date': '15/11/2023',
        'image': 'assets/images/3dmapa.png',
        'distance': '3.2 km',
        'hasLog': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF181A20), // AppTheme.textBlack
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Mis Rutas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: visitedPlaces.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no has realizado ninguna ruta',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: visitedPlaces.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final place = visitedPlaces[index];
                        final hasLog = place['hasLog'] as bool;

                        return _RouteCard(place: place, hasLog: hasLog);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatefulWidget {
  final Map<String, Object> place;
  final bool hasLog;

  const _RouteCard({required this.place, required this.hasLog});

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        // Aquí iría la navegación al detalle de la ruta
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Color(0xFF0F172A), AppTheme.textBlack],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.place['image'] as String,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.place['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          widget.place['date'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.straighten, size: 12, color: AppTheme.primaryMint),
                        const SizedBox(width: 4),
                        Text(
                          widget.place['distance'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Botón de Bitácora
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abrir/Crear bitácora próximamente')),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.hasLog 
                              ? AppTheme.primaryMint.withOpacity(0.15) 
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.hasLog 
                                ? AppTheme.primaryMint.withOpacity(0.5) 
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.hasLog ? Icons.menu_book : Icons.add_circle_outline,
                              size: 16,
                              color: widget.hasLog ? AppTheme.primaryMint : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.hasLog ? 'Ver Bitácora' : 'Crear Bitácora',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.hasLog ? AppTheme.primaryMint : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}