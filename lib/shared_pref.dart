import 'package:app_hc05_arduino_testright/bluetooth_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String>device_name = [];

class SharedPref{


  Future setWavelengthsAndExposure(List<String>od_list,int exposure)async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int cnt=1;
    for(var i in od_list){

      prefs.setString("$cnt", i);
      cnt++;

    }

    prefs.setInt("exposure", exposure);
    prefs.setStringList("HC-05", device_name);

  }

  Future<List<String>> getWavelengthsAndExposureAndDevices()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>od_list=[];

    String val = prefs.getString("1") ?? "420";
    od_list.add(val);

    val = prefs.getString("2") ?? "480";
    od_list.add(val);

    val = prefs.getString("3") ?? "520";
    od_list.add(val);

    val = prefs.getString("4") ?? "580";
    od_list.add(val);

    val = prefs.getString("5") ?? "620";
    od_list.add(val);

    val = prefs.getString("6") ?? "680";
    od_list.add(val);

    exposureVal = prefs.getInt("exposure") ?? 0;
    device_name = prefs.getStringList("HC-05") ?? [];

    return od_list;

  }




}