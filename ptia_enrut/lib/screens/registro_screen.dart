import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmacion = TextEditingController();
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmacion.dispose();
    _codigo.dispose();
    super.dispose();
  }

  void _registrarse() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: crear la cuenta en el backend y validar el código de empresa.
    appState.registrar(email: _email.text, codigoEmpresa: _codigo.text);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconBoxButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Volver',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const AppLogo(),
                ],
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Registro',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Correo electrónico',
                            ),
                            validator: validarEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Contraseña',
                            ),
                            validator: validarContrasena,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmacion,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Confirmar contraseña',
                            ),
                            validator: (v) {
                              if ((v ?? '').isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              return v == _password.text
                                  ? null
                                  : 'Las contraseñas no coinciden';
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _codigo,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _registrarse(),
                            decoration: const InputDecoration(
                              hintText: 'Código de la empresa',
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Ingresa el código de tu empresa'
                                : null,
                          ),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            label: 'Registrarse',
                            onPressed: _registrarse,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
