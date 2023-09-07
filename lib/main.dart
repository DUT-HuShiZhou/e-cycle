// The SignUp and Login Page
// @author hushizhou
// @date 2023.8.4f
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';


void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
class LoginPage extends StatefulWidget
{
  const LoginPage({Key? key}):super(key: key);
  @override
  LoginPageState createState()=>LoginPageState();
}
class LoginPageState extends State<LoginPage>
{

  final uri = Uri.parse('ws://10.0.2.2/80');
  bool _passwordVisable = false;
  final TextEditingController _userAccountController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final GlobalKey _formkey= GlobalKey<FormState>();
  Future<Uint8List> readAsset() async
  {
    var data = await rootBundle.load('images/profileImage.png');
    Uint8List result = data.buffer.asUint8List();
    return result;
  }
  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      future: readAsset(),
      builder:(context,snapshot)
      {
        UserData _userdata = UserData('','','','','',snapshot.data!);
        return Scaffold(
          appBar: AppBar(
            title: Text('登录页'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(builder: (BuildContext context){
                  return Form(
                    key: _formkey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _userAccountController,
                          decoration: InputDecoration(
                            labelText: '账号',
                            icon: Icon(Icons.person),
                            hintText: '账号由大小写字母和数字组成'
                          ),
                          validator: (v)
                          {
                            return v!.trim().isNotEmpty?null:'用户名不能为空';
                          },
                        ),
                        TextFormField(
                          controller: _userPasswordController,
                          decoration: InputDecoration(
                            labelText: '密码',
                            hintText: '密码由不少于6位的大小写字母数字组成',
                            icon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: _passwordVisable?Icon(Icons.visibility):Icon(Icons.visibility_off),
                              onPressed: (){
                                setState(() {
                                  _passwordVisable = !_passwordVisable;
                                });
                              }
                            ),
                          ),
                          obscureText: _passwordVisable?true:false,
                          validator: (v){
                            return v!.trim().length>5?null:'密码不能小于6位';
                          },
                        )
                      ],
                    ),
                  );
                }),
                ElevatedButton.icon(
                    onPressed: (){
                      if((_formkey.currentState as FormState).validate()){
                        var channel = WebSocketChannel.connect(uri);
                        channel.sink.add(json.encode({'userAccount': _userAccountController.text, 'userPassword': _userPasswordController.text, 'state': '登录'}));
                        channel.stream.listen((event) {
                          if(json.decode(event)['state'] == '成功登录返回') {
                            var data = json.decode(event);
                            data['profileImage'] = _userdata._profileImage;
                            _userdata._userAccount=data['userAccount'];
                            _userdata._userName=data['userName'];
                            _userdata._userPassWord=data['userPassword'];
                            _userdata._profileImage=data['profileImage'];
                            _userdata._userAddress=data['userAddress'];
                            _userdata._userRealName=data['userRealName'];
                            _userdata._userTelephone=data['userTelephone'];
                            channel.sink.close();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context){
                              return ProfilePage(userdata: _userdata);
                              },
                              settings: RouteSettings(
                                name: '/ProfilePage'
                              ),
                            ));
                          }
                         });
                      }
                    },
                    icon: Icon(Icons.navigate_next),
                    label: Text('登录'),
                ),
                TextButton(
                    onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context){
                        return RegisterPage();
                      }));
                    },
                    child: Text(
                      '注册',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class RegisterPage extends StatefulWidget
{
    RegisterPage({Key? key}):super(key: key);
    @override
    RegisterPageState createState()=>RegisterPageState();
}
class RegisterPageState extends State<RegisterPage>
{
  final uri = Uri.parse('ws://10.0.2.2/80');
  //【自己提醒自己用】注册页需要用户填写的内容：账号，密码，用户名，头像 / 真实姓名，地址，电话号码
  bool _passwordVisible = false;
  final TextEditingController _userAccountController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userRealNameController = TextEditingController();
  final TextEditingController _userAddressController = TextEditingController();
  final TextEditingController _userTelephoneController = TextEditingController();
  final GlobalKey _form7key = GlobalKey<FormState>();
  @override
  void initState()
  {
    super.initState();
    _userAccountController.text = ' ';
    _userNameController.text = ' ';
    _userRealNameController.text = ' ';
    _userAddressController.text = ' ';
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '注册页'
        ),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top:20,
              width: 350,
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _form7key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '账号信息'
                    ),
                    TextFormField(
                      controller: _userAccountController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: '账号',
                        hintText: '由大小写英文字母和数字组成',
                      ),
                      validator: (v){
                        //这里后面写一些敏感账号检查相关的内容
                        return v==' '?'账号不能为空':null;
                      },
                    ),
                    TextFormField(
                      controller: _userPasswordController,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '由不小于六位的大小写字母和数字组成',
                        icon:Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: _passwordVisible?Icon(Icons.visibility):Icon(Icons.visibility_off),
                          onPressed: (){
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (v){
                        return v!.trim().length<6?'密码不能小于六位':null;
                      },
                    ),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: '用户名',
                        hintText: '由字母和数字组成',
                      ),
                      validator: (v){
                        //后面写敏感词检查等代码
                        return v==' '?'用户名不能为空':null;
                      },
                    ),
                    Text(
                      '个人信息'
                    ),
                    TextFormField(
                      controller: _userRealNameController,
                      decoration: InputDecoration(
                        labelText: '真实姓名',
                        hintText: '暂时只能使用你的姓名的拼音',
                      ),
                      validator: (v){
                        //这里未来加入敏感词检测
                        return v==' '?'真实姓名不能为空':null;
                      },
                    ),
                    TextFormField(
                      controller: _userAddressController,
                      decoration: InputDecoration(
                        labelText: '地址',
                        hintText: '暂时只能使用英文名',
                      ),
                      validator: (v){
                        //未来加入敏感地点检测有关的代码
                        return v==' '?'地址不能为空':null;
                      },
                    ),
                    TextFormField(
                      controller: _userTelephoneController,
                      decoration: InputDecoration(
                        labelText: '联系人电话号码',
                        prefixText: '+86',
                        icon: Icon(Icons.phone),
                      ),
                      validator: (v){
                        return v!.trim().length!=11?'请输入正确的电话号码':null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 550,
              width: 150,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.keyboard_arrow_left),
                label: Text(
                  '完成注册'
                ),
                onPressed: (){
                  var channel = WebSocketChannel.connect(uri);
                  channel.sink.add(json.encode({'userAccount': _userAccountController.text,'userPassword': _userPasswordController.text,'userName': _userNameController.text,'userRealName': _userRealNameController.text, 'userAddress': _userAddressController.text, 'userTelephone': _userTelephoneController.text, 'state': '用户请求注册'}));
                  channel.stream.listen((event) {
                    if(json.decode(event)['state']=='注册成功'){
                      channel.sink.close;
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class UserData//用于存储用户账号和个人信息的类
{
  //所有属性必须保护起来
  late String _userAccount;//账号
  late String _userPassWord;//密码
  late String _userName;//用户名
  late Uint8List _profileImage;//头像
  late String _userAddress;//地址
  late String _userRealName;//真实姓名
  late String _userTelephone;//联系方式
  UserData(this._userAccount,this._userPassWord,this._userName,this._userAddress,this._userTelephone,this._profileImage);//构造函数，用于收到信息后的赋值
  void addressAndTelChange(String address,String tel,String realname)//修改地址和联系人信息
  {
    _userAddress = address;
    _userTelephone = tel;
    _userRealName = realname;
  }
  void profileImageChange(Uint8List newProfileImage)//修改头像
  {
    _profileImage = newProfileImage;
  }
  void passwordChange(String newPassword)//修改密码
  {
    _userPassWord = newPassword;
  }
}
class PageFramework extends StatefulWidget
{
  UserData userdata;
  PageFramework({Key? key,required this.userdata}):super(key: key);
  @override
  PageFrameworkState createState()=>PageFrameworkState(userdata: userdata);
}
class PageFrameworkState extends State<PageFramework>
{
  int _navigatorBarCurrentIndex = 0;
  final appbarTitleList = ['个人中心','主页','消息页'];
  UserData userdata;
  PageFrameworkState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appbarTitleList[_navigatorBarCurrentIndex],
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _navigatorBarCurrentIndex,
        onTap: (i) => setState(() => _navigatorBarCurrentIndex = i),
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text(
                '个人中心',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              selectedColor: Colors.redAccent
          ),
          SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text(
                '主页',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              selectedColor: Colors.orange
          ),
          SalomonBottomBarItem(
              icon: Icon(Icons.message),
              title: Text(
                '消息',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              selectedColor: Colors.amber
          ),
        ],
      ),
    );
  }
}
class ProfilePage extends StatefulWidget
{
  ProfilePage({Key? key,required this.userdata}):super(key: key);
  UserData userdata;
  @override
  ProfilePageState createState()=>ProfilePageState(userdata:userdata);

}
class ProfilePageState extends State<ProfilePage>
{
  final uri = Uri.parse('ws://10.0.2.2/80');
  late CroppedFile? croppedImage;
  late File _userImage;
  final ImageCropper cropper = new ImageCropper();
  final ImagePicker picker = new ImagePicker();
  var _navigatorBarCurrentIndex = 0;
  ProfilePageState({Key? key, required this.userdata});
  UserData userdata;
  noticeDialog1(){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('我们遇到了一点点问题'),
          content: const Text('拍摄失败或者某些地方出现了问题，请联系技术人员'),
          actions: [
            TextButton(
              child: Text('确认'),
              onPressed: ()
              {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  noticeDialog2(){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('我们遇到了一点点问题'),
          content: const Text('从相册选取图片失败或者某些地方出现了问题，请联系技术人员'),
          actions: [
            TextButton(
              child: Text('确认'),
              onPressed: ()
              {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  camaraOrGalleryDialog()
  {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('更换头像'),
          content: const Text('请选择拍摄照片或从相册选取'),
          actions: [
            TextButton(
              child: Text(
                  '拍摄照片'
              ),
              onPressed: () async {
                //这里写image_picker有关拍摄照片的方法
                Navigator.pop(context);
                final camaraImage = await picker.pickImage(source: ImageSource.camera);
                if(camaraImage != null)
                {
                    croppedImage = await cropper.cropImage(
                    sourcePath: camaraImage.path,
                    maxWidth: 250,
                    maxHeight: 250,
                  );
                }
                else
                {
                  noticeDialog1();
                }
                setState(() {
                  _userImage = File(croppedImage!.path);
                  var channel = WebSocketChannel.connect(uri);
                  channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userNewProfileImage': _userImage.readAsBytesSync(), 'state': '用户修改头像'}));
                  channel.stream.listen((event) {
                    if(json.decode(event)['state']=='成功修改用户头像')
                    {
                        userdata._profileImage = _userImage.readAsBytesSync();
                    }
                  });
                  channel.sink.close();

                });

              },
            ),
            TextButton(
              child: Text(
                '从相册选取',
              ),
              onPressed: () async{
                //这里写image_picker有关选取照片的方法
                Navigator.pop(context);
                final galleryImage = await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  if(galleryImage != null)
                  {
                    _userImage = File(galleryImage.path);
                    userdata._profileImage = _userImage.readAsBytesSync();
                  }
                  else
                  {
                    noticeDialog2();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context)
  {
      return Scaffold(
        appBar: AppBar(
          title: Text('个人中心'),
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child:
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 3,
                      child: Container(
                        width: 405,
                        height: 100,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 3,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            style: BorderStyle.none,
                          ),
                          color: Colors.white,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned(
                                top: 2,
                                width: 96,
                                height: 96,
                                left: 5,
                                child: CircularProfileAvatar(
                                  '',
                                  child: Image(
                                    image: MemoryImage(userdata._profileImage),),
                                  borderWidth: 2,
                                  onTap: () {
                                    print('用户刚刚点击了头像');
                                    camaraOrGalleryDialog();
                                  },
                                  radius: 48,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                width: 100,
                                height: 25,
                                left: 106,
                                child: Text(
                                  userdata._userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                width: 299,
                                height: 50,
                                left: 106,
                                child: Text(
                                  userdata._userAddress,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 10,
                                child: TextButton(
                                  child: Text(
                                    '设置',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  onPressed: () async {
                                    var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return SettingHomePage(userdata: userdata);
                                        })
                                    );
                                    setState(() {
                                      userdata._userName = result._userName;
                                      userdata._userRealName = result._userRealName;
                                      userdata._userTelephone = result._userTelephone;
                                      userdata._userAddress = result._userAddress;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //这里写个人中心中放功能的container
                    Positioned(
                      top: 108,
                      child: Container(
                        width: 405,
                        height: 135,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.none,
                            ),
                            color: Colors.white
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned(
                                top: 5,
                                left: 5,
                                width: 70,
                                height: 25,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  child: Text(
                                    '订单信息',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                left: 5,
                                width: 90,
                                height: 90,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.loop),
                                  label: Text(
                                    '正在进行的',
                                    style: TextStyle(
                                        color: Colors.black
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return OngoingOrderPage(userdata: userdata);
                                        }));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white),
                                    shape: MaterialStateProperty.all(
                                      ContinuousRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.grey),
                                    iconSize: MaterialStateProperty.all(20),
                                    iconColor: MaterialStateProperty.all(
                                        Colors.black),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                left: 110,
                                width: 90,
                                height: 90,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.summarize),
                                  label: Text(
                                    '用户废品收入统计',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return UserOrderStatisticsPage(
                                              userdata: userdata);
                                        }));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white),
                                    shape: MaterialStateProperty.all(
                                      ContinuousRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.grey),
                                    iconSize: MaterialStateProperty.all(20),
                                    iconColor: MaterialStateProperty.all(
                                        Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //写第三个功能区域
                    Positioned(
                      top: 250,
                      child: Container(
                        width: 405,
                        height: 250,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              style: BorderStyle.none,
                            ),
                            color: Colors.white
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned(
                                top: 5,
                                left: 5,
                                width: 70,
                                height: 25,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  child: Text(
                                    '其他功能',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                left: 5,
                                width: 90,
                                height: 90,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.perm_contact_cal),
                                  label: Text(
                                    '个人画像查看',
                                    style: TextStyle(
                                        color: Colors.black
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return UserPersonalImagePage(
                                              userdata: userdata);
                                        }));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white),
                                    shape: MaterialStateProperty.all(
                                      ContinuousRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.grey),
                                    iconSize: MaterialStateProperty.all(20),
                                    iconColor: MaterialStateProperty.all(
                                        Colors.black),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                left: 110,
                                width: 90,
                                height: 90,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.person_add_alt),
                                  label: Text(
                                    '我要成为个体户',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return ApplicationPage1(userdata: userdata);
                                        }));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white),
                                    shape: MaterialStateProperty.all(
                                      ContinuousRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.grey),
                                    iconSize: MaterialStateProperty.all(20),
                                    iconColor: MaterialStateProperty.all(
                                        Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


          ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _navigatorBarCurrentIndex,
          onTap: (i) => setState(() => _navigatorBarCurrentIndex = i),
          items: [
            SalomonBottomBarItem(
                icon: Icon(Icons.person),
                title: Text(
                  '个人中心',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                selectedColor: Colors.redAccent
            ),
            SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text(
                  '主页',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                selectedColor: Colors.orange
            ),
            SalomonBottomBarItem(
                icon: Icon(Icons.message),
                title: Text(
                  '消息',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selectedColor: Colors.amber
            ),
          ],
        ),
      );
    }

}
class SettingHomePage extends StatefulWidget
{
  UserData userdata;
  SettingHomePage({Key? key,required this.userdata}):super(key: key);
  @override
  SettingHomePageState createState()=>SettingHomePageState(userdata: userdata);

}
class SettingHomePageState extends State<SettingHomePage>
{
  UserData userdata;
  SettingHomePageState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设置'
        ),
        leading: Icon(Icons.settings),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top:150,
                width: 300,
                height: 40,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.lock),
                  label: Text(
                    '密保修改',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return SettingPasswordPage(userdata: userdata);
                    }));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top:205,
                width: 300,
                height: 40,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.person),
                  label: Text(
                    '昵称修改',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () async{
                    var result = await Navigator.push(context,MaterialPageRoute(builder: (context){
                      return SettingUserNamePage(userdata: userdata);
                    }));
                    userdata._userName = await result._userName;
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top:260,
                width: 300,
                height: 40,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.home),
                  label: Text(
                    '地址/联系方式修改',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () async{
                    var result = await Navigator.push(context,MaterialPageRoute(builder: (context){
                      return SettingUserContactInfoAndAddressPage(userdata: userdata);
                    }));
                    userdata._userRealName = result._userRealName;
                    userdata._userTelephone = result._userTelephone;
                    userdata._userAddress = result._userAddress;
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 350,
                width: 150,
                height:50,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.keyboard_arrow_left),
                  label: Text(
                    '退出',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style:  ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: (){
                    Navigator.pop(context,userdata);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SettingPasswordPage extends StatefulWidget
{
  UserData userdata;
  SettingPasswordPage({Key? key,required this.userdata}):super(key: key);
  @override
  SettingPasswordPageState createState()=>SettingPasswordPageState(userdata: userdata);
}
class SettingPasswordPageState extends State<SettingPasswordPage>
{
  final uri = Uri.parse('ws://10.0.2.2/80');
  final TextEditingController _userOldPasswordController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final GlobalKey _form2key = GlobalKey<FormState>();
  UserData userdata;
  SettingPasswordPageState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '密保设置',
        ),
        leading: Icon(Icons.lock),
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 185,
                width: 350,
                child:Form(
                  key: _form2key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userOldPasswordController,
                        decoration: InputDecoration(
                          labelText: '请重新输入一遍旧密码',
                          hintText: '请输入六位以上字母/数字组合',
                          icon: Icon(Icons.lock),
                        ),
                        validator: (v){
                          return v!.trim()==userdata._userPassWord?null:'用户输入与旧密码不符';
                        },
                      ),
                      TextFormField(
                        controller: _userPasswordController,
                        decoration: InputDecoration(
                          labelText: '新密码',
                          hintText: '请输入六位以上字母/数字组合',
                          icon: Icon(Icons.lock),
                        ),
                        validator: (v){
                          return v!.trim().length>5?null:'密码不能小于6位';
                        },
                      )
                    ],
                  ),
                  ),
                ),

              Positioned(
                top:350,
                left: 48.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '提交',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(Icons.arrow_left),
                  onPressed: (){
                    if((_form2key.currentState as FormState).validate())
                      {
                        var channel = WebSocketChannel.connect(uri);
                        channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userNewPassword': _userPasswordController.text, 'state': '用户修改密码'}));
                        channel.stream.listen((event) {
                          if(json.decode(event)['state']=='成功修改密码返回')
                            {
                              //最好加个弹窗提示用户修改完成
                              channel.sink.close();
                              Navigator.pop(context);
                            }
                        });
                      }
                  },
                  style:ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      iconSize:MaterialStateProperty.all(20),
                      iconColor: MaterialStateProperty.all(Colors.black),
                ),
              ),
              ),
              Positioned(
                top:350,
                left: 213.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '退出',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                    ),
                  ),
                  icon: Icon(Icons.arrow_left),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style:ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      iconSize:MaterialStateProperty.all(20),
                      iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SettingUserNamePage extends StatefulWidget
{
  UserData userdata;
  SettingUserNamePage({Key? key,required this.userdata}):super(key: key);
  @override
  SettingUserNamePageState createState()=>SettingUserNamePageState(userdata: userdata);
}
class SettingUserNamePageState extends State<SettingUserNamePage>
{
  final uri = Uri.parse('ws://10.0.2.2/80');
  final TextEditingController _userNameController = TextEditingController();
  GlobalKey _form3key = GlobalKey<FormState>();
  UserData userdata;
  SettingUserNamePageState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
   return Scaffold(
     appBar: AppBar(
       leading: Icon(Icons.settings),
       title: Text(
         '修改昵称'
       ),
     ),
     body: WillPopScope(
       onWillPop: () async{
         return false;
       },
       child: ConstrainedBox(
         constraints: BoxConstraints.expand(),
         child: Stack(
           alignment: Alignment.center,
           children: [
             Positioned(
               top: 200,
               width: 100,
               height: 20,
               child: Text(
                 '旧昵称'+ userdata._userName,
                 style: TextStyle(
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ),
             Positioned(
               top:235,
               width: 350,
               child: Form(
                 key: _form3key,
                 autovalidateMode: AutovalidateMode.onUserInteraction,
                 child: TextFormField(
                   controller: _userNameController,
                   decoration: InputDecoration(
                     labelText: '请输入新的昵称',
                     hintText: '昵称由字母和数字组成,不能有空格和特殊字符',
                     icon: Icon(Icons.person),
                   ),
                   validator: (v){
                     //这里后面要写判断是否有空格和特殊字符的代码
                   },
                 ),
               ),
             ),
             Positioned(
               top:335,
               left: 48.5,
               width: 150,
               height: 50,
               child: ElevatedButton.icon(
                 icon: Icon(Icons.keyboard_arrow_left),
                 label: Text(
                   '提交',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
                 onPressed: (){
                   if((_form3key.currentState as FormState).validate()){
                     var channel = WebSocketChannel.connect(uri);
                     channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userNewName': _userNameController.text, 'state': '用户修改昵称'}));
                     channel.stream.listen((event) {
                       if(json.decode(event)['state'] == '成功修改昵称返回')
                         {
                           channel.sink.close();
                           userdata._userName=_userNameController.text;
                           Navigator.pop(context,userdata);
                         }
                     });
                   }
                 },
                 style:ButtonStyle(
                   backgroundColor: MaterialStateProperty.all(Colors.white),
                   shape: MaterialStateProperty.all(
                     ContinuousRectangleBorder(
                       side: BorderSide.none,
                       borderRadius: BorderRadius.circular(5),
                     ),
                   ),
                   overlayColor: MaterialStateProperty.all(Colors.grey),
                   iconSize:MaterialStateProperty.all(20),
                   iconColor: MaterialStateProperty.all(Colors.black),
                 ),
               ),
             ),
             Positioned(
               top:335,
               left: 213.5,
               width: 150,
               height: 50,
               child: ElevatedButton.icon(
                 label: Text(
                   '退出',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
                 icon: Icon(Icons.arrow_left),
                 onPressed: (){
                   Navigator.pop(context);
                 },
                 style:ButtonStyle(
                   backgroundColor: MaterialStateProperty.all(Colors.white),
                   shape: MaterialStateProperty.all(
                     ContinuousRectangleBorder(
                       side: BorderSide.none,
                       borderRadius: BorderRadius.circular(5),
                     ),
                   ),
                   overlayColor: MaterialStateProperty.all(Colors.grey),
                   iconSize:MaterialStateProperty.all(20),
                   iconColor: MaterialStateProperty.all(Colors.black),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   ); 
  }
}
class SettingUserContactInfoAndAddressPage extends StatefulWidget
{
  UserData userdata;
  SettingUserContactInfoAndAddressPage({Key? key,required this.userdata}):super(key: key);
  @override
  SettingUserContactInfoAndAddressPageState createState()=>SettingUserContactInfoAndAddressPageState(userdata: userdata);
}
class SettingUserContactInfoAndAddressPageState extends State<SettingUserContactInfoAndAddressPage>
{
  final uri = Uri.parse('ws://10.0.2.2/80');
  final GlobalKey _form4key = GlobalKey<FormState>();
  final TextEditingController _userRealNameController = TextEditingController();
  final TextEditingController _userTelephoneController = TextEditingController();
  final TextEditingController _userAddressController = TextEditingController();
  UserData userdata;
  SettingUserContactInfoAndAddressPageState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.settings),
        title: Text(
          '修改联系方式和地址信息'
        ),
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 100,
                width: 350,
                child: Form(
                  key: _form4key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userRealNameController,
                        decoration: InputDecoration(
                          labelText: '联系人真实姓名',
                          hintText: '请输入联系人的真实姓名',
                          icon: Icon(Icons.person),
                        ),
                        validator: (v){
                          //这里可以放敏感姓名检测函数
                        },
                      ),
                      TextFormField(
                        controller: _userTelephoneController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.phone),
                          prefixText: '+86',
                          labelText: '联系人电话号码',
                          hintText: '请输入中国境内电话号码',
                        ),
                        validator: (v){
                          //这里放检测是否全为数字的代码
                        },
                      ),
                      TextFormField(
                        controller: _userAddressController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.home),
                          labelText: '联系人家庭地址',
                          hintText: '例：辽宁省大连市甘井子区凌工路2号',
                        ),
                        validator:(v){
                          //这里检测地址是否合法的代码
                        },
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 48.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.keyboard_arrow_left),
                  label: Text(
                    '提交',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: (){
                    var channel = WebSocketChannel.connect(uri);
                    channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userNewRealName': _userRealNameController.text, 'userNewTelephone': _userTelephoneController.text, 'userNewAddress': _userAddressController.text, 'state': '用户修改联系方式与地址'}));
                    channel.stream.listen((event) {
                      if(json.decode(event)['state'] == '成功修改联系方式与地址')
                        {
                          channel.sink.close();
                          userdata._userRealName = _userRealNameController.text;
                          userdata._userTelephone = _userTelephoneController.text;
                          userdata._userAddress = _userAddressController.text;
                          Navigator.pop(context,userdata);
                        }
                    });
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top:400,
                left: 213.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '退出',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(Icons.arrow_left),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class UserPersonalImagePage extends StatefulWidget
{
  UserData userdata;
  UserPersonalImagePage({Key? key,required this.userdata}):super(key: key);
  @override
  UserPersonalImagePageState createState()=>UserPersonalImagePageState(userdata: userdata);
}
class UserPersonalImagePageState extends State<UserPersonalImagePage>
{
  UserData userdata;
  UserPersonalImagePageState({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
   return Scaffold(
     appBar: AppBar(
       leading: Icon(Icons.person),
       title: Text(
         '用户个人画像查看',
       ),
     ),
     body: WillPopScope(
       onWillPop: () async{
         return false;
       },
       child:ConstrainedBox(
         constraints: BoxConstraints.expand(),
         child: Stack(
           alignment: Alignment.center,
           children: [
             //这里第一个Positioned放后面从服务器获得的图片（大概由matplotlib生成）
             Positioned(
               top: 400,
               width: 150,
               height: 50,
               child: ElevatedButton.icon(
                 icon: Icon(Icons.keyboard_arrow_left),
                 label: Text(
                   '退出',
                   style: TextStyle(
                     color: Colors.black,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 onPressed: (){
                   Navigator.pop(context);
                 },
                 style:ButtonStyle(
                   backgroundColor: MaterialStateProperty.all(Colors.white),
                   shape: MaterialStateProperty.all(
                     ContinuousRectangleBorder(
                       side: BorderSide.none,
                       borderRadius: BorderRadius.circular(5),
                     ),
                   ),
                   overlayColor: MaterialStateProperty.all(Colors.grey),
                   iconSize:MaterialStateProperty.all(20),
                   iconColor: MaterialStateProperty.all(Colors.black),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
  }
}
class UserApplicationData
{
  late String userRealName;
  late String userIDCode;
  late String userServiceAddress;
}
class ApplicationPage1 extends StatefulWidget
{

  UserData userdata;
  ApplicationPage1({Key? key,required this.userdata}):super(key: key);
  @override
  ApplicationPage1State createState()=>ApplicationPage1State(userdata: userdata);
}
class ApplicationPage1State extends State<ApplicationPage1>
{
  final TextEditingController _userIDCodeController = TextEditingController();
  final TextEditingController _userRealNameController = TextEditingController();
  GlobalKey _form5key = GlobalKey<FormState>();
  UserApplicationData userApplicationData = UserApplicationData();
  UserData userdata;
  ApplicationPage1State({Key? key,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.person_add_alt),
        title: Text(
          '我要申请成为个体户',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 30,
                child: Container(
                  width: 350,
                  height: 135,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 3,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.none,
                      ),
                      color: Colors.white
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                          top: 20,
                          left: 65,
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.filter_1,
                            color: Colors.lightBlueAccent,
                            size:20,
                          ),
                        ),
                        Positioned(
                          top: 45,
                          left:30,
                          width: 90,
                          height: 20,
                          child: Text(
                            '身份信息填写',
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 165,
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.filter_2,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 45,
                          left:130,
                          width: 90,
                          height: 20,
                          child: Text(
                            '服务区域选择',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 265,
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.filter_3,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 45,
                          left:230,
                          width: 90,
                          height: 20,
                          child: Text(
                            '审核',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ),
              Positioned(
                top: 200,
                width: 350,
                child: Form(
                  key: _form5key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userRealNameController,
                        decoration: InputDecoration(
                          labelText: '请输入你的真实姓名',
                          icon: Icon(Icons.person),
                        ),
                        validator: (v){
                          //这里可能放检测敏感名称的代码
                        },
                      ),
                      TextFormField(
                        controller: _userIDCodeController,
                        decoration: InputDecoration(
                          labelText: '请输入你的身份证号码',
                        ),
                        validator: (v){
                          return v!.trim().length == 18?null:'你输入的身份证号码不合法';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 48.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '下一步',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (){
                    if((_form5key.currentState as FormState).validate())
                      {
                        userApplicationData.userRealName = _userRealNameController.text;
                        userApplicationData.userIDCode = _userIDCodeController.text;
                        Navigator.push(context,MaterialPageRoute(builder: (context){
                          return ApplicationPage2(userApplicationData: userApplicationData,userdata: userdata,);
                        }));
                      }
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 213.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '退出',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }
}
class ApplicationPage2 extends StatefulWidget
{
  UserApplicationData userApplicationData;
  UserData userdata;
  ApplicationPage2({Key? key,required this.userApplicationData,required this.userdata}):super(key: key);
  @override
  ApplicationPage2State createState()=>ApplicationPage2State(userApplicationData: userApplicationData,userdata: userdata);
}
class ApplicationPage2State extends State<ApplicationPage2>
{
  UserData userdata;
  final uri = Uri.parse('ws://10.0.2.2/80');
  final TextEditingController _userServiceAddressController = TextEditingController();
  GlobalKey _form6key = GlobalKey<FormState>();
  bool _isUserFinishApplication = false;
  UserApplicationData userApplicationData;
  ApplicationPage2State({Key? key,required this.userApplicationData,required this.userdata});
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.person_add_alt),
        title: Text(
          '我要申请成为个体户',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 30,
                child: Container(
                  width: 350,
                  height: 135,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 3,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.none,
                      ),
                      color: Colors.white
                  ),
                  child: ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned(
                            top: 20,
                            left: 65,
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.filter_1,
                              color: Colors.grey,
                              size:20,
                            ),
                          ),
                          Positioned(
                            top: 45,
                            left:30,
                            width: 90,
                            height: 20,
                            child: Text(
                              '身份信息填写',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 165,
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.filter_2,
                              color: _isUserFinishApplication?Colors.grey:Colors.lightBlueAccent,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            top: 45,
                            left:130,
                            width: 90,
                            height: 20,
                            child: Text(
                              '服务区域选择',
                              style: TextStyle(
                                color: _isUserFinishApplication?Colors.grey:Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 265,
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.filter_3,
                              color: _isUserFinishApplication?Colors.lightBlueAccent:Colors.grey,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            top: 45,
                            left:230,
                            width: 90,
                            height: 20,
                            child: Text(
                              '审核',
                              style: TextStyle(
                                color: _isUserFinishApplication?Colors.lightBlueAccent:Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
              Positioned(
                top: 200,
                width: 350,
                child: Form(
                  key: _form6key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    controller: _userServiceAddressController,
                    decoration: InputDecoration(
                      labelText: '请输入你的服务地址',
                      hintText: '例：辽宁省(省）大连市（市）甘井子区（区）凌工路（路）2号（门牌号）',
                      icon: Icon(Icons.home),
                    ),
                    validator: (v){
                      //这里放一些检验地址真实性的代码
                    },
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 18.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '提交',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (){
                    //先写网络通讯的代码
                    if((_form6key.currentState as FormState).validate())
                      {
                        userApplicationData.userServiceAddress = _userServiceAddressController.text;
                        var channel = WebSocketChannel.connect(uri);
                        channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userRealName': userApplicationData.userRealName, 'userIDCode': userApplicationData.userIDCode, 'userServiceAddress': userApplicationData.userServiceAddress, 'state': '用户申请加入个体户'}));
                        channel.stream.listen((event) {
                          if(json.decode(event)['state'] == '已收到用户申请加入个体户信息')
                            {
                              Navigator.popUntil(context, ModalRoute.withName('/ProfilePage'));
                            }
                        });
                      }
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 213.5,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  label: Text(
                    '退出',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (){
                    Navigator.popUntil(context, ModalRoute.withName('/ProfilePage'));
                  },
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class UserOrderStatisticsPage extends StatefulWidget
{
  UserData userdata;
  UserOrderStatisticsPage({Key? key,required this.userdata}):super(key: key);
  @override
  UserOrderStatisticsPageState createState()=>UserOrderStatisticsPageState(userdata: userdata);
}
class UserOrderStatisticsPageState extends State<UserOrderStatisticsPage>
{
  List result=[];
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final uri = Uri.parse('ws://10.0.2.2/80');
  final List timeTable = [{'title': '全部'},{'title': '2023年', 'children': [{'title': '1月'},{'title': '2月'},{'title': '3月'},{'title': '4月'},{'title': '5月'},{'title': '6月'},{'title': '7月'},{'title': '8月'},{'title': '9月'},{'title': '10月'},{'title': '11月'},{'title': '12月'}]},{'title': '2022年', 'children': [{'title': '1月'},{'title': '2月'},{'title': '3月'},{'title': '4月'},{'title': '5月'},{'title': '6月'},{'title': '7月'},{'title': '8月'},{'title': '9月'},{'title': '10月'},{'title': '11月'},{'title': '12月'}]},{'title': '2021年', 'children': [{'title': '1月'},{'title': '2月'},{'title': '3月'},{'title': '4月'},{'title': '5月'},{'title': '6月'},{'title': '7月'},{'title': '8月'},{'title': '9月'},{'title': '10月'},{'title': '11月'},{'title': '12月'}]},{'title': '2020年', 'children': [{'title': '1月'},{'title': '2月'},{'title': '3月'},{'title': '4月'},{'title': '5月'},{'title': '6月'},{'title': '7月'},{'title': '8月'},{'title': '9月'},{'title': '10月'},{'title': '11月'},{'title': '12月'}]},{'title': '2019年', 'children': [{'title': '1月'},{'title': '2月'},{'title': '3月'},{'title': '4月'},{'title': '5月'},{'title': '6月'},{'title': '7月'},{'title': '8月'},{'title': '9月'},{'title': '10月'},{'title': '11月'},{'title': '12月'}]}];
  UserData userdata;
  UserOrderStatisticsPageState({Key? key,required this.userdata});
  YearLabel? selectedYear;
  MonthLabel? selectedMonth;

  @override
  Widget build(BuildContext context)
  {
    List<DropdownMenuEntry<MonthLabel>> monthEntries = <DropdownMenuEntry<MonthLabel>>[];
    List<DropdownMenuEntry<YearLabel>> yearEntries = <DropdownMenuEntry<YearLabel>>[];
    for(final YearLabel year in YearLabel.values)
      {
        yearEntries.add(
          DropdownMenuEntry(value: year, label: year.year),
        );
      }
    for(final MonthLabel month in MonthLabel.values)
      {
        monthEntries.add(
          DropdownMenuEntry(value: month, label: month.month),
        );
      }
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.summarize),
        title: Text(
          '用户废品收入统计'
        ),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                top:30,
                left:3.5,
                width: 150,
                child: DropdownMenu(
                  initialSelection: YearLabel.yrinit,//这个参数指的是还没有选择的时候显示在上面的选项
                  controller: _yearController,//就是一个文本框controller，使其支持文本输入
                  label: const Text(
                    '年份',
                  ),//就是显示在菜单上面用于标记菜单功能的
                  dropdownMenuEntries: yearEntries,//一个dropdownMenuEntry类型列表
                  onSelected: (YearLabel? year){
                    setState(() {
                      selectedYear = year;
                      print('selectedYear changed to'+selectedYear!.year);
                    });
                  },
                ),//这里使用DropdownMenu就行后面显示数据的部分要用一个FutureBuilder之类的组件
            ),
            Positioned(
              top: 30,
              left: 213.5,
              width: 150,
              child: DropdownMenu(
                initialSelection: MonthLabel.init,
                controller: _monthController,
                label: const Text(
                  '月份',
                ),
                dropdownMenuEntries: monthEntries,
                onSelected: (MonthLabel? month){
                  setState(() {
                    selectedMonth = month;
                    print('selectedMonth changed to'+selectedMonth!.month);
                  });
                },
              ),
            ),
            Positioned(
              top: 400,
              width: 150,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.keyboard_arrow_left),
                label: Text(
                  '退出',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                },
                style:ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    ContinuousRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.grey),
                  iconSize:MaterialStateProperty.all(20),
                  iconColor: MaterialStateProperty.all(Colors.black),
                ),
              ),
            ),
             Positioned(
                top: 200,
                child: Builder(

                  builder: (context){
                    if(selectedYear?.year != null && selectedMonth?.month != null)
                      {

                          var channel = WebSocketChannel.connect(uri);
                          channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'userSelectedYear': selectedYear?.year, 'userSelectedMonth': selectedMonth?.month, 'state': '用户请求历史订单数据'}));
                          channel.stream.listen((event) {
                          if(json.decode(event)['state']=='成功返回用户历史数据')
                          {
                            result = json.decode(event)['list'];
                            print(result);
                          }
                          });
                          channel.sink.close();
                          return Container(
                            child: Column(
                              children: result.map(
                                      (order) =>
                                      Container(
                                        alignment: Alignment.center,
                                        width: 300,
                                        height: 50,
                                        child: Text(
                                          order,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black,
                                                blurRadius: 3
                                            ),
                                          ],
                                        ),
                                      )
                              ).toList(),
                            ),
                          );
                         }
                          else
                          {
                            return Container(
                              width: 400,
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                '暂无数据',
                              ),
                            );
                          }
                      }
                    ),




                ),


          ],
        ),
      ),
    );
  }
}
class OngoingOrderPage extends StatefulWidget
{
  UserData userdata;
  OngoingOrderPage({Key? key,required this.userdata}):super(key: key);
  @override
  OngoingOrderPageState createState()=>OngoingOrderPageState(userdata: userdata);
}
class OngoingOrderPageState extends State<OngoingOrderPage>
{
  bool userHasOngoingOrder = false;
  final uri = Uri.parse('ws://10.0.2.2/80');
  UserData userdata;
  OngoingOrderPageState({Key? key,required this.userdata});
  var message;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.loop),
        title: Text(
          '正在进行的订单',
        ),
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              //第一个positioned大概要放表单什么东西
              Positioned(
                top: 30,
                width: 400,
                height: 150,
                child:Builder(
                  builder: (context){
                  var channel = WebSocketChannel.connect(uri);
                  channel.sink.add(json.encode({'userAccount': userdata._userAccount, 'state': '用户请求正在进行的订单数据'}));
                  channel.stream.listen((event) {
                  if(json.decode(event)['state']=='成功返回正在进行的订单数据')
                  {
                    setState(() {
                       userHasOngoingOrder = true;
                       message = json.decode(event);
                       channel.sink.close();
                    });

                  }
                    if(json.decode(event)['state']=='该用户没有正在进行的订单')
                    {
                      setState(() {
                        userHasOngoingOrder = false;
                        channel.sink.close();
                      });

                    }

                });
                    if(userHasOngoingOrder){
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 3,
                            )
                          ],
                          ),

                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned(
                                top: 30,
                                left: 20,
                                width: 20,
                                height: 20,
                                child: Icon(
                                  Icons.loop,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Positioned(
                                top: 30,
                                left: 50,
                                width: 80,
                                height: 20,
                                child: Text(
                                  '正在进行中',
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 50,
                                width: 200,
                                height: 20,
                                child: Text(
                                  '订单时间:' + message['time'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 80,
                                right: 5,
                                width: 200,
                                height: 20,
                                child: Text(
                                  '上门回收人员:' + message['servicePersonName'],
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 110,
                                right: 215,
                                width: 20,
                                height: 20,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Positioned(
                                top: 110,
                                right: 5,
                                width: 200,
                                height: 20,
                                child: Text(
                                  '联系电话:' + message['servicePersonTelephone'],
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    else
                      {
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                              '您暂时没有正在进行中的订单',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                  },
                ),
              ),
              Positioned(
                top: 400,
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.keyboard_arrow_left),
                    label: Text(
                      '退出',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    iconSize:MaterialStateProperty.all(20),
                    iconColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
enum YearLabel
{
  yrinit('请选择一个年份'),
  yr2023('2023年'),
  yr2022('2022年'),
  yr2021('2021年'),
  yr2020('2020年'),
  yr2019('2019年');
  const YearLabel(this.year);
  final String year;
}
enum MonthLabel
{
  init('请选择一个月份'),
  jan('一月'),
  feb('二月'),
  mar('三月'),
  apr('四月'),
  may('五月'),
  jun('六月'),
  jul('七月'),
  aug('八月'),
  sep('九月'),
  oct('十月'),
  nov('十一月'),
  dec('十二月');
  const MonthLabel(this.month);
  final String month;
}