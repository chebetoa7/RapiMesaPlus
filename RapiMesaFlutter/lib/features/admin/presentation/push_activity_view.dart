import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';

/// Panel de actividad de notificaciones push.
///
/// Dos pestañas:
///  - DISPOSITIVOS: qué dispositivos pueden recibir push, quién los tiene
///    abiertos y cuándo se vio por última vez. Si un dispositivo lleva
///    mucho sin "verse", su token está muerto y ese dispositivo ya no va a
///    recibir push (hay que pedir que abra la app).
///  - ACTIVIDAD: el historial de pushes enviados: quién los originó, a qué
///    audiencia iban, si eran silenciosos o visibles y cuántos dispositivos
///    los aceptaron.
class PushActivityView extends StatefulWidget {
  final String restaurantName;
  final String restaurantId;

  const PushActivityView({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
  });

  @override
  State<PushActivityView> createState() => _PushActivityViewState();
}

class _PushActivityViewState extends State<PushActivityView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devices = await _get('/api/push/devices');
      final history = await _get('/api/push/history?limit=100');
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _messages = history;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _get(String path) async {
    String? lastError;
    for (final base in ApiConfig.candidates) {
      try {
        final resp = await ApiClient.get('$base$path', timeout: const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final list = (data['dispositivos'] ?? data['mensajes'] ?? []) as List?;
          return (list ?? []).map((e) => e as Map<String, dynamic>).toList();
        }
        lastError = 'HTTP ${resp.statusCode}: ${resp.body}';
      } catch (e) {
        lastError = e.toString();
      }
    }
    throw Exception(lastError ?? 'sin respuesta');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2228),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notificaciones', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 17)),
            Text(
              widget.restaurantName,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE25822)))
                : const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFE25822),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Dispositivos (${_devices.length})'),
            Tab(text: 'Actividad (${_messages.length})'),
          ],
        ),
      ),
      body: _error != null
          ? _buildError()
          : _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE25822)))
              : TabBarView(
                  controller: _tabs,
                  children: [_buildDevices(), _buildHistory()],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Color(0xFF9CA3AF), size: 42),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar la actividad de notificaciones',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF), fontSize: 11),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE25822)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevices() {
    if (_devices.isEmpty) {
      return _vacio(
        Icons.devices_other_rounded,
        'Ningún dispositivo registrado',
        'Cuando un mesero, cocinero o tablet abra la app con sesión iniciada, '
            'su dispositivo aparecerá aquí y podrá recibir push.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final d = _devices[i];
        final vencido = d['vencido'] == true;
        final activo = d['activo'] != false;
        final minutos = d['minutosDesdeUltimoContacto'];
        final color = !activo
            ? const Color(0xFF6B7280)
            : vencido
                ? const Color(0xFFEF4444)
                : const Color(0xFF22C55E);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2228),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D323A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d['deviceLabel']?.toString() ?? 'Dispositivo',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _chip(d['role']?.toString() ?? '', const Color(0xFFE25822)),
                ],
              ),
              const SizedBox(height: 10),
              _fila('Plataforma', d['platform']?.toString() ?? '-'),
              _fila('Usuario', (d['userId']?.toString() ?? '-')),
              _fila('Token', d['token']?.toString() ?? '-'),
              _fila(
                'Último contacto',
                minutos == null
                    ? 'nunca'
                    : minutos < 60
                        ? 'hace $minutos min'
                        : minutos < 1440
                            ? 'hace ${(minutos / 60).floor()} h'
                            : 'hace ${(minutos / 1440).floor()} días',
              ),
              if (vencido)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️  Este token lleva más de 24 h sin actualizarse: probablemente '
                    'ya no sirve y ese dispositivo NO recibirá push hasta que abra la app.',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontSize: 11),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _fila(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF), fontSize: 11)),
          ),
          Expanded(
            child: Text(v, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(texto, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _vacio(IconData icon, String titulo, String detalle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 48),
            const SizedBox(height: 14),
            Text(titulo, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_messages.isEmpty) {
      return _vacio(
        Icons.notifications_none_rounded,
        'Todavía no se ha enviado ninguna push',
        'Cada vez que se modifique el menú, entre una comanda o una mesa pida '
            'auxilio, quedará registrado aquí.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final m = _messages[i];
        final silencioso = m['deliveryMode'] == 'silent';
        final status = m['status']?.toString() ?? '';
        final statusColor = switch (status) {
          'sent' => const Color(0xFF22C55E),
          'partial' => const Color(0xFFF59E0B),
          _ => const Color(0xFFEF4444),
        };

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2228),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D323A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    silencioso ? Icons.bolt_rounded : Icons.notifications_active_rounded,
                    color: silencioso ? const Color(0xFF38BDF8) : const Color(0xFFE25822),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m['eventType']?.toString() ?? 'push',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _chip(silencioso ? 'silencioso' : 'visible', silencioso ? const Color(0xFF38BDF8) : const Color(0xFFE25822)),
                  const SizedBox(width: 6),
                  _chip(status, statusColor),
                ],
              ),
              const SizedBox(height: 10),
              _fila('AUDIENCIA', m['audience']?.toString() ?? '-'),
              _fila('ENVIADO POR', m['senderUserId']?.toString() ?? '-'),
              if ((m['targetName']?.toString() ?? '').isNotEmpty)
                _fila('OBJETO', '${m['targetType']} "${m['targetName']}"'),
              if ((m['action']?.toString() ?? '').isNotEmpty)
                _fila('ACCIÓN', m['action'].toString()),
              _fila(
                'DISPOSITIVOS',
                'aceptados ${m['successCount']} / ${m['targetCount']}'
                    '${(m['failureCount'] ?? 0) > 0 ? ' · fallidos ${m['failureCount']}' : ''}',
              ),
              _fila('CUÁNDO', _fecha(m['createdAt']?.toString())),
            ],
          ),
        );
      },
    );
  }

  String _fecha(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final d = DateTime.tryParse(iso);
      if (d == null) return iso;
      final local = d.toLocal();
      String dos(int n) => n.toString().padLeft(2, '0');
      return '${dos(local.day)}/${dos(local.month)} ${dos(local.hour)}:${dos(local.minute)}';
    } catch (_) {
      return iso;
    }
  }
}
