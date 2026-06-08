import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/radio_player_controller.dart';

class RadioScreen extends StatefulWidget {
  final RadioPlayerController controller;

  const RadioScreen({super.key, required this.controller});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  late Future<List<Emisora>> _emisorasFuture;

  RadioPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _emisorasFuture = Emisora.getEmisoras();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _playEmisora(Emisora emisora) async {
    try {
      await _controller.play(emisora);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir ${emisora.nombre}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Emisora>>(
      future: _emisorasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final emisoras = snapshot.data ?? [];
        if (emisoras.isEmpty) {
          return const Center(
            child: Text('No hay emisoras disponibles'),
          );
        }

        return ListView.builder(
          itemCount: emisoras.length,
          itemBuilder: (context, index) {
            final emisora = emisoras[index];
            final isCurrentStation =
                _controller.currentEmisora?.id == emisora.id;

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  emisora.urlImagen,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.radio, size: 48),
                ),
              ),
              title: Text(emisora.nombre),
              trailing: Icon(
                isCurrentStation ? Icons.volume_up : Icons.play_arrow,
                color: isCurrentStation
                    ? const Color.fromRGBO(25, 52, 89, 1)
                    : null,
              ),
              onTap: () => _playEmisora(emisora),
            );
          },
        );
      },
    );
  }
}
