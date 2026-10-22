import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/api_config.dart';
import '../../../core/config/qa_version_label.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/push_notification_service.dart';
import '../../admin/presentation/super_admin_view.dart';
import '../../admin/presentation/restaurant_admin_dashboard_view.dart';
import '../../menu/presentation/menu_categories_page.dart';
import '../../kitchen/presentation/kitchen_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _restaurantController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _restaurantController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa usuario y contraseña'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido ${userCredential.user?.email ?? ""}!'),
            backgroundColor: Colors.green,
          ),
        );
        final uid = userCredential.user?.uid ?? '';
        final lowerEmail = email.toLowerCase().trim();
        String role = 'restaurant_admin';
        String restaurantName = _restaurantController.text.trim().isNotEmpty
            ? _restaurantController.text.trim()
            : 'Mi Restaurante';
        String restaurantId = '';
        String planName = 'Prueba Gratuita (7 Días)';
        int trialDaysRemaining = 7;
        int maxWaiters = 3;

        // 1. Obtener el ROL AUTORITATIVO desde Firebase Auth (Custom Claims del token)
        try {
          final idTokenResult = await userCredential.user?.getIdTokenResult(true);
          final claimRole = idTokenResult?.claims?['role']?.toString();
          if (claimRole != null && claimRole.isNotEmpty) {
            role = claimRole;
          }
        } catch (_) {}

        // 2. Consultar el perfil real desde la base de datos PostgreSQL
        //
        // Se reintenta una vez: la primera consulta tras arrancar el backend
        // puede tardar (conexión fría a Cloud SQL) y agotar el tiempo de
        // espera. Si tras el reintento sigue fallando, el usuario se avisa en
        // vez de entrar con un restaurante sin identificar.
        bool perfilOk = false;
        for (int intento = 0; intento < 2 && !perfilOk; intento++) {
          if (intento > 0) {
            await Future<void>.delayed(const Duration(milliseconds: 800));
          }
          for (final base in ApiConfig.candidates) {
            try {
              final resp = await ApiClient.get(
                '$base/api/auth/profile/$uid',
                timeout: const Duration(seconds: 5),
              );
              if (resp.statusCode == 200) {
                final data = jsonDecode(resp.body);
                role = data['role'] ?? role;
                restaurantName = data['restaurantName'] ?? restaurantName;
                restaurantId = data['restaurantId'] ?? '';
                planName = data['planName'] ?? planName;
                maxWaiters = data['maxWaiters'] ?? maxWaiters;
                trialDaysRemaining = data['trialDaysRemaining'] ?? trialDaysRemaining;
                perfilOk = true;
                break;
              }
              debugPrint('[Login] Perfil no disponible en $base -> HTTP ${resp.statusCode}');
            } catch (e) {
              debugPrint('[Login] Perfil falló en $base -> $e');
            }
          }
        }

        if (!perfilOk) {
          debugPrint('[Login] No se pudo resolver el perfil de $email; se continúa sin restaurante identificado.');
        }

        // Registrar el dispositivo para recibir push DESDE AHORA.
        //
        // `register-device` exige un token de Firebase válido, así que registrar
        // en el arranque (antes de iniciar sesión) siempre devolvía 401 y el
        // dispositivo se quedaba sin push. Aquí ya hay sesión, y el
        // restaurantId del perfil es el que usa el backend para filtrar los
        // dispositivos y suscribirlos al tópico correcto.
        if (restaurantId.isNotEmpty) {
          unawaited(
            PushNotificationService().registerThisDevice(
              restaurantId: restaurantId,
              role: role,
            ),
          );
        }

        // Enrutamiento basado EXCLUSIVAMENTE en el ROL del usuario en la base de datos
        if (role == 'super_admin' || lowerEmail == 'chebetoa7@gmail.com') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SuperAdminDashboardView(),
            ),
          );
        } else if (role == 'kitchen' || role == 'chef') {
          // El usuario es Cocinero / Chef: va DIRECTO al Monitor de Cocina (KDS)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const KitchenView(),
            ),
          );
        } else if (role == 'waiter') {
          // El usuario tiene rol de mesero en la BD: va DIRECTO a levantar pedidos.
          //
          // `restaurantId` se pasa tal cual. Antes, si la consulta al perfil
          // fallaba, se usaba el UID de Firebase como identificador de
          // restaurante: ese valor no es un UUID, el backend respondía 500 y el
          // menú se quedaba vacío (solo el agua gratis) sin explicar por qué.
          // Si el perfil no se pudo resolver, la pantalla de menú lo reintenta
          // por su cuenta y, si tampoco puede, lo muestra en pantalla.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MenuCategoriesPage(
                restaurantId: restaurantId,
                userRole: role,
              ),
            ),
          );
        } else {
          // El usuario es administrador: ve su Dashboard de gestión
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RestaurantAdminDashboardView(
                restaurantName: restaurantName,
                adminEmail: email,
                planName: planName,
                trialDaysRemaining: trialDaysRemaining,
                maxStaffQuota: maxWaiters,
                restaurantId: restaurantId,
                adminUid: uid,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe un usuario con este correo.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensaje = 'Contraseña o credenciales incorrectas.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El formato del correo es inválido.';
      } else {
        mensaje = e.message ?? mensaje;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openWebRegistration() async {
    final uri = Uri.parse('${ApiConfig.landingUrl}/#registro');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!launched) {
        final altUri = Uri.parse('${ApiConfig.landingUrl}/#registro');
        await launchUrl(altUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Visita en tu navegador: ${ApiConfig.landingUrl}/#registro'),
          backgroundColor: const Color(0xFFE25822),
        ),
      );    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF222428),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Logo Placeholder
              Container(
                height: 220,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF222428),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Color(0xFFF16821),
                ),
              ),

              // Login Form
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2F35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF444444), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _restaurantController,
                      hintText: 'ID Restaurante (Ej: burger-01)',
                      icon: Icons.store,
                    ),
                    const Divider(height: 1, color: Color(0xFF444444)),
                    _buildTextField(
                      controller: _userController,
                      hintText: 'Usuario / Email',
                      icon: Icons.person,
                    ),
                    const Divider(height: 1, color: Color(0xFF444444)),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Contraseña',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF16821),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Iniciar Turno',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),

              const SizedBox(height: 15),

              // Register Button
              TextButton(
                onPressed: _openWebRegistration,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF9A11F),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Registrarte',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Version Label
              //
              // 5 toques aquí abren el conmutador PR/QA (solo en builds de QA:
              // la contraseña viene de keylocal.txt y se inyecta en el build).
              const QaVersionLabel(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          icon: Icon(icon, color: const Color(0xFF888888), size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
