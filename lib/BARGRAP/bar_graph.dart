import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:trackie/BARGRAP/individual_bar.dart';

class BarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const BarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  //this list can hold data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    
    super.initState();

    //need to scroll latest month automatically 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrolltoEnd);
  }

  //initialize bar data - user our monthly summary to crate list of bars
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

//uppper limit of graph

  double calculateMax() {
    double max = 500;

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return 500;
    }
    return max;
  }


final ScrollController _scrollController = ScrollController();
void scrolltoEnd(){
  _scrollController.animateTo(_scrollController.position.maxScrollExtent,
   duration: const Duration(seconds: 1), 
   curve: Curves.fastOutSlowIn);
} 
  @override
  Widget build(BuildContext context) {
    //initialize upon build
    initializeBarData();

    //bar dimensions

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width:
              barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
                minY: 0,
                maxY: calculateMax(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: getbottomtitiles,
                      reservedSize: 24,
                    ),
                  ),
                ),
                barGroups: barData
                    .map(
                      (data) => BarChartGroupData(
                        x: data.x,
                        barRods: [
                          BarChartRodData(
                              toY: data.y,
                              width: 20,
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade800,
                              backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: calculateMax(),
                                  color:
                                      const Color.fromARGB(255, 253, 253, 253))),
                        ],
                      ),
                    )
                    .toList(),
                alignment: BarChartAlignment.start,
                groupsSpace: spaceBetweenBars),
          ),
        ),
      ),
    );
  }

  //botttom titles
}

Widget getbottomtitiles(double value, TitleMeta meta) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'A';
      break;
    case 1:
      text = 'S';
      break;
    case 2:
      text = 'O';
      break;
    case 3:
      text = 'N';
      break;
    case 4:
      text = 'D';
      break;
    case 5:
      text = 'J';
      break;
    case 6:
      text = 'F';
      break;
    case 7:
      text = 'M';
      break;
    case 8:
      text = 'A';
      break;
    case 9:
      text = 'M';
      break;
    case 10:
      text = 'J';
      break;
    case 11:
      text = 'J';
      break;
    default:
      text = 'A';
      break;
  }

  return SideTitleWidget(
      child: Text(
        text,
        style: textstyle,
      ),
      axisSide: meta.axisSide);
}
