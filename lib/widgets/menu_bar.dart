import 'package:flutter/material.dart';

class Menu_Bar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAuthenticated;
  
  // Variable para recibir la foto
  final String? photoUrl;

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
    this.photoUrl,
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
      elevation: 6,
      // Botón de menú (siempre visible)
      leading: IconButton(
        icon: Icon(Icons.menu, color: iconColor),
        onPressed: onMenuPressed ?? () {
          Scaffold.of(context).openDrawer();
        },
      ), 
      title: _buildSearchBar(), 
      actions: _buildDynamicActions(context),
    );
  }

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

  List<Widget> _buildDynamicActions(BuildContext context) {
    if (isAuthenticated) {
      // Acciones para usuario autenticado
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

        Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 8.0),
          child: GestureDetector(
            onTap: onProfilePressed,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? NetworkImage(photoUrl!)
                  : null,
              child: (photoUrl == null || photoUrl!.isEmpty)
                  ? Icon(Icons.account_circle_outlined, color: iconColor, size: 28)
                  : null,
            ),
          ),
        ),
      ];
    } else {
      // Acciones para usuario NO autenticado
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            backgroundColor: const Color.fromARGB(255, 255, 153, 0),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          onPressed: onLoginPressed ?? () {
            Navigator.pushNamed(context, 'inicio_usuarios');
          },
          child: const Text('Login', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            backgroundColor: const Color(0xFF0F3B81),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            side: const BorderSide(color: Color(0xFF0F3B81), width: 1),
          ),
          onPressed: onSignUpPressed ?? () {
            Navigator.pushNamed(context, 'crear_cuenta');
          },
          child: const Text('Signup', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
      ];
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}