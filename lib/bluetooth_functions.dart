import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

BluetoothConnection? connection;
int mode = 5;
int save_mode = 5;
int exposureVal=0;
List<double> valuesListAbs = [];
List<double> valuesListIntensity = [];
List<double> valuesListBlank = [];
List<double> arrayList = [];
bool isExposureValid = true;


class BleFunctions {


  Future sendMessage(String text,Function callback) async {
    text = text.trim();
    // mode = 5 for r and t

    int delay;

    if (mode == 1 || mode == 4) {
      delay = 40000;
    } else {
      delay = (5000 + 2.5 * exposureVal).toInt();
    }

    if (mode != 5) {
      // progressData = ProgressDialog.show(ledControl.this, null, "Please Wait!");
      // handler.postDelayed(runnable, delay);
      // edtTime.clearFocus();
    }

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;
        if (mode != 5) await recieveMessage(callback);

        // Future.delayed(Duration(milliseconds: delay)).then((_) {
        //   print("hello");
        // });
      } catch (e) {
        print(e);
      }
    }
  }

  Future recieveMessage(Function callback) async {


    arrayList.clear();
    if (mode == 2) {
      valuesListAbs.clear();
    } else if (mode == 3) {
      valuesListIntensity.clear();
    } else if (mode == 1) {
      valuesListBlank.clear();
    }
    String inputData="";
    connection?.input?.listen((data) {
      inputData += utf8.decode(data);
      int cnt=0;
      for(var i =0;i<inputData.length;i++){
        if(inputData[i]=='/')cnt++;
      }
      if(cnt==9){
        onDataReceived(inputData,callback);
      }
    });


  }

  void onDataReceived(String inputData,Function callback) {

    if (mode == 1 || mode == 2 || mode == 3) {
      List<String> separated = inputData.split("/");

      for (String s in separated) {
        try {
          arrayList.add(double.parse(s));
        } catch (e) {
          print(e);
        }
      }
      if (arrayList.length > 7) {
        processValues(arrayList);
      }
    }
    else if (mode == 4) {
      exposureVal = int.parse(inputData);
    } else {
      //showToastOnlyOnce(getString(R.string.msg_range));
    }

    if (mode == 1)
      callback(valuesListBlank, false);
    else if (mode == 2) {
      callback(valuesListAbs, true);
    }
    else if (mode == 3) {
      callback(valuesListIntensity, false);
    }

  }

  void processValues(List<double> arrayList) {
//        StringBuilder builder = new StringBuilder();
    try {
      inputPnt = [
        415.toDouble(),
        arrayList[0],
        445.toDouble(),
        arrayList[1],
        480.toDouble(),
        arrayList[2],
        515.toDouble(),
        arrayList[3],
        555.toDouble(),
        arrayList[4],
        590.toDouble(),
        arrayList[5],
        630.toDouble(),
        arrayList[6],
        680.toDouble(),
        arrayList[7],
      ];
      exposureVal = arrayList[8].round().toInt();

      Func(inputPnt, inputStart, inputEnd, graphs);
    } catch (e) {
      print(e);
      return;
    }
//                                    Ending the receiving loop and stopping animation
//     if (mode == 2) {
//     try {
//     showToastOnlyOnce("Abs is taken");
//     detailsFragment.setData(valuesListAbs);
//     detailsFragment.onButtonClick();
//     } catch (Exception e) {
//     e.printStackTrace();
//     msg(e.getMessage());
//     }
//
//     ledControl.this.runOnUiThread(new Runnable() {
//     @Override
//     public void run() {
//     try{
//     concFragment.setValuesList(valuesListAbs);
//     }catch (Exception e){
//     e.printStackTrace();
//     }
//     }
//     });
//     spectraFragment.receiveData(valuesListAbs);
//     } else if (mode == 3) {
//     try {
//     showToastOnlyOnce("Intensity is taken");
//     detailsFragment.setData(valuesListIntensity);
//     detailsFragment.onButtonClick();
//     } catch (Exception e) {
//     e.printStackTrace();
//     msg(e.getMessage());
//     }
//
//     spectraFragment.receiveData(valuesListIntensity);
//     } else if(mode == 1) {
//     showToastOnlyOnce("Blank successful");
//     spectraFragment.receiveData(valuesListBlank);
// //                                        if(valuesListBlank.get(0) == 0)
// //                                            msg("Blank received 0");
// //                                        else
// //                                            msg("Blank received 1");
//     }
//
//     ledControl.this.runOnUiThread(new Runnable() {
//     @Override
//     public void run() {
//     handler.removeCallbacks(runnable);
//
//     edtTime.setText(String.valueOf(exposureVal));
//     edtTime.clearFocus();
//
//     progressData.dismiss();
//     btnSave.setVisibility(View.VISIBLE);
//     }
//     });
  }

  String state = "";
  int n = 8; // points
  //int n2 = n + n;
  List<double> inputPnt = []; // points x,y ..

  //--------------Input Variables----------------
  int inputStart = 1;
  int inputEnd = 8;
  int graphs = 300;
  //---------------------------------------------

  void Func(List<double> inputArray, int inputStart, int inputEnd, int graphs) {
    //print(inputArray);
    List<double> p = List.filled(2, 0.toDouble());
    double t;
    int startingIndex = (inputStart - 1) * 2;
    int endingIndex = (inputEnd - 1) * 2;
    int n = (inputEnd - inputStart);
    double interval = (n / graphs);
    int i = 0;

    List<double> sliced = List.filled(n * 2 + 3, 0.toDouble());
    sliced[0] = 0.toDouble();
    int j = 1;
    for (int k = startingIndex; k < endingIndex + 2; k++) {
      sliced[j] = inputArray[k];
      j++;
    }

    // for(int a=0;a<n * 2 + 2;a++){
    //   Serial.print(sliced[a]);
    //   Serial.print(" , ");
    // }

    NumberFormat df;
    if (mode == 3)
      df = NumberFormat("#");
    else
      df = NumberFormat("#.###");

    double num;
    //print(sliced);
    for (t = 0.0; t <= n.toDouble(); t += interval) {
      getpnt(p, t, sliced, n * 2 + 2);
      i++;
      num = double.parse(df.format(p[1]));
      //print(num);

      try {
//                Log.e("DATA", String.valueOf(num));
        if (mode == 2) {
          valuesListAbs.add(num);
        } else if (mode == 3) {
          valuesListIntensity.add(num);
        } else {
//                  for blank
          valuesListBlank.add(num);
        }
//              Log.e("DATA", data);
      } catch (e) {
        print(e);
      }

//            Serial.println(p[1]);
    }
  }

  void getpnt(
      List<double> p, double t, List<double> pont, int noOfPnts) // t = <0,n-1>
  {
    List<double> pnt = List.filled(noOfPnts, 0.toDouble());
    int j = 0;

    for (int i = 1; i <= noOfPnts; i++) {
      pnt[j++] = pont[i];
    }
    int n = noOfPnts ~/ 2;
    int n2 = n + n;
    int i, ii;
    double a0, a1, a2, a3, d1, d2, tt, ttt;
    List<double> p0, p1, p2, p3;
    // handle t out of range
    if (t <= 0.0) {
      p[0] = pnt[0];
      p[1] = pnt[1];
      return;
    }
    if (t >= (n - 1).toDouble()) {
      p[0] = pnt[n2 - 2];
      p[1] = pnt[n2 - 1];
      return;
    }
    // select patch
    i = t.floor(); // start point of patch
    t -= i.toDouble(); // parameter <0,1>
    i <<= 1;
    tt = (t * t);
    ttt = (tt * t);
    // control points
    ii = i - 2;
    if (ii < 0) ii = 0;
    if (ii >= n2) ii = n2 - 2;
    p0 = _copy(pnt, ii);
    ii = i;
    if (ii < 0) ii = 0;
    if (ii >= n2) ii = n2 - 2;
    p1 = _copy(pnt, ii);
    ii = i + 2;
    if (ii < 0) ii = 0;
    if (ii >= n2) ii = n2 - 2;
    p2 = _copy(pnt, ii);
    ii = i + 4;
    if (ii < 0) ii = 0;
    if (ii >= n2) ii = n2 - 2;
    p3 = _copy(pnt, ii);
    // loop all dimensions
    for (i = 0; i < 2; i++) {
      // compute polynomial coeficients
      d1 = (0.5 * (p2[i] - p0[i]));
      d2 = (0.5 * (p3[i] - p1[i]));
      a0 = p1[i];
      a1 = d1;
      a2 = ((3.0 * (p2[i] - p1[i])) - (2.0 * d1) - d2);
      a3 = (d1 + d2 + (2.0 * (-p2[i] + p1[i])));
      // compute point coordinate
      p[i] = a0 + (a1 * t) + (a2 * tt) + (a3 * ttt);
    }
  }

  List<double> _copy(List<double> pnt, int i) {
    List<double> list = [];
    for (int j = i; j < pnt.length; j++) {
      list.add(pnt[j]);
    }

    List<double> p = List.filled(list.length, 0.toDouble());
    int innn = 0;
    for (var value in list) {
      p[innn++] = value;
    }
    return p;
  }
}
