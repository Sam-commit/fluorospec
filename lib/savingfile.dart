

import 'dart:io';

import 'package:app_hc05_arduino_testright/bluetooth_functions.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SavingFile{
  
  List<List<dynamic>>saving_data=[];
  
  Future save_data(List<double>data,String name)async{
    
    saving_data.clear();
    String temp = save_mode==2 ? "abs" : "intensity";
    saving_data.add(["wavelength",temp]);
    int cnt = 401;
    
    for(var i in data){
      saving_data.add(["$cnt","$i"]);
      cnt++;
    }

    //final Directory? _dirpath = await getExternalStorageDirectory();
    Directory _folderpath = Directory("/storage/emulated/0/Download/TestRight");

    String path;
    print(_folderpath.path);

    //PermissionStatus permission = await Permission.manageExternalStorage.request();
    PermissionStatus permission2 = await Permission.storage.request();
    if(permission2.isGranted ){

      print(permission2.name);

      if (await _folderpath.exists()) {
        path = _folderpath.path;
      } else {
        //if folder not exists create folder and then return its path
        final Directory _appDocDirNewFolder =
        await _folderpath..create();
        path =  _appDocDirNewFolder.path;
      }

      print(path);
      try {
        String csvData = ListToCsvConverter().convert(saving_data);
        path = "$path/${name}.csv";
        print(path);
        final File file = File(path);
        await file.writeAsString(csvData);
      } on Exception catch (e) {
        print(e);
      }
    }
    else {
      print("permission denied");
    }


    
  }
  
  
  
  
}