
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de estudiantes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaEstudiantes(),
    );
  }
}

class PantallaEstudiantes extends StatefulWidget {
  const PantallaEstudiantes({super.key});

  @override
  State<PantallaEstudiantes> createState() =>
      _PantallaEstudiantesState();
}

class _PantallaEstudiantesState extends State<PantallaEstudiantes> {
  final String apiUrl =
      'http://localhost/conexion/estudiantes.php';

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final programaController = TextEditingController();
  final semestreController = TextEditingController();

  List<Map<String, dynamic>> estudiantes = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    consultarEstudiantes();
  }

  Future<void> consultarEstudiantes() async {
    setState(() => cargando = true);

    try {
      final respuesta = await http.get(Uri.parse(apiUrl));

      if (respuesta.statusCode == 200) {
        final List datos = jsonDecode(respuesta.body);

        setState(() {
          estudiantes = datos
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      } else {
        mostrarMensaje('Error al consultar estudiantes');
      }
    } catch (e) {
      mostrarMensaje('No se pudo conectar con la API PHP');
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> agregarEstudiante() async {
    if (nombreController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        programaController.text.trim().isEmpty ||
        semestreController.text.trim().isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    try {
      final respuesta = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombreController.text.trim(),
          'correo': correoController.text.trim(),
          'programa': programaController.text.trim(),
          'semestre': semestreController.text.trim(),
        }),
      );

      final resultado = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        nombreController.clear();
        correoController.clear();
        programaController.clear();
        semestreController.clear();

        await consultarEstudiantes();
        mostrarMensaje(resultado['mensaje'] ?? 'Estudiante registrado');
      } else {
        mostrarMensaje(resultado['error'] ?? 'No se pudo registrar');
      }
    } catch (e) {
      mostrarMensaje('Error al conectar con PHP');
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    programaController.dispose();
    semestreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de estudiantes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: consultarEstudiantes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del estudiante',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: programaController,
              decoration: const InputDecoration(
                labelText: 'Programa académico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: semestreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Semestre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: cargando ? null : agregarEstudiante,
              child: const Text('Agregar estudiante'),
            ),
            const Divider(),
            const Text(
              'Lista de estudiantes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (cargando) const LinearProgressIndicator(),
            Expanded(
              child: estudiantes.isEmpty && !cargando
                  ? const Center(
                      child: Text('No hay estudiantes registrados'),
                    )
                  : ListView.builder(
                      itemCount: estudiantes.length,
                      itemBuilder: (context, index) {
                        final estudiante = estudiantes[index];

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              estudiante['nombre']?.toString() ?? '',
                            ),
                            subtitle: Text(
                              '${estudiante['correo'] ?? ''}\n'
                              '${estudiante['programa'] ?? ''} - '
                              'Semestre ${estudiante['semestre'] ?? ''}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
