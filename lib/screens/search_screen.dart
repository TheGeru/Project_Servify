import 'package:flutter/material.dart';
import 'package:project_servify/widgets/card_container.dart';

class SearchScreen extends StatefulWidget {
  final List<Map<String, String>> allServices;
  final Function(BuildContext, String) navigateToServiceDetail;

  const SearchScreen({
    super.key,
    required this.allServices,
    required this.navigateToServiceDetail,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = '';
  List<Map<String, String>> _searchResults = [];

  void _searchServices(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchText = query;
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final results = widget.allServices.where((service) {
      return service['titulo']!.toLowerCase().contains(lowerCaseQuery) ||
          service['descripcion']!.toLowerCase().contains(lowerCaseQuery) ||
          service['categoria']!.toLowerCase().contains(lowerCaseQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _searchText = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar servicio...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
          ),
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
          onChanged: _searchServices,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: _searchResults.isEmpty && _searchText.isNotEmpty
          ? const Center(
              child: Text(
                'No se encontraron servicios.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final service = _searchResults[index];
                return CardContainer(
                  titulo: service['titulo']!,
                  categoria: service['categoria']!,
                  descripcion: service['descripcion']!,
                  onTap: () {
                    widget.navigateToServiceDetail(context, service['titulo']!);
                  },
                );
              },
            ),
    );
  }
}
