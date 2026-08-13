import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesagem_frangos/main.dart';

class Util {
  static Future<Widget?> showDialogAlert({
    String? titleConfirm,
    String? titleCancel,
    required BuildContext context,
    String? title,
    Function()? onConfirm,
    Function()? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          title: Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(child: Text(titleCancel ?? "Não"), onPressed: onCancel),
            TextButton(
              child: Text(titleConfirm ?? "Sim"),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }

  static List<DropdownMenuItem<String>> sexo() {
    return <String>['Macho', 'Fêmea', 'Misto'].map((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }

  static String? validateForm(String? value) {
    return value!.isEmpty ? 'Informe um valor!' : null;
  }

  static String formatDecimal(double value, {int decimals = 1}) {
    final pattern = switch (decimals) {
      0 => '#,##0',
      1 => '#,##0.0',
      2 => '#,##0.00',
      3 => '#,##0.000',
      _ => throw ArgumentError.value(decimals, 'decimals', 'Use 0, 1, 2 ou 3'),
    };
    return NumberFormat(pattern, 'pt_BR').format(value);
  }

  static String formatInteger(num value) =>
      NumberFormat.decimalPattern('pt_BR').format(value);

  static Future<List<String>> getListPesoPadrao(String? sexo) async {
    try {
      switch (sexo) {
        case 'Macho':
          return mPrefs.getStringList('padraoMacho') ?? [];
        case 'Fêmea':
          return mPrefs.getStringList('padraoFemea') ?? [];
        default:
          List<String> list = [];
          var padraoMacho = mPrefs.getStringList('padraoMacho') ?? [];
          var padraoFemea = mPrefs.getStringList('padraoFemea') ?? [];

          for (int i = 0; i < padraoFemea.length; i++) {
            // desconsiderar caso um dos padrões não tenha sido registrado (-10000) não vai deixar o resultado ser maior que 0
            int peso =
                int.tryParse(
                  padraoMacho.length > 0 ? padraoMacho[i] : -10000 as String,
                )! +
                int.tryParse(
                  padraoFemea.length > 0 ? padraoFemea[i] : -10000 as String,
                )!;
            double pesoAdd = peso > 0 ? (peso / 2) : 0.0;

            if (peso > 0) list.add(pesoAdd.round().toString());
          }

          return list;
      }
    } catch (e) {
      print('Erro $e');
      return [];
    }
  }
}
