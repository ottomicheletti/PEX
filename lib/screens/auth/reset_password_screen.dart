import 'package:flutter/material.dart';
import 'package:agpop/main.dart';
import 'package:agpop/routes.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';
import 'package:agpop/widgets/custom_text_field.dart';
import 'package:agpop/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Ocorreu um erro ao enviar o e-mail';
        
        if (e.code == 'user-not-found') {
          errorMessage = 'Não há usuário registrado com este e-mail';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'E-mail inválido';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor
          )
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar e-mail: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        centerTitle: true
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildSuccessView() : _buildFormView()
          )
        )
      )
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_reset,
            size: 80,
            color: AppTheme.primaryColor
          ),
          const SizedBox(height: 24),
          
          Text(
            'Esqueceu sua senha?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 8),
          
          Text(
            'Digite seu e-mail para receber um link de redefinição de senha',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.subtitleTextColor
            ),
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 48),
          
          CustomTextField(
            controller: _emailController,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail
          ),
          const SizedBox(height: 24),
          
          CustomButton(
            text: 'Enviar Link',
            isLoading: _isLoading,
            onPressed: _resetPassword
          ),
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Voltar para o login',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppTheme.completedColor
        ),
        const SizedBox(height: 24),
        
        Text(
          'E-mail enviado!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center
        ),
        const SizedBox(height: 8),
        
        Text(
          'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.subtitleTextColor
          ),
          textAlign: TextAlign.center
        ),
        const SizedBox(height: 48),
        
        CustomButton(
          text: 'Voltar para o login',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        )
      ]
    );
  }
}
