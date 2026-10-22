import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantSubscriptionRecord {
  final String id;
  final String name;
  final String planName;
  final double monthlyPriceUsd;
  final int maxBranches;
  final int usedBranches;
  final int maxAdmins;
  final int usedAdmins;
  final String billingPeriod;
  final bool isPaid;
  final String contactEmail;
  final String contactPhone;

  const RestaurantSubscriptionRecord({
    required this.id,
    required this.name,
    required this.planName,
    required this.monthlyPriceUsd,
    required this.maxBranches,
    required this.usedBranches,
    required this.maxAdmins,
    required this.usedAdmins,
    required this.billingPeriod,
    required this.isPaid,
    required this.contactEmail,
    required this.contactPhone,
  });
}

class SuperAdminDashboardView extends StatefulWidget {
  const SuperAdminDashboardView({super.key});

  @override
  State<SuperAdminDashboardView> createState() => _SuperAdminDashboardViewState();
}

class _SuperAdminDashboardViewState extends State<SuperAdminDashboardView> {
  String _selectedFilter = 'all'; // 'all', 'paid', 'pending'

  final List<RestaurantSubscriptionRecord> _restaurants = [
    const RestaurantSubscriptionRecord(
      id: 'ednas-01',
      name: "Edna's Coffee",
      planName: 'Full (\$89/mes)',
      monthlyPriceUsd: 89.0,
      maxBranches: 3,
      usedBranches: 2,
      maxAdmins: 5,
      usedAdmins: 3,
      billingPeriod: 'Octubre 2026',
      isPaid: true,
      contactEmail: 'edna@ednascoffee.com',
      contactPhone: '+52 55 1234 5678',
    ),
    const RestaurantSubscriptionRecord(
      id: 'dely-02',
      name: 'Dely Burger & Grill',
      planName: 'Express (\$29/mes)',
      monthlyPriceUsd: 29.0,
      maxBranches: 1,
      usedBranches: 1,
      maxAdmins: 2,
      usedAdmins: 2,
      billingPeriod: 'Octubre 2026',
      isPaid: true,
      contactEmail: 'gerencia@delyburger.com',
      contactPhone: '+52 55 9876 5432',
    ),
    const RestaurantSubscriptionRecord(
      id: 'inter-03',
      name: 'Restaurante Internacional',
      planName: 'Enterprise (\$1,000/mes)',
      monthlyPriceUsd: 1000.0,
      maxBranches: 999,
      usedBranches: 6,
      maxAdmins: 999,
      usedAdmins: 14,
      billingPeriod: 'Octubre 2026',
      isPaid: false,
      contactEmail: 'finanzas@grupobistro.com',
      contactPhone: '+52 55 5555 4444',
    ),
    const RestaurantSubscriptionRecord(
      id: 'taco-04',
      name: 'Taco Gourmet Poblano',
      planName: 'Free (\$0/mes)',
      monthlyPriceUsd: 0.0,
      maxBranches: 1,
      usedBranches: 1,
      maxAdmins: 1,
      usedAdmins: 1,
      billingPeriod: 'Octubre 2026',
      isPaid: true,
      contactEmail: 'info@tacogourmet.mx',
      contactPhone: '+52 22 2345 6789',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _restaurants.fold<double>(0, (sum, r) => sum + r.monthlyPriceUsd);
    final paidCount = _restaurants.where((r) => r.isPaid).length;
    final pendingList = _restaurants.where((r) => !r.isPaid).toList();
    final pendingCount = pendingList.length;
    final pendingRevenue = pendingList.fold<double>(0, (sum, r) => sum + r.monthlyPriceUsd);

    final filteredList = _restaurants.where((r) {
      if (_selectedFilter == 'paid') return r.isPaid;
      if (_selectedFilter == 'pending') return !r.isPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2228),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: Color(0xFFE25822), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Panel Super Administrador',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'Sesión: chebetoa7@gmail.com (Plataforma RapiMesa SaaS)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronizando estado de suscripciones...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E2228),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de bienvenida e indicador Super Admin
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D1B14), Color(0xFF1E2228)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE25822).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25822).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.insights, color: Color(0xFFE25822), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control Global de Facturación y Clientes',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitorea el estatus de pago de cada cliente registrado, asigna planes y detecta saldos pendientes.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Métricas Rápidas (KPI Cards)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildKpiCard(
                      title: 'MRR Facturación Mes',
                      value: '\$${totalRevenue.toStringAsFixed(0)} USD',
                      subtitle: '≈ \$${(totalRevenue * 20).toStringAsFixed(0)} MXN',
                      icon: Icons.monetization_on,
                      color: const Color(0xFF10B981),
                      width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                    ),
                    _buildKpiCard(
                      title: 'Clientes Activos',
                      value: '${_restaurants.length}',
                      subtitle: 'Restaurantes',
                      icon: Icons.store,
                      color: const Color(0xFF3B82F6),
                      width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                    ),
                    _buildKpiCard(
                      title: 'Al Corriente (Pagado)',
                      value: '$paidCount',
                      subtitle: 'Suscripciones al día',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF10B981),
                      width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                    ),
                    _buildKpiCard(
                      title: 'Con Deuda / Vencido',
                      value: '$pendingCount',
                      subtitle: '\$${pendingRevenue.toStringAsFixed(0)} USD pendientes',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444),
                      width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Filtros y Cabecera de Directorio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Directorio de Restaurantes',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('all', 'Todos (${_restaurants.length})'),
                    _buildFilterChip('paid', 'Pagados ($paidCount)'),
                    _buildFilterChip('pending', 'Pendientes ($pendingCount)'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de Restaurantes
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildRestaurantCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFE25822),
      backgroundColor: const Color(0xFF1E2228),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFE25822) : const Color(0xFF2D323A),
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = key);
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D323A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: color.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantSubscriptionRecord r) {
    final badgeColor = r.isPaid ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final badgeText = r.isPaid ? 'PAGADO AL DÍA' : 'PAGO PENDIENTE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: r.isPaid ? const Color(0xFF2D323A) : const Color(0xFFEF4444).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${r.id}  •  Plan: ${r.planName}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE25822),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2D323A), height: 1),
          const SizedBox(height: 12),

          // Cuotas de Uso
          Row(
            children: [
              Expanded(
                child: _buildUsageItem(
                  'Sucursales / Rest.',
                  '${r.usedBranches} / ${r.maxBranches == 999 ? "∞" : r.maxBranches}',
                  Icons.business,
                ),
              ),
              Expanded(
                child: _buildUsageItem(
                  'Admins Asignados',
                  '${r.usedAdmins} / ${r.maxAdmins == 999 ? "∞" : r.maxAdmins}',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildUsageItem(
                  'Periodo',
                  r.billingPeriod,
                  Icons.calendar_today,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Botones de Acción Super Admin
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.email_outlined, size: 16),
                label: const Text('Contactar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email: ${r.contactEmail} | Tel: ${r.contactPhone}'),
                      backgroundColor: const Color(0xFF1E2228),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              if (!r.isPaid)
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Marcar Pagado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pago para ${r.name} registrado con éxito.'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Ver Recibo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF2D323A)),
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Recibo emitido para ${r.billingPeriod}: \$${r.monthlyPriceUsd} USD.'),
                        backgroundColor: const Color(0xFF1E2228),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF9CA3AF),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
