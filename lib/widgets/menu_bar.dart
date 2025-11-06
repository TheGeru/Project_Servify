import 'package:flutter/material.dart';

class Menu_Bar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAuthenticated;
  
  // Callbacks
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onSignUpPressed;
  
  final int notificationCount;
  
  // Personalización
  final Color backgroundColor;
  final Color iconColor;
  final double toolbarHeight;

  const Menu_Bar({
    Key? key,
    this.isAuthenticated = false,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.notificationCount = 0,
    this.onLoginPressed,
    this.onSignUpPressed,
    this.backgroundColor = const Color(0xFFD7D7D7),
    this.iconColor = Colors.black,
    this.toolbarHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      toolbarHeight: toolbarHeight,
      elevation: 1,
      // Botón de menú (siempre visible)
      leading: IconButton(
        icon: Icon(Icons.menu, color: iconColor),
        onPressed: onMenuPressed ?? () {
          Scaffold.of(context).openDrawer();
        },
      ),
      
      // 
      // Usaremos un Row para asegurarnos de que el TextField se expanda.
      title: _buildSearchBar(),
      
      // 
      actions: _buildDynamicActions(context),
    );
  }

  // Ahora usa Expanded dentro de un Row para ocupar el espacio
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onTap: onSearchPressed,
          readOnly: onSearchPressed != null,
        ),
      ),
    );
  }

  // 🛑 NUEVO MÉTODO: Muestra un set de acciones basado en la autenticación
  List<Widget> _buildDynamicActions(BuildContext context) {
    if (isAuthenticated) {
      // Acciones para usuario autenticado (Notificaciones y Perfil)
      return [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: iconColor),
              onPressed: onNotificationPressed,
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.account_circle_outlined, color: iconColor),
          onPressed: onProfilePressed,
        ),
        const SizedBox(width: 8),
      ];
    } else {
      // Acciones para usuario NO autenticado (Botones de Login/Signup)
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            backgroundColor: Colors.orange,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4), // Reducir padding
          ),
          onPressed: onLoginPressed ?? () {
            Navigator.pushNamed(context, 'inicio_usuarios');
          },
          child: const Text('LOGIN', style: TextStyle(fontSize: 12)), // Reducir texto
        ),
        // Espacio reducido
        const SizedBox(width: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF0F3B81),
            backgroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4), // Reducir padding
            side: const BorderSide(color: Color(0xFF0F3B81), width: 1), // Borde
          ),
          onPressed: onSignUpPressed ?? () {
            Navigator.pushNamed(context, 'crear_cuenta');
          },
          child: const Text('SIGNUP', style: TextStyle(fontSize: 12)), // Reducir texto
        ),
        const SizedBox(width: 8),
      ];
    }
  }
  // ... (preferredSize se mantiene igual)

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}