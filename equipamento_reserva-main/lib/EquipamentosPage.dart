import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EquipamentosPage extends StatefulWidget {
  @override
  _EquipamentosPageState createState() => _EquipamentosPageState();
}

class _EquipamentosPageState extends State<EquipamentosPage> {
  List<dynamic> equipamentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEquipamentos();
  }

  Future<void> fetchEquipamentos() async {
    try {
      final response = await http.get(
          Uri.parse('https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos'));

      if (response.statusCode == 200) {
        setState(() {
          equipamentos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar equipamentos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  // Função para reservar o equipamento
  Future<void> reservarEquipamento(int equipamentoId) async {
    try {
      final response = await http.post(
        Uri.parse('https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos/$equipamentoId/reservar'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = equipamentos.indexWhere((e) => e['id'] == equipamentoId);
          if (index != -1) {
            equipamentos[index]['disponivel'] = false;
            equipamentos[index]['dataRetirada'] = DateTime.now().toIso8601String(); // Armazenar data e hora da retirada
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Equipamento reservado com sucesso!'),
        ));
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Erro ao reservar equipamento')),
        );
      } else {
        throw Exception('Falha ao reservar equipamento');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao reservar equipamento'),
      ));
    }
  }

  // Função para liberar o equipamento reservado
  Future<void> liberarEquipamento(int equipamentoId) async {
    try {
      final response = await http.post(
        Uri.parse('https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos/$equipamentoId/liberar'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = equipamentos.indexWhere((e) => e['id'] == equipamentoId);
          if (index != -1) {
            equipamentos[index]['disponivel'] = true;
            equipamentos[index]['dataRetirada'] = null; // Remove data de retirada quando equipamento for liberado
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reserva liberada com sucesso!'),
        ));
      } else {
        throw Exception('Falha ao liberar reserva');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao liberar reserva'),
      ));
    }
  }

  // Função para formatar a data de retirada
  String formatarData(String dataISO) {
    DateTime data = DateTime.parse(dataISO);
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipamentos'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu de Navegação'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Consultar Equipamentos'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/consulta');
              },
            ),
            ListTile(
              title: Text('Cadastrar Equipamento'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/cadastro');
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: equipamentos.length,
              itemBuilder: (context, index) {
                final equipamento = equipamentos[index];
                return ListTile(
                  title: Text(equipamento['nome']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(equipamento['disponivel'] ? 'Disponível' : 'Reservado'),
                      if (equipamento['dataRetirada'] != null)
                        Text('Retirado em: ${formatarData(equipamento['dataRetirada'])}'),
                    ],
                  ),
                  trailing: equipamento['disponivel']
                      ? ElevatedButton(
                          onPressed: () {
                            reservarEquipamento(equipamento['id']);
                          },
                          child: Text('Reservar'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            liberarEquipamento(equipamento['id']);
                          },
                          child: Text('Liberar'),
                        ),
                );
              },
            ),
    );
  }
}
