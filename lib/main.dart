import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bluetooth_functions.dart';
import 'devices_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'spectra.dart';
import 'savingfile.dart';
import 'shared_pref.dart';
import 'global_variables.dart';
import 'fluorescence.dart';
import 'absorbance.dart';
import 'od_textbox.dart';
import 'od_textbox_uv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  od_list = await SharedPref().getWavelengthsAndExposureAndDevices();
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
  UvVis _def2 = UvVis.Vis;
  int flag=1;
  String filename = "Unnamed";


  List<double> final_list = [];


  late BluetoothDevice _device;

  @override
  void initState() {
    mode = 5;

    _controller1 = TabController(length: 2, vsync: this);
    _controller2 = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future checkingConnection() async {
    if (isConnected && flag==1) {
      await BluetoothConnection.toAddress(_device.address).then((_connection) {
        print('Connected to the device');
        connection = _connection;

        String inputData="";
        connection?.input?.listen((data) {
          inputData += utf8.decode(data);
          int cnt=0;
          if(mode==4){
            func.onDataReceived(inputData,generalCallback);
          }
          else {

            for(var i =0;i<inputData.length;i++){
              if(inputData[i]=='/')cnt++;
            }
            if(cnt==9){
              func.onDataReceived(inputData,generalCallback);
              inputData="";
            }

          }

        });

        flag++;

      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }


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
                      flag=1;
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
            return SingleChildScrollView(
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
                            },
                            child: Text("Save"))
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height/2,
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
                              physics: NeverScrollableScrollPhysics(),
                                controller: _controller2,
                                children: [
                                  currUv ? Column(
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
                                      Od_TextBox(num: 1,final_list: final_list,),
                                      Od_TextBox(num: 2,final_list: final_list,),
                                      Od_TextBox(num: 3,final_list: final_list,),
                                      Od_TextBox(num: 4,final_list: final_list,),
                                      Od_TextBox(num: 5,final_list: final_list,),
                                      Od_TextBox(num: 6,final_list: final_list,),

                                    ],
                                  ) : Column(
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
                                      Od_TextBox_Uv(num: 1,final_list: final_list,hint:"260",),
                                      Od_TextBox_Uv(num: 2,final_list: final_list,hint: "280",),
                                      Od_TextBox_Uv(num: 3,final_list: final_list,hint: "340",),
                                      Od_TextBox_Uv(num: 3,final_list: final_list,hint: "260/280",),
                                    ],
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
                    Container(
                      height:currUv ? MediaQuery.of(context).size.height/4 : MediaQuery.of(context).size.height/2.70,
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
                                    def2: _def2,
                                    def: _def,
                                    callBack: radioCallback,
                                    genCallBack: generalCallback,
                                  ),
                                  fluorescenceSelect(
                                    genCallBack: generalCallback,
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isConnected
                          ? () async {
                              try {
                                await connection?.finish();
                                isConnected = false;
                                flag=1;
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


