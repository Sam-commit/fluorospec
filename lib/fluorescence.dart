
import 'package:flutter/material.dart';
import 'bluetooth_functions.dart';
import 'global_variables.dart';

class fluorescenceSelect extends StatelessWidget {

  fluorescenceSelect({required this.genCallBack});

  Function genCallBack;
  int MAX_EXPOSURE = 40000;

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
                child: ElevatedButton(onPressed: isConnected
                    ? () async {
                  try {
                    mode = 6;
                    //arrayList = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
                    //func.processValues(arrayList);
                    //print(valuesListBlank);
                    await func.sendMessage("f365",genCallBack);
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
                }, child: Text("Exc 365")),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(onPressed: isConnected
                    ? () async {
                  try {
                    mode = 7;
                    //arrayList = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
                    //func.processValues(arrayList);
                    //print(valuesListBlank);
                    await func.sendMessage("f470",genCallBack);
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
                }, child: Text("Exc 470")),
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
                    (exposureVal ==0 ) ? "Exposure" : exposureVal.toString(),
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
              )),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(onPressed: isConnected
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
                }, child: Text("Autoset")),
              )),
        ],
      )
    ]);
  }
}