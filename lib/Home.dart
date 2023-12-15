import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  final TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dadosTarefa.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = {};
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _lerArquivo();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration:
                      const InputDecoration(labelText: "Digite sua tarefa"),
                  onChanged: (text) {},
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text("Salvar"),
                    onPressed: () {
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: _listaTarefas.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(_listaTarefas[index]["titulo"].toString()),
                value: _listaTarefas[index]["realizada"],
                onChanged: (valorChecado) {
                  setState(() {
                    _listaTarefas[index]["realizada"] = valorChecado;
                  });
                  _salvarArquivo();
                },
              );
              // return ListTile(
              //   title: Text(_listaTarefas[index]["titulo"].toString()),
              // );
            },
          ),
        )
      ]),
    );
  }
}
