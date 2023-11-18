import 'dart:convert';

import 'package:consumindo_api/src/models/moeda_model.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';

class MoedaRepository {
  final client = Client();
  Future<List<MoedaModel>> getMoedas() async {
    final response = await client.get(
        Uri.parse('https://economia.awesomeapi.com.br/xml/available/uniq'));
    final xmlRaw = response.body;
    return parseMoeda(xmlRaw);
  }

  List<MoedaModel> parseMoeda(String xmlRaw) {
    final document = XmlDocument.parse(xmlRaw);
    final elements = document.children.first.children.whereType<XmlElement>();

    final moedas = <MoedaModel>[];

    for (var element in elements) {
      final moeda = MoedaModel(
        name: element.innerText,
        code: element.localName,
      );
      moedas.add(moeda);
    }
    return moedas;
  }

  Future<double> cotacao(MoedaModel moedaIn, MoedaModel moedaOut) async {
    final search = '${moedaIn.code}-${moedaOut.code}';
    final response = await client
        .get(Uri.parse('https://economia.awesomeapi.com.br/json/last/$search'));
    final xmlRaw = response.body;
    return parseCotacao(xmlRaw, search);
  }

  double parseCotacao(String jsonRaw, String search) {
    search = search.replaceFirst('-', '');
    final json = jsonDecode(jsonRaw);
    final model = json[search];
    final cotacao = model['bid'];
    return double.parse(cotacao);
  }
}
