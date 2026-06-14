import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/usuario_service.dart';
import '../services/admin_service.dart';
import '../services/auth_manager.dart';

class AdminScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminScreen({super.key, this.onLogout});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _nombreArchivo;
  List<int>? _bytesArchivo;
  bool _subiendo = false;
  String? _mensajeCsv;
  bool _mensajeCsvError = false;
  String _tipoCsv = 'infopasos';

  List<Map<String, dynamic>> _dias = [];
  bool _cargandoDias = false;
  String? _mensajeDias;
  bool _mensajeDiasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Future<void> _seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (resultado != null && resultado.files.single.bytes != null) {
      setState(() {
        _nombreArchivo = resultado.files.single.name;
        _bytesArchivo = resultado.files.single.bytes!.toList();
        _mensajeCsv = null;
      });
    }
  }

  Future<void> _subirCsv() async {
    if (_bytesArchivo == null || _nombreArchivo == null) return;

    setState(() {
      _subiendo = true;
      _mensajeCsv = null;
    });

    try {
      final Map<String, dynamic> respuesta;
      if (_tipoCsv == 'hermandades') {
        respuesta = await AdminService.uploadHermandadesCsv(
          _bytesArchivo!,
          _nombreArchivo!,
        );
      } else {
        respuesta = await AdminService.uploadInfopasosCsv(
          _bytesArchivo!,
          _nombreArchivo!,
        );
      }

      if (mounted) {
        setState(() {
          _subiendo = false;
          _mensajeCsv = respuesta['mensaje'] ?? 'Carga completada';
          _mensajeCsvError = false;
          _nombreArchivo = null;
          _bytesArchivo = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _subiendo = false;
          _mensajeCsv = e.toString().replaceFirst('Exception: ', '');
          _mensajeCsvError = true;
        });
      }
    }
  }


  Future<void> _cargarDias() async {
    setState(() {
      _cargandoDias = true;
      _mensajeDias = null;
    });

    try {
      final dias = await AdminService.getDias();
      if (mounted) {
        setState(() {
          _dias = dias;
          _cargandoDias = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDias = false;
          _mensajeDias = e.toString().replaceFirst('Exception: ', '');
          _mensajeDiasError = true;
        });
      }
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final primerDia = _dias.isNotEmpty ? _dias.first : null;
    var fechaInicial = primerDia != null
        ? (DateTime.tryParse(primerDia['fecha'] ?? '') ?? DateTime.now())
        : DateTime.now();

    //initialDate debe caer en viernes
    if (fechaInicial.weekday != DateTime.friday) {
      final diasHastaViernes = (DateTime.friday - fechaInicial.weekday + 7) % 7;
      fechaInicial = fechaInicial.add(Duration(days: diasHastaViernes == 0 ? 7 : diasHastaViernes));
    }

    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona la fecha del Viernes de Dolores',
      selectableDayPredicate: (DateTime day) => day.weekday == DateTime.friday,
    );

    if (nuevaFecha == null) return;

    setState(() {
      _mensajeDias = null;
      _cargandoDias = true;
    });

    try {
      final fechaStr = nuevaFecha.toIso8601String();
      final respuesta = await AdminService.actualizarFechasDesdeInicio(
        fechaStr,
      );

      if (mounted) {
        setState(() {
          _mensajeDias = respuesta['mensaje'] ?? 'Fechas actualizadas';
          _mensajeDiasError = false;
        });
        _cargarDias();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDias = false;
          _mensajeDias = e.toString().replaceFirst('Exception: ', '');
          _mensajeDiasError = true;
        });
      }
    }
  }

  void _cerrarSesion() {
    UsuarioService.logout();
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.pop(context, 'logout');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
        title: const Text(
          'Administración',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: 'Cargar CSVs'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Días'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCsvTab(),
          _buildDiasTab(),
        ],
      ),
    );
  }


  Widget _buildCsvTab() {
    final opciones = {
      'infopasos': 'InfoPasos',
      'hermandades': 'Hermandades',
    };
    final descripciones = {
      'infopasos': 'Formato: idHermandad;tipoPaso;hora;localizacion;difHora;esCarreraOficial',
      'hermandades': 'Formato: id;nombre;idDia',
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cargar CSV',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _tipoCsv,
            decoration: InputDecoration(
              labelText: 'Tipo de datos',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: opciones.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: _subiendo
                ? null
                : (value) {
                    setState(() {
                      _tipoCsv = value!;
                      _nombreArchivo = null;
                      _bytesArchivo = null;
                      _mensajeCsv = null;
                    });
                  },
          ),
          const SizedBox(height: 8),
          Text(
            descripciones[_tipoCsv] ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _subiendo ? null : _seleccionarArchivo,
              icon: const Icon(Icons.folder_open),
              label: Text(
                _nombreArchivo ?? 'Seleccionar archivo CSV',
                style: const TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(25, 52, 89, 1),
                side: const BorderSide(
                  color: Color.fromRGBO(25, 52, 89, 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_bytesArchivo != null && !_subiendo)
                  ? _subirCsv
                  : null,
              icon: _subiendo
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload, color: Colors.white),
              label: Text(
                _subiendo ? 'Subiendo...' : 'Subir CSV',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          if (_mensajeCsv != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _mensajeCsvError
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                border: Border.all(
                  color: _mensajeCsvError ? Colors.red : Colors.green,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _mensajeCsv!,
                style: TextStyle(
                  color: _mensajeCsvError
                      ? Colors.red
                      : Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildDiasTab() {
    if (_cargandoDias) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Fechas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona la fecha del Viernes de Dolores y el resto de días se calcularán automáticamente.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _seleccionarFechaInicio,
              icon: const Icon(Icons.edit_calendar, color: Colors.white),
              label: const Text(
                'Seleccionar fecha de inicio',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          if (_mensajeDias != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _mensajeDiasError
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                border: Border.all(
                  color: _mensajeDiasError ? Colors.red : Colors.green,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _mensajeDias!,
                style: TextStyle(
                  color: _mensajeDiasError
                      ? Colors.red
                      : Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 16),

          Expanded(
            child: _dias.isEmpty
                ? const Center(
                    child: Text(
                      'No hay días configurados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _dias.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final dia = _dias[index];
                      return _buildDiaCard(dia);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaCard(Map<String, dynamic> dia) {
    final fechaStr = dia['fecha'] ?? '';
    final fecha = DateTime.tryParse(fechaStr);
    final fechaFormateada = fecha != null
        ? '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year}'
        : 'Sin fecha';

    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(
          Icons.calendar_month,
          color: Color.fromRGBO(25, 52, 89, 1),
        ),
        title: Text(
          dia['nombre'] ?? 'Día',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Fecha: $fechaFormateada'),
      ),
    );
  }
}
