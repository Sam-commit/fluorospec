
import 'dart:math';

import 'package:app_hc05_arduino_testright/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Spectra extends StatelessWidget {

  List<double>data;
  Spectra({required this.data,required this.type});

  bool type;
  double mini=0;
  double maxi =1;

  List<Color> gradient = [
    Color(0xFF56ab2f),
    Color(0xFFd77076),
  ];


  @override
  Widget build(BuildContext context) {
    print(data);
    if(!data.isEmpty) {
      mini = data.reduce(min);
      maxi = data.reduce(max);
    }
    double div  = (maxi-mini)/6;

    int cnt=401;
    List<FlSpot>graphspoints=[];
    for(var i in data){
      double y=0;
      if(div!=0) {
        y = 1.toDouble() + ((i - mini) / div);
      }
        graphspoints.add(FlSpot(cnt.toDouble(),y));
        cnt++;

    }


    return Padding(
      padding: const EdgeInsets.only(top: 8,right: 30,left: 10,bottom: 8),
      child: Container(
        child: LineChart(
            LineChartData(
              clipData: FlClipData(
                right: true,
                top: false,
                left: false,
                bottom: false
              ),
              lineBarsData: [
                LineChartBarData(
                  gradient: LinearGradient(
                    colors: gradient
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  spots: graphspoints,
                  belowBarData:  BarAreaData(
                    show: true,
                    gradient:LinearGradient(
                        colors: gradient.map((e) => e.withOpacity(0.3)).toList()
                    ),
                  ),

                ),
              ],
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey,width: 1),
                    right: BorderSide(color: Colors.grey,width: 1),
                    bottom: BorderSide(color: Colors.grey,width: 1),
                  )
                ),
                gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                          strokeWidth: 1, color: Colors.grey);
                    },
                    horizontalInterval: 1,
                    verticalInterval: 50,
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value){
                      return FlLine(strokeWidth:1,color: Colors.grey);
                    }
                ),
                minX: 401,
                minY: 0.5,
                maxX: 701,
                maxY: 8,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      // getTextStyles: (value) =>
                      // TextStyle(color: Colors.white),
                      // margin: 8,
                        showTitles: true,
                        getTitlesWidget: (value , name) {
                          switch (value.toInt()) {
                            case 450:
                              return Text("450");
                            case 500:
                              return Text("500");
                            case 550:
                              return Text("550");
                            case 600:
                              return Text("600");
                            case 650:
                              return Text("650");
                            case 700:
                              return Text("700");
                          }
                          return Text("");
                        }),),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        reservedSize: 45,
                        // getTextStyles: (value) =>
                        // TextStyle(color: Colors.white),
                        // margin: 8,
                        showTitles: true,
                        getTitlesWidget: (value , name) {
                          switch (value.toInt()) {
                            case 1:
                              return Text((type) ? mini.toStringAsFixed(3) : mini.toStringAsFixed(0));
                            case 2:
                              return Text((type) ? (mini + div).toStringAsFixed(3) : (mini + div).toStringAsFixed(0));
                            case 3:
                              return Text((type) ? (mini + 2*div).toStringAsFixed(3) : (mini + 2*div).toStringAsFixed(0));
                            case 4:
                              return Text((type) ? (mini + 3*div).toStringAsFixed(3) : (mini + 3*div).toStringAsFixed(0));
                            case 5:
                              return Text((type) ? (mini + 4*div).toStringAsFixed(3) : (mini + 4*div).toStringAsFixed(0));
                            case 6:
                              return Text((type) ? (mini + 5*div).toStringAsFixed(3) : (mini + 5*div).toStringAsFixed(0));
                            case 7:
                              return Text((type) ? (mini + 6*div).toStringAsFixed(3) : (mini + 6*div).toStringAsFixed(0));
                          }
                          return Text("");
                        }),),

                )

            )
        ),
      ),
    );
  }
}
