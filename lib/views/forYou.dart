import 'package:flutter/material.dart';
import 'Simplewidgets.dart';


/*
class forYou  extends StatefulWidget{
  @override
  forYouState createState()=>forYouState();
}
forYouState
State<forYou>
 */


class forYou extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Container(
        height: height,
        width: width,
        child:new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(itemBuilder: (BuildContext context, int index){
                return findPlaylistTile(
                    width: width,
                    isavailable: false,
                    height: height*0.1,
                    title: new Text('Title'),
                    Artist: new Text('Artist'),
                    icon: FittedBox(child: Image.asset('Assets/Images/testImage.jpg',),
                      fit: BoxFit.cover,)
                );
              },itemCount: 40,),
            )
          ],
        ),
      );

  }
}