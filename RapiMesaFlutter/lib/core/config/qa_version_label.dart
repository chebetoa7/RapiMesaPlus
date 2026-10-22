import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/environment_service.dart';

/// Label de versión que abre el conmutador de entorno.
///
/// Gesto: **5 toques** en "v1.0.0 (Flutter)" y después la contraseña del
/// modo QA (la de `keylocal.txt`).
///
/// En un build de PRODUCCIÓN (sin `--dart-define=QA_PASSWORD`) el gesto
/// está muerto: no hay contraseña válida y no ocurre nada. El conmutador
/// solo existe en los builds de QA.
class QaVersionLabel extends StatefulWidget {
  final String versionText;

  const QaVersionLabel({
    super.key,
    this.versionText = 'v1.0.0 (Flutter)',
  });

  @override
  State<QaVersionLabel> createState() => _QaVersionLabelState();
}

class _QaVersionLabelState extends State<QaVersionLabel> {
  /// Tokes necesarios para abrir el conmutador.
  static const int _toquesNecesarios = 5;

  /// Tiempo sin tocar que reinicia la cuenta.
  static const Duration _ventana = Duration(milliseconds: 2500);

  int _toques = 0;
  Timer? _reinicio;

  @override
  void dispose() {
    _reinicio?.cancel();
    super.dispose();
  }

  void _alTocar() {
    final env = EnvironmentService.instance;

    // Build de producción: no hay contraseña, el gesto no hace nada.
    if (env.qaDeshabilitado) return;

    _toques++;
    _reinicio?.cancel();
    _reinicio = Timer(_ventana, () => _toques = 0);

    if (_toques >= _toquesNecesarios) {
      _toques = 0;
      _abrirConmutador();
    } else if (_toques >= 3) {
      // Aviso sutil de que el gesto está siendo detectado.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_toquesNecesarios - _toques} toque(s) más para el conmutador QA'),
          duration: const Duration(milliseconds: 900),
          backgroundColor: const Color(0xFF1E2228),
        ),
      );
    }
  }

  Future<void> _abrirConmutador() async {
    final env = EnvironmentService.instance;
    final contrasena = TextEditingController();
    final url = TextEditingController(text: env.baseUrl);

    final resultado = await showDialog<_ResultadoConmutador>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogoConmutador(
        contrasena: contrasena,
        url: url,
        esQaActual: env.esQa,
      ),
    );

    if (resultado == null) return;

    if (!env.passwordCorrecta(resultado.contrasena)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña incorrecta'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    await env.setEntorno(
      resultado.qa ? AppEnvironment.qa : AppEnvironment.production,
      qaUrl: resultado.url,
    );

    if (!mounted) return;

    final destino = env.esQa ? 'QA (red local)' : 'PRODUCCIÓN';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entorno: $destino · ${env.baseUrl}'),
        backgroundColor: env.esQa ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
        duration: const Duration(seconds: 4),
      ),
    );

    // Se vuelve al login para que TODO se reinicialice contra el backend
    // nuevo: sesión, token de push (que hay que volver a registrar en el
    // backend correcto) y datos del menú.
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final env = EnvironmentService.instance;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _alTocar,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.versionText,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: const Color(0xFF666666),
              fontSize: 12,
            ),
          ),
          if (env.esQa) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.6)),
              ),
              child: Text(
                'QA',
                style: GoogleFonts.lato(
                  color: const Color(0xFFF59E0B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultadoConmutador {
  final String contrasena;
  final String url;
  final bool qa;

  _ResultadoConmutador({
    required this.contrasena,
    required this.url,
    required this.qa,
  });
}

class _DialogoConmutador extends StatefulWidget {
  final TextEditingController contrasena;
  final TextEditingController url;
  final bool esQaActual;

  const _DialogoConmutador({
    required this.contrasena,
    required this.url,
    required this.esQaActual,
  });

  @override
  State<_DialogoConmutador> createState() => _DialogoConmutadorState();
}

class _DialogoConmutadorState extends State<_DialogoConmutador> {
  bool _qa = true;
  bool _oculta = true;

  @override
  void initState() {
    super.initState();
    _qa = widget.esQaActual;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2228),
      title: Row(
        children: [
          const Icon(Icons.swap_horiz_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(
            'Conmutador de entorno',
            style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.contrasena,
            obscureText: _oculta,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2D323A)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF59E0B)),
              ),
              suffixIcon: IconButton(
                icon: Icon(_oculta ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                onPressed: () => setState(() => _oculta = !_oculta),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.url,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'URL de la API en QA',
              hintText: 'http://192.168.0.136:3000',
              labelStyle: TextStyle(color: Colors.white54),
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2D323A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF59E0B)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BotonEntorno(
                  texto: 'QA · LAN',
                  seleccionado: _qa,
                  color: const Color(0xFFF59E0B),
                  onTap: () => setState(() => _qa = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BotonEntorno(
                  texto: 'PROD',
                  seleccionado: !_qa,
                  color: const Color(0xFF22C55E),
                  onTap: () => setState(() => _qa = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'En QA la app apunta a tu Mac en la red local.\n'
            '⚠️ En web por HTTP no hay push (el service worker exige HTTPS).',
            style: GoogleFonts.lato(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: GoogleFonts.lato(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              _ResultadoConmutador(
                contrasena: widget.contrasena.text,
                url: widget.url.text,
                qa: _qa,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE25822)),
          child: Text('Aplicar', style: GoogleFonts.lato(color: Colors.white)),
        ),
      ],
    );
  }
}

class _BotonEntorno extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;

  const _BotonEntorno({
    required this.texto,
    required this.seleccionado,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color : const Color(0xFF2D323A),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Text(
          texto,
          style: GoogleFonts.lato(
            color: seleccionado ? color : Colors.white38,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
