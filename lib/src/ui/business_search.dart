import 'package:flutter/material.dart';

import '../places/location.dart';
import '../places/places_client.dart';

class BusinessSearch extends StatefulWidget {
  const BusinessSearch({
    super.key,
    required this.onSelected,
    this.client,
    this.locate,
  });
  final ValueChanged<BusinessPlace> onSelected;
  final PlacesClient? client;
  final Future<BusinessLocation> Function()? locate;
  @override
  State<BusinessSearch> createState() => _BusinessSearchState();
}

class _BusinessSearchState extends State<BusinessSearch> {
  late final _client = widget.client ?? PlacesClient();
  final _name = TextEditingController();
  bool _busy = false;
  String? _message;
  List<BusinessPlace> _places = [];

  Future<void> _search(bool nearby) async {
    setState(() {
      _busy = true;
      _message = null;
      _places = [];
    });
    try {
      BusinessLocation? location;
      if (nearby) {
        try {
          location = await (widget.locate ?? locateBusiness)();
        } catch (_) {
          throw const PlacesException(
            'No pudimos obtener tu ubicación. Habilitá el permiso o buscá por nombre y localidad.',
          );
        }
      }
      final places = nearby
          ? await _client.nearby(location!)
          : await _client.search(_name.text);
      if (!mounted) return;
      setState(() {
        _places = places;
        _message = places.isEmpty
            ? 'No encontramos negocios. Probá por nombre y localidad o pegá el Place ID.'
            : null;
      });
    } on PlacesException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    if (widget.client == null) _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Encontrá tu negocio',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const Text(
        'Usá tu ubicación y elegí el nombre y la dirección correctos. Si no aparece, buscá por nombre.',
      ),
      FilledButton.icon(
        onPressed: _busy ? null : () => _search(true),
        icon: const Icon(Icons.my_location),
        label: const Text('Buscar cerca mío'),
      ),
      ExpansionTile(
        title: const Text('Buscar por nombre'),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre y localidad',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              if (!_busy) _search(false);
            },
          ),
          TextButton(
            onPressed: _busy ? null : () => _search(false),
            child: const Text('Buscar negocio'),
          ),
        ],
      ),
      if (_busy)
        const LinearProgressIndicator(semanticsLabel: 'Buscando negocios'),
      if (_message != null)
        Text(_message!, key: const ValueKey('search-message')),
      if (_places.isNotEmpty) ...[
        const Text('Resultados de Google Maps · Elegí tu negocio'),
        for (final place in _places)
          ListTile(
            title: Text(place.name),
            subtitle: Text(place.address),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onSelected(place),
          ),
      ],
      const Divider(height: 32),
      const Text('O ingresá el Place ID manualmente'),
    ],
  );
}
