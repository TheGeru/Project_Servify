import 'package:flutter/material.dart';

class Menu_Bar extends StatelessWidget implements PreferredSizeWidget {
  // Parámetro principal para determinar el estado
  final bool isAuthenticated;
  
  // Callbacks comunes
  final VoidCallback? onMenuPressed;
  
  // Callbacks para usuario autenticado
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final int notificationCount;
  
  // Callbacks para usuario NO autenticado
  final VoidCallback? onLoginPressed;
  final VoidCallback? onSignUpPressed;
  
  // Personalización
  final Color backgroundColor;
  final Color iconColor;
  final double toolbarHeight;

  const Menu_Bar({
    Key? key,
    this.isAuthenticated = false,
    this.onMenuPressed,
    // Autenticado
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.notificationCount = 0,
    // No autenticado
    this.onLoginPressed,
    this.onSignUpPressed,
    // Personalización
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
      leading: IconButton(
        icon: Icon(Icons.menu, color: iconColor),
        onPressed: onMenuPressed ?? () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: _buildSearchBar(),
      actions: isAuthenticated 
          ? _buildAuthenticatedActions() 
          : _buildUnauthenticatedActions(context),
    );
  }

  // Barra de búsqueda para usuarios autenticados
  Widget _buildSearchBar() {
    return Container(
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
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onTap: onSearchPressed,
        readOnly: onSearchPressed != null,
      ),
    );
  }

  // Acciones para usuarios autenticados
  List<Widget> _buildAuthenticatedActions() {
    return [
      Stack(
        children: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: iconColor),
            onPressed: onNotificationPressed ?? () {
              print('Notificaciones presionadas');
            },
          ),
          if (notificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: TextStyle(
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
        onPressed: onProfilePressed ?? () {
          print('Perfil presionado');
        },
      ),
      SizedBox(width: 8),
    ];
  }

  // Acciones para usuarios NO autenticados
  List<Widget> _buildUnauthenticatedActions(BuildContext context) {
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          elevation: 0,
        ),
        onPressed: onLoginPressed ?? () {
          Navigator.pushNamed(context, 'inicio_usuarios');
        },
        child: const Text('INICIAR SESIÓN'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF6B42DE),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: onSignUpPressed ?? () {
          Navigator.pushNamed(context, 'crear_cuenta');
        },
        child: const Text('CREAR CUENTA'),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
