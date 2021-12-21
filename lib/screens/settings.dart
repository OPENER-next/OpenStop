import 'package:flutter/material.dart';

enum userTheme {
  light,
  dark,
  contrast
}

enum difficulty {
  novice,
  amatuer,
  expert
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);


  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.palette, color: Colors.black54),
                      title: const Text('Design'),
                      //subtitle: const Text('Farbliche Darstellung'),
                      onTap: _selectDesign,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.line_weight, color: Colors.black54),
                      title: const Text('Schwierigkeitsgrad'),
                      //subtitle: const Text('Farbliche Darstellung'),
                      onTap: _selectDifficulty,
                    )
                  ],
                ),
              ),
            )
    );
  }

Future<void> _selectDesign() async {
    switch (await showDialog<userTheme>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Design auswählen'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, userTheme.light); },
                child: const Text('Hell'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, userTheme.dark);
                  },
                child: const Text('Dunkel'),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, userTheme.contrast); },
                child: const Text('Kontrast'),
              ),
            ],
          );
        }
    )) {
      case userTheme.light:
        _showToast(context, 'Helles Design gewählt');
        break;
      case userTheme.dark:
        _showToast(context, 'Dunkles Design gewählt');
        break;
      case userTheme.contrast:
        _showToast(context, 'Kontrastreiches Design gewählt');
        break;
      case null:
      // dialog dismissed
        break;
    }
  }

  Future<void> _selectDifficulty() async {
    switch (await showDialog<difficulty>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Design auswählen'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, difficulty.novice); },
                child: const Text('Einfach'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, difficulty.amatuer);
                },
                child: const Text('Standard'),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, difficulty.expert); },
                child: const Text('Schwer'),
              ),
            ],
          );
        }
    )) {
      case difficulty.novice:
        _showToast(context, 'Schwierigkeitsgrad: Einfach');
        break;
      case difficulty.amatuer:
        _showToast(context, 'Schwierigkeitsgrad: Standard');
        break;
      case difficulty.expert:
        _showToast(context, 'Schwierigkeitsgrad: Schwer');
        break;
      case null:
      // dialog dismissed
        break;
    }
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
