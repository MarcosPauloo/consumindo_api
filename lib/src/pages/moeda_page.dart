import 'package:consumindo_api/src/stores/moeda_store.dart';
import 'package:flutter/material.dart';

import '../models/moeda_model.dart';

class MoedaPage extends StatefulWidget {
  const MoedaPage({super.key});

  @override
  State<MoedaPage> createState() => _MoedaPageState();
}

class _MoedaPageState extends State<MoedaPage> {
  final store = MoedaStore();
  var input = '';
  @override
  void initState() {
    super.initState();
    store.addListener(_listener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // me permite executar uma função após o build
      store.getMoedas();
    });
  }

  _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    store.removeListener(_listener);
    super.dispose();
  }

  Future<MoedaModel?> _selectMoeda(MoedaModel model) {
    return showModalBottomSheet<MoedaModel>(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return ListView.builder(
              itemCount: store.value.moedas.length,
              itemBuilder: (context, index) {
                final innerMoeda = store.value.moedas[index];
                return ListTile(
                  title: Text(innerMoeda.name),
                  selected: innerMoeda == model,
                  onTap: () {
                    Navigator.of(context).pop(innerMoeda);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = store.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Moeda',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => input = value,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final moeda = await _selectMoeda(state.moedaIn);
                    if (moeda != null) {
                      store.selecionarMoedaIn(moeda);
                    }
                  },
                  child: Text(state.moedaIn.code),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: store.switchMoedas,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final moeda = await _selectMoeda(state.moedaOut);
                    if (moeda != null) {
                      store.selecionarMoedaOut(moeda);
                    }
                  },
                  child: Text(state.moedaOut.code),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => store.converter(input),
              child: Text('Resultado: ${state.result}'),
            ),
          ],
        ),
      ),
    );
  }
}
