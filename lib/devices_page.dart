import 'package:app_hc05_arduino_testright/bluetooth_functions.dart';
import 'package:app_hc05_arduino_testright/main.dart';
import 'package:app_hc05_arduino_testright/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:app_hc05_arduino_testright/BluetoothDeviceListEntry.dart';

//BleFunctions func = BleFunctions();

bool isConnected = false;

class AvailableDevices extends StatefulWidget {
  final bool start;
  Function callBack;

  AvailableDevices({this.start = true, required this.callBack});

  @override
  _AvailableDevicesState createState() => _AvailableDevicesState();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _AvailableDevicesState extends State<AvailableDevices> {
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  bool isON = false;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() async {
    if (_bluetoothState != BluetoothState.STATE_ON) {
      await FlutterBluetoothSerial.instance.requestEnable();
      FlutterBluetoothSerial.instance.state.then((state) {
        _bluetoothState = state;
      });
    }

    if (_bluetoothState == BluetoothState.STATE_ON) {
      _streamSubscription =
          FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        setState(() {
          final existingIndex = results.indexWhere(
              (element) => element.device.address == r.device.address);
          if (existingIndex >= 0)
            results[existingIndex] = r;
          else
            results.add(r);
        });
      });

      _streamSubscription!.onDone(() {
        print(results);
        setState(() {
          isDiscovering = false;
        });
      });
    }

    // FlutterBluetoothSerial.instance
    //     .getBondedDevices()
    //     .then((List<BluetoothDevice> bondedDevices) {
    //   setState(() {
    //     devices = bondedDevices
    //         .map(
    //           (device) => _DeviceWithAvailability(
    //         device, _DeviceAvailability.maybe),
    //     )
    //         .toList();
    //   });
    // });
    //

  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> new_devices = [];
    List<BluetoothDeviceListEntry> bonded_devices = [];

    for (var i in results) {
      if(i.device.name != "HC-05")continue;

      if(!device_name.contains(i.device.address))device_name.add(i.device.address);

      if (i.device.bondState == BluetoothBondState.bonded) {

        bonded_devices.add(BluetoothDeviceListEntry(
          name: "TestRight FluoroUV ${device_name.indexOf(i.device.address)+1}",
            device: i.device,
          rssi: i.rssi,
          onTap: () async {
            try {
              isConnected = true;
              if (isConnected) {
                try {
                  mode = 5;
                  await func.sendMessage("r",(){});
                } on Exception catch (e) {
                  print(e);
                  const snackBar = SnackBar(
                    content: Text('Something Went Wrong'),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar);
                }
              }
              widget.callBack();
              Navigator.of(context).pop(i.device);
            } catch (ex) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        'Error occured while connecting'),
                    content: Text("${ex.toString()}"),
                    actions: <Widget>[
                      new TextButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          onLongPress: () async {
            try {
              bool? bonded = true;
              if (i.device.isBonded) {
                isConnected = false;
                print('Unbonding from ${i.device.address}...');
                bonded = await FlutterBluetoothSerial.instance
                    .removeDeviceBondWithAddress(i.device.address);
                bonded = !bonded!;
                print(
                    'Unbonding from ${i.device.address} has succed');
              }
              setState(() {
                results[results.indexOf(i)] =
                    BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: i.device.name ?? '',
                          address: i.device.address,
                          type: i.device.type,
                          bondState: bonded!
                              ? BluetoothBondState.bonded
                              : BluetoothBondState.none,
                        ),
                        rssi: i.rssi);
              });

              widget.callBack();
            } catch (ex) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        'Error occured while unbonding'),
                    content: Text("${ex.toString()}"),
                    actions: <Widget>[
                      new TextButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        );

      } else {
        new_devices.add(BluetoothDeviceListEntry(
          name: "TestRight FluoroUV ${device_name.indexOf(i.device.address)+1}",
          device: i.device,
          rssi: i.rssi,
          onTap: () async {
            try {
              isConnected = true;
              if (isConnected) {
                try {
                  mode = 5;
                  await func.sendMessage("r",(){});
                } on Exception catch (e) {
                  print(e);
                  const snackBar = SnackBar(
                    content: Text('Something Went Wrong'),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar);
                }
              }
              widget.callBack();
              Navigator.of(context).pop(i.device);
            } catch (ex) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        'Error occured while connecting'),
                    content: Text("${ex.toString()}"),
                    actions: <Widget>[
                      new TextButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          onLongPress: () async {
            try {
              bool? bonded = true;
              if (i.device.isBonded) {
                isConnected = false;
                print('Unbonding from ${i.device.address}...');
                bonded = await FlutterBluetoothSerial.instance
                    .removeDeviceBondWithAddress(i.device.address);
                bonded = !bonded!;
                print(
                    'Unbonding from ${i.device.address} has succed');
              }
              setState(() {
                results[results.indexOf(i)] =
                    BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: i.device.name ?? '',
                          address: i.device.address,
                          type: i.device.type,
                          bondState: bonded!
                              ? BluetoothBondState.bonded
                              : BluetoothBondState.none,
                        ),
                        rssi: i.rssi);
              });

              widget.callBack();
            } catch (ex) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        'Error occured while unbonding'),
                    content: Text("${ex.toString()}"),
                    actions: <Widget>[
                      new TextButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),);
      }
    }


    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text("FluoroSpec"),
        actions: [
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.white,),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    _restartDiscovery();
                  },
                  icon: Icon(Icons.wifi_protected_setup_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Paired Devices"),
                        ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5)
                    ),
                    width: MediaQuery.of(context).size.width,),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:(bonded_devices.isNotEmpty) ? bonded_devices : [Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("No paired device found",style: TextStyle(color: Colors.grey),),
                    )],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Available Devices"),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5)
                      ),
                      width: MediaQuery.of(context).size.width,),
                  ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:(new_devices.isNotEmpty) ?  new_devices : [Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("No new device found",style: TextStyle(color: Colors.grey),),)],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
