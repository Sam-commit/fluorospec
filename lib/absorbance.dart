import 'package:flutter/material.dart';
import 'global_variables.dart';
import 'bluetooth_functions.dart';

class absorbanceSelect extends StatelessWidget {
  absorbanceSelect(
      {required this.def,
      required this.callBack,
      required this.genCallBack,
      required this.def2});

  Val def;
  UvVis def2;
  Function callBack;
  Function genCallBack;

  int MAX_EXPOSURE = 40000;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Radio<UvVis>(
                  value: UvVis.Uv,
                  groupValue: def2,
                  onChanged: isConnected
                      ? (UvVis? val) async {
                          try {
                            mode = 5;
                            await func.sendMessage("uv", () {});
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
                      : (UvVis? val) {
                          const snackBar = SnackBar(
                            content: Text('Bluetooth Not Connected'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                  splashRadius: 0,
                ),
                Text("Uv"),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Radio<UvVis>(
                  value: UvVis.Vis,
                  groupValue: def2,
                  onChanged: isConnected
                      ? (UvVis? def2) async {
                          try {
                            mode = 5;
                            await func.sendMessage("vis", () {});
                            callBack(def2);
                          } on Exception catch (e) {
                            print(e);
                            const snackBar = SnackBar(
                              content: Text('Something Went Wrong'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      : (UvVis? def2) {
                          const snackBar = SnackBar(
                            content: Text('Bluetooth Not Connected'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                  splashRadius: 0,
                ),
                Text("Vis"),
              ],
            ),
            SizedBox(
              width: 50,
            ),
            Row(
              children: [
                Radio<Val>(
                  value: Val.t,
                  groupValue: def,
                  onChanged: isConnected
                      ? (Val? val) async {
                          try {
                            mode = 5;
                            await func.sendMessage("t", () {});
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
                            await func.sendMessage("r", () {});
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
            SizedBox(
              width: 20,
            )
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
                              await func.sendMessage("blank", genCallBack);
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
                    onPressed: isConnected
                        ? () async {
                            try {
                              mode = 2;
                              save_mode = 2;
                              await func.sendMessage("abs", genCallBack);
                              // arrayList = [0.91, 0.23, 0.33, 0.56, 0.11, 0.81, 0.11, 0.14, 467.00];
                              // print(exposureVal);
                              // func.processValues(arrayList);
                              // print(valuesListAbs);
                              //
                              // genCallBack(valuesListAbs, true);
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
                                    "intensity " + exposureVal.toString(),
                                    genCallBack);
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
            currUv
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(child: Text("Exposure")),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36,vertical: 16),
                        child: Center(child: Text("Exp 260")),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36,vertical: 16),
                        child: Center(child: Text("Exp 280")),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36,vertical: 16),
                        child: Center(child: Text("Exp 340")),
                      ),
                    ],
                  ),
            currUv
                ? Expanded(
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: (exposureVal == 0)
                              ? "Exposure"
                              : exposureVal.toString(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: TextField(
                            onChanged: (value) {
                              if (int.parse(value) >= 1 &&
                                  int.parse(value) <= MAX_EXPOSURE) {
                                exp260 = int.parse(value);
                                isExposureValid = true;
                              } else {
                                isExposureValid = false;
                                const snackBar = SnackBar(
                                  content: Text(
                                      'Invalid exposure Value. Valid Range = [1,40000]'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  (exp260 == 0) ? "Exp260" : exp260.toString(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: TextField(
                            onChanged: (value) {
                              if (int.parse(value) >= 1 &&
                                  int.parse(value) <= MAX_EXPOSURE) {
                                exp280 = int.parse(value);
                                isExposureValid = true;
                              } else {
                                isExposureValid = false;
                                const snackBar = SnackBar(
                                  content: Text(
                                      'Invalid exposure Value. Valid Range = [1,40000]'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  (exp280 == 0) ? "Exp280" : exp280.toString(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: TextField(
                            onChanged: (value) {
                              if (int.parse(value) >= 1 &&
                                  int.parse(value) <= MAX_EXPOSURE) {
                                exp340 = int.parse(value);
                                isExposureValid = true;
                              } else {
                                isExposureValid = false;
                                const snackBar = SnackBar(
                                  content: Text(
                                      'Invalid exposure Value. Valid Range = [1,40000]'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  (exp340 == 0) ? "Exp340" : exp340.toString(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      )
                    ],
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: isConnected
                        ? () async {
                            try {
                              mode = 4;
                              await func.sendMessage("auto", genCallBack);
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
