import 'package:flutter/material.dart';

import '../estado/cartera.dart';
import '../ui/breakpoints.dart';
import 'clientes/clientes_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'prestamos/prestamos_screen.dart';

// Una entrada del menu. Se define una sola vez y sirve para la barra de abajo
// (celular) y para la barra lateral (PC), asi no se desincronizan.
class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoActivo);
  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}

const _destinos = [
  _Destino('Hoy', Icons.today_outlined, Icons.today),
  _Destino('Clientes', Icons.people_outline, Icons.people),
  _Destino('Préstamos', Icons.request_page_outlined, Icons.request_page),
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabActual = 0;

  @override
  void initState() {
    super.initState();
    // Se trae la cartera una sola vez al entrar; despues cada cambio la
    // refresca solo.
    cartera.cargarTodo();
  }

  final _pantallas = const [
    DashboardScreen(),
    ClientesScreen(),
    PrestamosScreen(),
  ];

  void _cambiarTab(int i) => setState(() => _tabActual = i);

  @override
  Widget build(BuildContext context) {
    // El ancho disponible decide la forma del menu; el resto de la app no cambia.
    return LayoutBuilder(
      builder: (context, restricciones) {
        final tamano = tamanoDe(restricciones.maxWidth);
        final contenido = IndexedStack(index: _tabActual, children: _pantallas);

        // Celular: menu abajo, al alcance del pulgar.
        if (tamano == Tamano.compacto) {
          return Scaffold(
            body: contenido,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tabActual,
              onDestinationSelected: _cambiarTab,
              destinations: _destinos.map((d) {
                return NavigationDestination(
                  icon: Icon(d.icono),
                  selectedIcon: Icon(d.iconoActivo),
                  label: d.etiqueta,
                );
              }).toList(),
            ),
          );
        }

        // Tablet y PC: menu al costado. En pantalla amplia se muestra con
        // texto; en la mediana solo los iconos, para no comerse el ancho.
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _tabActual,
                onDestinationSelected: _cambiarTab,
                extended: tamano == Tamano.amplio,
                labelType: tamano == Tamano.amplio
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: _destinos.map((d) {
                  return NavigationRailDestination(
                    icon: Icon(d.icono),
                    selectedIcon: Icon(d.iconoActivo),
                    label: Text(d.etiqueta),
                  );
                }).toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: contenido),
            ],
          ),
        );
      },
    );
  }
}
