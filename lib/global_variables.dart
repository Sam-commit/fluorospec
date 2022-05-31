
import 'bluetooth_functions.dart';

BleFunctions func = BleFunctions();
enum Val { r, t }
enum  UvVis{ Uv, Vis }
bool isConnected = false;
List<String> od_list = [];
List<String>device_name = [];
bool currUv = true;
int exp260 =0;
int exp280=0;
int exp340=0;