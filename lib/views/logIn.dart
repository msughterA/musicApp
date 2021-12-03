import 'package:flutter/material.dart';


class logIn extends StatefulWidget{
  @override
  logInState createState()=>logInState();
}

class logInState extends State<logIn>{
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SingleChildScrollView(
        child: new Container(
          height: height,
          width: width,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(
                  top: height*0.3,
                  left: width*0.1,
                ),
                height: height*0.4,
                width: width,
                child:  new Text('Login',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                  ),),
              ),
              new Container(
                height: height*0.4,
                padding: EdgeInsets.only(top: 1.0,right: 18.0,
                    left: 18.0),
                child: new Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'email or username',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),

                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'password',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),
                      ),
                      new GestureDetector(onTap: (){
                        //Add the checked songs to Playlist

                      },
                        child: new Container(
                          child:new Center(
                            child:  new Text('Login',style: new TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          decoration: new BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),offset: Offset(10,10),
                                  blurRadius: 10)],
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: Colors.pink
                          ),
                          height: height*0.06,
                          width: width*0.8,),),
                    ],
                  ),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text('Don\'t have an accoount'),
                  new FlatButton(onPressed: (){}, child: new Text('Create',style: new TextStyle(
                      color: Colors.pink,
                      decoration: TextDecoration.underline
                  ),))
                ],)
            ],),
        ),
      )
    );
  }
}


class createAcc extends StatefulWidget{
  @override
  createAccState createState()=>createAccState();
}

class createAccState extends State<createAcc>{
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Scaffold(
      body:SingleChildScrollView(
        child: new Container(
          height: height,
          width: width,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(
                  top: height*0.1,
                  left: width*0.1,
                ),
                height: height*0.2,
                width: width,
                child:  new Text('Create account',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                  ),),
              ),
              new Container(
                height: height*0.4,
                padding: EdgeInsets.only(top: 1.0,right: 18.0,
                    left: 18.0),
                child: new Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'email or username',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),

                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'enter password',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'confirm password',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'enter phone number',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink)
                            )
                        ),
                      ),
                      new GestureDetector(onTap: (){
                        //Add the checked songs to Playlist

                      },
                        child: new Container(
                          child:new Center(
                            child:  new Text('Create',style: new TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          decoration: new BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),offset: Offset(10,10),
                                  blurRadius: 10)],
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: Colors.pink
                          ),
                          height: height*0.06,
                          width: width*0.8,),),
                    ],
                  ),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text('Already have an account'),
                  new FlatButton(onPressed: (){}, child: new Text('Login',style: new TextStyle(
                      color: Colors.pink,
                      decoration: TextDecoration.underline
                  ),))
                ],)
            ],),
        ),
      ) ,
    )
    ;
  }
}