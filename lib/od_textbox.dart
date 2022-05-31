
import 'package:flutter/material.dart';
import 'global_variables.dart';

class Od_TextBox extends StatefulWidget {

  Od_TextBox({required this.num,required this.final_list});

  int num;
  List<double> final_list;

  @override
  State<Od_TextBox> createState() => _Od_TextBoxState();
}

class _Od_TextBoxState extends State<Od_TextBox> {
  bool value_ok = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Text("ƛ${widget.num}"),
              SizedBox(
                width: 40,
              ),
              SizedBox(
                width: 100,
                child:
                TextField(
                  onChanged: (value){
                    if(int.parse(value)<=700 && int.parse(value)>=401){
                      value_ok = true;
                    }
                    else {
                      value_ok = false;
                      const snackBar = SnackBar(
                        content: Text('Invalid value. Valid Range - [401,700]'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  keyboardType:
                  TextInputType
                      .number,
                  onSubmitted:
                      (value) {
                    if(value_ok){
                      od_list[widget.num-1] =
                          value;
                      setState(() {});
                    }
                    else {
                      const snackBar = SnackBar(
                        content: Text('Invalid value'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                  },
                  decoration:
                  InputDecoration(
                    hintText:
                    od_list[widget.num-1]
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
          Text((widget.final_list
              .isNotEmpty)
              ? widget.final_list[
          int.parse(od_list[widget.num-1]) -
              401]
              .toString()
              : "NA"),
        ],
      ),
    );
  }
}


