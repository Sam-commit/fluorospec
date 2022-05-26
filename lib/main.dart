import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bluetooth_functions.dart';
import 'devices_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'spectra.dart';
import 'savingfile.dart';
import 'shared_pref.dart';

BleFunctions func = BleFunctions();
enum Val { r, t }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _controller1;
  late TabController _controller2;
  Val _def = Val.r;

  String filename = "Unnamed";

  List<double> final_list = [];
  List<String> od_list = [];

  late BluetoothDevice _device;

  @override
  void initState() {
    mode = 5;

    _controller1 = TabController(length: 2, vsync: this);
    _controller2 = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future checkingConnection() async {
    if (isConnected) {
      await BluetoothConnection.toAddress(_device.address).then((_connection) {
        print('Connected to the device');
        connection = _connection;
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }

    od_list = await SharedPref().getWavelengthsAndExposure();
  }

  radioCallback(Val value) {
    setState(() {
      _def = value;
    });
  }

  connectCallBack() {
    print("got called");
    setState(() {});
  }

  bool type = false;

  generalCallback(List<double> data, bool type) {
    setState(() {
      final_list = data;
      this.type = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: isConnected
          ? AppBar(
              title: Text(
                "Connected to ${_device.name}",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await connection?.finish();
                      isConnected = false;
                      setState(() {});
                    },
                    child: Text(
                      "Disonnect",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                  ),
                )
              ],
            )
          : AppBar(
              title: Text(
                "Not Connected",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.yellow,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      _device = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AvailableDevices(
                                    callBack: connectCallBack,
                                  )));
                    },
                    child: Text(
                      "Connect",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.yellow),
                    ),
                  ),
                )
              ],
            ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(
                              image: AssetImage("images/testrightlogo.png"),
                              width: 120,
                              height: 50,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  (save_mode ==2 || save_mode==3) ?
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Save As"),
                                      content: TextField(
                                        onChanged: (value) {
                                          filename = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "File name",
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(10),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await SavingFile().save_data(
                                                  final_list, filename);

                                                const snackBar = SnackBar(
                                                  content: Text('File saved'),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);

                                              Navigator.pop(context);

                                            },
                                            child: Text("Save")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel")),
                                      ],
                                    ),
                                  ) : () {
                                    const snackBar = SnackBar(
                                      content: Text('No data to save'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  };
                                  //print(_device.name);
                                  //print(connection?.isConnected);

                                  //print(_device.name);
                                  //print(connection?.isConnected);
                                  //SavingFile().save_data(final_list, "Abracadabra");
                                },
                                child: Text("Save"))
                          ],
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Column(
                                      children: [
                                        TabBar(
                                          controller: _controller2,
                                          indicatorColor: Colors.green,
                                          labelPadding: EdgeInsets.all(10),
                                          padding: EdgeInsets.all(10),
                                          tabs: [
                                            Text(
                                              "OD",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "SPECTRA",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: TabBarView(
                                              controller: _controller2,
                                              children: [
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
//SizedBox(width: 10,),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 90),
                                                              child: Text("nm"),
                                                            ),
                                                            Text(
                                                                "abs/intensity")
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ1"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[0] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[0]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[0]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ2"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[1] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[1]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[1]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ3"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[2] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[2]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[2]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ4"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[3] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[3]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[3]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ5"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[4] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[4]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[4]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text("ƛ6"),
                                                                SizedBox(
                                                                  width: 40,
                                                                ),
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    onSubmitted:
                                                                        (value) {
                                                                      od_list[5] =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          od_list[5]
                                                                              .toString(),
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      disabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 2.0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text((final_list
                                                                    .isNotEmpty)
                                                                ? final_list[
                                                                        int.parse(od_list[5]) -
                                                                            401]
                                                                    .toString()
                                                                : "NA"),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spectra(
                                                  data: final_list,
                                                  type: type,
                                                ),
                                              ]),
                                        )
                                      ],
                                    ),
                                  ),
                                  flex: 9,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        TabBar(
                                          controller: _controller1,
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, top: 10),
                                          labelPadding: EdgeInsets.all(5),
                                          tabs: [
                                            Text(
                                              "Absorbance",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              "Fluorescence",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: TabBarView(
                                              controller: _controller1,
                                              children: [
                                                absorbanceSelect(
                                                  def: _def,
                                                  callBack: radioCallback,
                                                  genCallBack: generalCallback,
                                                ),
                                                fluorescenceSelect(),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isConnected
                              ? () async {
                                  try {
                                    await connection?.finish();
                                    isConnected = false;
                                    await SharedPref()
                                        .setWavelengthsAndExposure(
                                            od_list, exposureVal);
                                    SystemNavigator.pop();
                                  } on Exception catch (e) {
                                    print(e);
                                    const snackBar = SnackBar(
                                      content: Text('Something Went Wrong'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              : () {
                                  const snackBar = SnackBar(
                                    content: Text('Bluetooth Not Connected'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.power_settings_new_rounded),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Dis & Close"),
                              ],
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          print(snapshot.connectionState);
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: checkingConnection(),
      ),
    );
  }
}

class absorbanceSelect extends StatelessWidget {
  absorbanceSelect(
      {required this.def, required this.callBack, required this.genCallBack});

  Val def;
  Function callBack;
  Function genCallBack;

  int MAX_EXPOSURE = 40000;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Radio<Val>(
                  value: Val.t,
                  groupValue: def,
                  onChanged: isConnected
                      ? (Val? val) async {
                          try {
                            mode = 5;
                            await func.sendMessage("t",(){});
                            callBack(val);
                          } on Exception catch (e) {
                            print(e);
                            const snackBar = SnackBar(
                              content: Text('Something Went Wrong'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      : (Val? val) {
                          const snackBar = SnackBar(
                            content: Text('Bluetooth Not Connected'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                  splashRadius: 0,
                ),
                Text("T"),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Radio<Val>(
                  value: Val.r,
                  groupValue: def,
                  onChanged: isConnected
                      ? (Val? val) async {
                          try {
                            mode = 5;
                            await func.sendMessage("r",(){});
                            callBack(val);
                          } on Exception catch (e) {
                            print(e);
                            const snackBar = SnackBar(
                              content: Text('Something Went Wrong'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      : (Val? val) {
                          const snackBar = SnackBar(
                            content: Text('Bluetooth Not Connected'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                  splashRadius: 0,
                ),
                Text("R"),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: isConnected
                        ? () async {
                            try {
                              mode = 1;
                              //arrayList = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
                              //func.processValues(arrayList);
                              //print(valuesListBlank);
                              await func.sendMessage("blank",genCallBack);
                              //genCallBack(valuesListBlank, false);
                            } on Exception catch (e) {
                              print(e);
                              const snackBar = SnackBar(
                                content: Text('Something Went Wrong'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        : () {
                            const snackBar = SnackBar(
                              content: Text('Bluetooth Not Connected'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                    child: Text("Blank")),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(

                    onPressed: isConnected ?  () async{
                      try {
                        mode = 2;
                        save_mode = 2;
                        await func.sendMessage("abs",genCallBack);
                        // arrayList = [0.91, 0.23, 0.33, 0.56, 0.11, 0.81, 0.11, 0.14, 467.00];
                        // func.processValues(arrayList);
                        // print(valuesListAbs);
                        //genCallBack(valuesListAbs, true);
                      } on Exception catch (e) {
                        print(e);
                        const snackBar = SnackBar(
                          content: Text('Something Went Wrong'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    : () {
                        const snackBar = SnackBar(
                          content: Text('Bluetooth Not Connected'),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBar);
                      },
                    child: Text("Abs")),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: isConnected
                        ? () async {
                            //mode = 3;
                            // await func.sendMessage("abs");
                            // arrayList = [1110.toDouble(),20211.toDouble(),52000.toDouble(),34000.toDouble(),101.toDouble(),3737.toDouble(),8585.toDouble(),900.toDouble(),498.toDouble()];
                            // func.processValues(arrayList);
                            // print(valuesListIntensity);

                            if (isExposureValid) {
                              try {
                                mode = 3;
                                save_mode = 3;
                                await func.sendMessage(
                                    "intensity " + exposureVal.toString(),genCallBack);
                                //genCallBack(valuesListIntensity, false);
                              } on Exception catch (e) {
                                print(e);
                                const snackBar = SnackBar(
                                  content: Text('Something Went Wrong'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            } else {
                              const snackBar = SnackBar(
                                content: Text("invalid exposure value"),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        : () {
                            const snackBar = SnackBar(
                              content: Text('Bluetooth Not Connected'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                    child: Text("Intensity")),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(child: Text("Exposure")),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  onChanged: (value) {
                    if (int.parse(value) >= 1 &&
                        int.parse(value) <= MAX_EXPOSURE) {
                      exposureVal = int.parse(value);
                      isExposureValid = true;
                    } else {
                      isExposureValid = false;
                      const snackBar = SnackBar(
                        content: Text(
                            'Invalid exposure Value. Valid Range = [1,40000]'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  decoration: InputDecoration(
                    hintText:
                        exposureVal == 0 ? "Exposure" : exposureVal.toString(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  keyboardType:
                  TextInputType
                      .number,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: isConnected
                        ? () async {
                            try {
                              mode = 4;
                              await func.sendMessage("auto",genCallBack);
                              const snackBar = SnackBar(
                                content: Text('Auto value recieved'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } on Exception catch (e) {
                              print(e);
                              const snackBar = SnackBar(
                                content: Text('Something Went Wrong'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        : () {
                            const snackBar = SnackBar(
                              content: Text('Bluetooth Not Connected'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                    child: Text("Autoset")),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class fluorescenceSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 50,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(onPressed: () {}, child: Text("Exc 365")),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(onPressed: () {}, child: Text("Exc 470")),
              )),
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
      Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text("Exposure")),
          )),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(hintText: "Exposure"),
            ),
          )),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(onPressed: () {}, child: Text("Autoset")),
          )),
        ],
      )
    ]);
  }
}
