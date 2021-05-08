import 'package:flutter/material.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../myTools.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  var catChecked='Vehicles';
  @override
  Widget build(BuildContext context) {
    final t = mT(context);
    return Scaffold(
      appBar: mAppbar('Your Filter'),
      body: Column(
          children: [
            mRadioChecked('Category', Category.values),
          ],
        ),
    );
  }

  Widget mRadioChecked(
   String filter, List mList,) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(filter,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),),
          SizedBox(
            height: 10,
          ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: mList.length+1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 2,
       mainAxisExtent: 60,
       //       mainAxisSpacing: 10,
              ),
            itemBuilder: (ctx, index) {
              return
                  RadioListTile(
                    toggleable: true,
                    title:Text(index==0?'All':mList[index].toString().substring(9).trim(),) ,
                    value:index==0?'All': mList[index].toString().substring(9).trim(),
                    groupValue:catChecked,
                    onChanged: (checked){
                      setState(() {
                        catChecked=checked;
                      });
                    },
                  );
            },
          ),
        ],
      );
    }

}
