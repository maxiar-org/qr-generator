import 'package:flutter/material.dart';

import '../places/location.dart';
import '../places/places_client.dart';
import 'theme/app_theme.dart';

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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Encontrá tu negocio', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Usá tu ubicación y elegí el nombre y la dirección correctos. Si no aparece, buscá por nombre.',
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: _busy ? null : () => _search(true),
          icon: const Icon(Icons.my_location),
          label: const Text('Buscar cerca mío'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
            title: const Text('Buscar por nombre'),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre y localidad',
                ),
                onSubmitted: (_) {
                  if (!_busy) _search(false);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _busy ? null : () => _search(false),
                  child: const Text('Buscar negocio'),
                ),
              ),
            ],
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(semanticsLabel: 'Buscando negocios'),
        ],
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            key: const ValueKey('search-message'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(_message!, style: textTheme.bodyMedium),
              ),
            ],
          ),
        ],
        if (_places.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Resultados de Google Maps · Elegí tu negocio'),
          const SizedBox(height: AppSpacing.xs),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final place in _places)
                  ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.address),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.inkMuted,
                    ),
                    onTap: () => widget.onSelected(place),
                  ),
              ],
            ),
          ),
        ],
        const Divider(height: AppSpacing.xxl),
        Text('O ingresá el Place ID a mano', style: textTheme.headlineSmall),
      ],
    );
  }
}
