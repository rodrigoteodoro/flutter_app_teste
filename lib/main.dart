import 'package:app_teste/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
//https://github.com/mix1009/desktop_window
import 'package:desktop_window/desktop_window.dart';

//import 'package:regras/regras.dart';

//typedef getPreco_func = ffi.Double Function();
//typedef GetPreco = double Function();
//var libraryPath = path.join(Directory.current.path, 'lib', 'extra', 'regras_plugin.dll');
//final dylib = ffi.DynamicLibrary.open(libraryPath);
//final GetPreco getPreco = dylib.lookup<ffi.NativeFunction<getPreco_func>>('getDesconto').asFunction();


typedef hello_world_func = ffi.Void Function();
typedef HelloWorld = void Function();
var libraryPath = path.join(Directory.current.path, 'lib', 'extra', 'hello.dll');
final dylib = ffi.DynamicLibrary.open(libraryPath);
final HelloWorld hello = dylib.lookup<ffi.NativeFunction<hello_world_func>>('hello_world').asFunction();
typedef getPreco_func = ffi.Double Function();
typedef GetPreco = double Function();
final GetPreco getPreco = dylib.lookup<ffi.NativeFunction<getPreco_func>>('get_preco').asFunction();

//https://flutter.dev/docs/development/platform-integration/c-interop
//https://github.com/mraleph/go_dart_ffi_example/blob/master/godart.dart

typedef TGUIConsulta = void Function(String query);
typedef getItemPreco_func = ffi.Double Function();
typedef GetItemPreco = double Function();
final GetItemPreco calcularItemPreco = dylib.lookup<ffi.NativeFunction<getItemPreco_func>>('calcular_item_preco').asFunction();
//final getItemPreco_func nativeAdd = dylib.lookup<ffi.NativeFunction<getItemPreco_func>>("calcular_item_preco").asFunction();


const simplePeriodicTask = "simplePeriodicTask";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodicTask:
        log("$simplePeriodicTask was executed");
        break;
   }
      return Future.value(true);
});
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Teste',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'App Teste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  double _valor = 0.0;
  String _texto = "Path";
  String _DBPath = "DB";
  String _retBanco = "retBanco";
  String _restValor = "retorno";
  late DatabaseHelper handler;

  void initState() {
    super.initState();
    this.handler = DatabaseHelper();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        log("Database inicializada");
      });
    });

  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _valor++;
    });
  }

  Future<List<Map>> gui_consulta(String query) async {
    log('data: $libraryPath');
    List<Map> retorno = [{}];
    retorno = await this.handler.guiConsulta(query);
    return retorno;
  }

  Future<String> teste_query() async {
    List<Map> retorno = await gui_consulta('SELECT produto, pf0 as preco FROM produto WHERE id = 22;');
    String retBanco = "";
    //retorno.forEach((row) => retBanco + row["produto"]+ " " + row["preco"].toString() + "\n");
    //retorno.forEach((row) => log("DB: ${row.length}"));
    //retorno.forEach((row) { log(row["produto"]);});
    retorno.forEach((row) {
      retBanco += row["produto"]+ " " + row["preco"].toString();
    });
    return retBanco;
  }

  Future<double> teste_preco() async {
    double preco = -1.0;
    //preco = await getPreco();
    Map pedido = {'codigo': 22};
    preco = await calcularItemPreco();
    return preco;

  }

  Future<void> _getPreco() async {
    double preco = -1.0;
    //double preco = await Regras.getPreco ?? 0.0;
    //print(libraryPath);
    String dbPath = await this.handler.getPath();
    log('data: $libraryPath');
    //hello();
    String retBanco = await teste_query();
    preco = await teste_preco();
    setState(() {
      _valor = preco;
      _texto = libraryPath;
      _DBPath= dbPath;
      _retBanco = retBanco;
    });
  }

  /**
   * https://flutter.dev/docs/cookbook/networking/fetch-data
   */
  Future<void> _getRest() async {
    log('_getRest');
    http.Response response = await http.get(
        Uri.parse('http://127.0.0.1:5000/preco'),
        headers: {"Accept": "application/json"}
    );
    String rret = "Status: " + response.statusCode.toString() + " Body: " + response.body.toString();
    log(rret);
    setState(() {
      _restValor = rret;
    });
  }

  Future<void> _initBackgroundTask() async {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  Future<void> _startBackgroundTask() async {
    log('_startBackgroundTask');
    Workmanager().registerPeriodicTask(
      "2",
      simplePeriodicTask,
      initialDelay: Duration(seconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_DBPath',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_texto',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_valor',
              style: Theme.of(context).textTheme.headline4,
            ),Text(
              '$_retBanco',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: _getRest,
                    child: const Text('Rest'),
                  ),
                ],
              ),
            ), Text(
              '$_restValor',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: _initBackgroundTask,
              child: const Text('Start the Flutter background service'),
            ),TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: _startBackgroundTask,
              child: const Text('Register Periodic Task'),
            ),TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Workmanager().cancelAll();
              },
              child: const Text('Cancel Periodic Task'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPreco,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
