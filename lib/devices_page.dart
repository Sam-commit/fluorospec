import 'package:app_hc05_arduino_testright/bluetooth_functions.dart';
import 'package:app_hc05_arduino_testright/main.dart';
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
    List<BluetoothDiscoveryResult> new_devices = [];
    List<BluetoothDiscoveryResult> bonded_devices = [];

    for (var i in results) {
      if (i.device.bondState == BluetoothBondState.bonded) {
        // Iterator it = devices.iterator;
        // while (it.moveNext()) {
        //   var _device = it.current;
        //   if (_device.device == i.device) {
        //     _device.availability = _DeviceAvailability.yes;
        //     _device.rssi = i.rssi;
        //   }
        // }
        bonded_devices.add(i);
      } else {
        new_devices.add(i);
      }
    }

    // List<BluetoothDeviceListEntry> list = devices
    //     .map((_device) => BluetoothDeviceListEntry(
    //   device: _device.device,
    //   rssi: _device.rssi,
    //   enabled: _device.availability == _DeviceAvailability.yes,
    //   onTap: () {
    //     Navigator.of(context).pop(_device.device);
    //   },
    // ))
    //     .toList();

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
              Container(
                height: MediaQuery.of(context).size.height/2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Paired Devices"),
                        ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5)
                    ),
                    width: MediaQuery.of(context).size.width,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: bonded_devices.length,
                        itemBuilder: (BuildContext context, index) {
                          BluetoothDiscoveryResult result = bonded_devices[index];
                          final device = result.device;
                          final address = device.address;
                          return BluetoothDeviceListEntry(
                            device: device,
                            rssi: result.rssi,
                            // onTap: () {
                            //   Navigator.of(context).pop(result.device);
                            // },
                            onTap: () async {
                              try {
                                isConnected = true;
                                if (isConnected) {
                                  try {
                                    mode = 5;
                                    await func.sendMessage("r");
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
                                Navigator.of(context).pop(device);
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
                                if (device.isBonded) {
                                  isConnected = false;
                                  print('Unbonding from ${device.address}...');
                                  bonded = await FlutterBluetoothSerial.instance
                                      .removeDeviceBondWithAddress(address);
                                  bonded = !bonded!;
                                  print(
                                      'Unbonding from ${device.address} has succed');
                                }
                                setState(() {
                                  bonded_devices[bonded_devices.indexOf(result)] =
                                      BluetoothDiscoveryResult(
                                          device: BluetoothDevice(
                                            name: device.name ?? '',
                                            address: address,
                                            type: device.type,
                                            bondState: bonded!
                                                ? BluetoothBondState.bonded
                                                : BluetoothBondState.none,
                                          ),
                                          rssi: result.rssi);
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height/2,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Available Devices"),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5)
                      ),
                      width: MediaQuery.of(context).size.width,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: new_devices.length,
                        itemBuilder: (BuildContext context, index) {
                          BluetoothDiscoveryResult result = new_devices[index];
                          final device = result.device;
                          final address = device.address;
                          return BluetoothDeviceListEntry(
                            device: device,
                            rssi: result.rssi,
                            // onTap: () {
                            //   Navigator.of(context).pop(result.device);
                            // },
                            onTap: () async {
                              try {
                                bool bonded = false;
                                if (device.isBonded) {
                                  isConnected = false;
                                  print('Unbonding from ${device.address}...');
                                  await FlutterBluetoothSerial.instance
                                      .removeDeviceBondWithAddress(address);
                                  print(
                                      'Unbonding from ${device.address} has succed');
                                } else {
                                  print('Bonding with ${device.address}...');
                                  bonded = (await FlutterBluetoothSerial.instance
                                      .bondDeviceAtAddress(address))!;
                                  print(
                                      'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                                  isConnected = bonded;
                                }
                                setState(() {
                                  new_devices[new_devices.indexOf(result)] =
                                      BluetoothDiscoveryResult(
                                          device: BluetoothDevice(
                                            name: device.name ?? '',
                                            address: address,
                                            type: device.type,
                                            bondState: bonded
                                                ? BluetoothBondState.bonded
                                                : BluetoothBondState.none,
                                          ),
                                          rssi: result.rssi);
                                });
                                if (isConnected) {
                                  try {
                                    mode = 5;
                                    await func.sendMessage("r");
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
                                Navigator.of(context).pop(device);
                              } catch (ex) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Error occured while bonding'),
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
