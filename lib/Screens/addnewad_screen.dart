import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:toast/toast.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';

import 'package:http/http.dart' as http;
import 'package:untitled1/model/user.dart';
import 'package:untitled1/myTools.dart';
import 'package:untitled1/widgets/mWidgets.dart';

class addnewadscreen extends StatefulWidget {
  final String adId;
  final User mUser;
  const addnewadscreen({this.adId, this.mUser});

  @override
  _addnewadscreenState createState() => _addnewadscreenState();
}

class _addnewadscreenState extends State<addnewadscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var usedcontext;
  var pubormod = 'Publish';
  List<Asset> picked;
  List<File> fileImageArray = [];
  bool ispicked = false;
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var priceController = TextEditingController();
  var phoneController=TextEditingController();
  final Categories = Category.values;
  var _selectedcategory;
 // var _selectedlocation;
  var src;




  Future<void> pickimage() async {
    var mList;
    mList = await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);
    setState(() {
      picked = mList;
      getfilefromasset();
      ispicked = true;
    });
  }

  getfilefromasset() {
    picked.forEach((imageAsset) async {
      final filePath =
      await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
      File tempFile = File(filePath);
      if (tempFile.existsSync()) {
        fileImageArray.insert(0, tempFile);
      }
    });
  }

  @override
  void initState() {
    if (widget.adId != null) {
      final prod = Provider
          .of<Products>(context, listen: false)
          .mListproducts
          .firstWhere((element) => element.id == widget.adId);
      src = prod.imageUrl;
      titleController.text = prod.title;
      _selectedcategory = prod.category;
      Provider.of<Products>(context,listen: false).selectedlocation=prod.location;
      descriptionController.text = prod.description;
      priceController.text = prod.price;
      phoneController.text =prod.pubphone;
      pubormod = 'Modify';
    }
    phoneController.text =widget.mUser.phone;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (widget.adId == null)
      Future.delayed(Duration(milliseconds: 500), () => mAlertcategory(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final t = mT(context);
    usedcontext = context;
    return Scaffold(
        appBar: mAppbar("Add your Ad"),
        body:  RelativeBuilder(builder: (ctx,height,width,sy,sx)=> Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                   height: sy(2),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    ispicked
                        ? Image.file(
                      fileImageArray[0],
                      fit: BoxFit.contain,
                      width: sx(200),
                      height: sy(100),
                    )
                        : (src != null)
                        ? Image.network(
                      src,
                      width: sx(200),
                      height: sy(100),
                      fit: BoxFit.contain,
                    )
                        : SizedBox(
                      child: ElevatedButton(
                        onPressed: null,
                        child: Icon(Icons.add_a_photo),
                      ),
                      width: sx(200),
                      height: sy(100),
                    ),
                    IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () => pickimage()),
                  ]),
                  SizedBox(
                //    height: sy(10),
                  ),
                  Provider.of<Products>(context).isloading
                      ? Stack(children: [
                    Center(child: mCat()),
                    Center(child: CircularProgressIndicator(backgroundColor: Colors.white,))
                  ])
                      :  mCat(),
                  mInput('Title', (String val){
                    final titlelength=20;
                    if (val.isEmpty) {
                      return  "write your Ad's Title";
                    } else if (val.length > titlelength) {
                     return "Title must be less than $titlelength character";
                    } return null;
                  },titleController),
                  mInput('Description',(String val){
                      final descriptionlength=300;
                    if (val.isEmpty) {
                        return "write your Ad's Description";
                    }else if(val.length>300){
                      return "Description can't be more than $descriptionlength ";
                    }return null;
                  },descriptionController,
                      mtextinputtype: TextInputType.multiline, maxlines: 5),
                  mInput('Price', (String val){
                    if (val.isEmpty) {
                      return "write your Ad's price";
                    } else if (val.length > 7) {
                      return "price must be less than 8 numbers";
                    }return null;
                  },priceController,
                      mtextinputtype:
                      TextInputType.numberWithOptions(decimal: true)),
                  mInput('Phone Number', (String value){
                    if(value.length != 11 && !value.startsWith('01')){
                      return 'Phone number is not valid';
                    }return null;
                  },phoneController,mtextinputtype: TextInputType.phone),
                  mLocationDropdown((newval) {
                    setState(() {
                      context.read<Products>().selectedlocation=newval;
                    });
                  }),
                  SizedBox(
              //      height: sy(10),
                  ),
                  Align(
                    alignment:
                    Alignment.lerp(Alignment.centerRight, Alignment.center, .3),
                    child: ElevatedButton(
                      onPressed: () => publishAd(usedcontext),
                      child: Text(pubormod),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  publishAd(context) async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    final mprov = Provider.of<Products>(context, listen: false);
    String imageUrl;
    var title = titleController.text;
    var category = _selectedcategory;
    var description = descriptionController.text;
    var price = priceController.text;
    var phonenumber=phoneController.text;
    var location=Provider.of<Products>(context,listen: false).selectedlocation;
    if (category == null) {
      Toast.show("please select a Category", context);
      return;
    }
    if (location == null) {
      Toast.show("please select your location", context);
      return;
    }
    if (!ispicked && widget.adId == null) {
      Toast.show('please pick a photo', context);
    } else if (imageUrl == null && ispicked) {
      try {
        mprov.loading();
        imageUrl = await images().uploadimage(fileImageArray[0],context);
      } catch (e) {
        Toast.show(e.toString(), context);
        mprov.notloading();
        return;
      }
    }
    mprov.loading();
    if (pubormod == 'Publish') {
      await mprov.add(context,
          title: title,
          description: description,
          category: category,
          imageUrl: imageUrl,
          datetime: mgetdatetime(),
          location: location,
          price: price,
          publisherid:widget.mUser.id,
          pubemail: widget.mUser.email,
          pubusername:widget.mUser.username,
          pubphone: phonenumber,
      );
    } else {
      await mprov.updateproduct(Product(id: widget.adId,
        title: title,
        description: description,
        category: category,
        imageUrl: imageUrl,
        datetime: mgetdatetime(),
        location: location,
        price: price,
        publisherid: widget.mUser.id,
        pubemail: widget.mUser.email,
        pubusername:widget.mUser.username,
        pubphone: phonenumber,
      ),context);
      }
    Navigator.of(context).pop();
    mprov.notloading();
  }

  String mgetdatetime() {
    return DateFormat('dd/MM/yyyy HH:mm a').format(DateTime.now());
  }

  Widget mdialogbtn(title, context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade700,
            Colors.blue.shade300,
          ],
        )
      ),
      margin: EdgeInsets.all(5),
      child: ListTile(
        title: Text(title),
        onTap: () {
          setState(() {
            _selectedcategory = title;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  mAlertcategory(mcontext)async {
   await showDialog(
        context: mcontext,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Choose a Category'),
            titleTextStyle:TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ) ,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                mdialogbtn('Vehicles', ctx),
                mdialogbtn('Electronics', ctx),
                mdialogbtn('Furnitures', ctx),
                mdialogbtn('Homemades', ctx),
                mdialogbtn('Fashions', ctx),
                mdialogbtn('pets', ctx),
              ]
            ),
          );
        },
        barrierDismissible: true);
  }

  Widget mCat() {
    // ignore: deprecated_member_use
    return RelativeBuilder(builder: (ctx,height,width,sy,sx)=> ElevatedButton(
        onPressed: () => mAlertcategory(usedcontext),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: sx(18)),
            ),
            SizedBox(
              width: sx(50),
            ),
            Text(
              (_selectedcategory == null)
                  ? 'Choose a Category'
                  : _selectedcategory,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: sx(16),color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }


}
