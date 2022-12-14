
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huaji_bluetooth_print/huaji_bluetooth_print.dart';
import 'package:huaji_bluetooth_print/bluetooth_print_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HuajiBluetoothPrint bluetoothPrint = HuajiBluetoothPrint.instance;

  bool _connected = false;
  late BluetoothDevice _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool? isConnected=await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case HuajiBluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case HuajiBluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected!) {
      setState(() {
        _connected=true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('BluetoothPrint example app'),
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Text(tips),
                      ),
                    ],
                  ),
                  Divider(),
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: bluetoothPrint.scanResults,
                    initialData: [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data.map((d) => ListTile(
                        title: Text(d.name??''),
                        subtitle: Text(d.address),
                        onTap: () async {
                          setState(() {
                            _device = d;
                          });
                        },
                        trailing: _device!=null && _device.address == d.address?Icon(
                          Icons.check,
                          color: Colors.green,
                        ):null,
                      )).toList(),
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            OutlinedButton(
                              child: Text('connect'),
                              onPressed:  _connected?null:() async {
                                if(_device!=null && _device.address !=null){
                                  await bluetoothPrint.connect(_device);
                                }else{
                                  setState(() {
                                    tips = 'please select device';
                                  });
                                  print('please select device');
                                }
                              },
                            ),
                            SizedBox(width: 10.0),
                            OutlinedButton(
                              child: Text('disconnect'),
                              onPressed:  _connected?() async {
                                await bluetoothPrint.disconnect();
                              }:null,
                            ),
                          ],
                        ),
                        OutlinedButton(
                          child: Text('print receipt(esc)'),
                          onPressed:  _connected?() async {
                            Map<String, dynamic> config = Map();
                            List<LineText> list = [];
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'A Title', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent left', weight: 0, align: LineText.ALIGN_LEFT,linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent right', align: LineText.ALIGN_RIGHT,linefeed: 1));
                            list.add(LineText(linefeed: 1));

                            ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
                            List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                            String base64Image = base64Encode(imageBytes);
                            list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                            await bluetoothPrint.printReceipt(config, list);
                          }:null,
                        ),
                        OutlinedButton(
                          child: Text('print label(tsc)'),
                          onPressed:  _connected?() async {
                            Map<String, dynamic> config = Map();
                            config['width'] = 40; // ?????????????????????mm
                            config['height'] = 70; // ?????????????????????mm
                            config['gap'] = 2; // ?????????????????????mm

                            // x???y?????????????????????dpi???1mm=8dpi
                            List<LineText> list = [];
                            list.add(LineText(type: LineText.TYPE_TEXT, x:10, y:10, content: 'A Title'));
                            list.add(LineText(type: LineText.TYPE_TEXT, x:200, y:10, content: 'A Title'));
                            list.add(LineText(type: LineText.TYPE_TEXT, x:10, y:40, content: 'this is content'));
                            list.add(LineText(type: LineText.TYPE_BARCODE, x:10, y:70, content: 'qrcode i\n'));
                      

                            await bluetoothPrint.printLabel(config, list);
                          }:null,
                        ),
                        OutlinedButton(
                          child: Text('print selftest'),
                          onPressed:  _connected?() async {
                            await bluetoothPrint.printTest();
                          }:null,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}
