import 'package:firebase_core/firebase_core.dart';
import 'package:truple_practice/pages/signup.dart';
import 'package:flutter/material.dart';

//google api key = AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 이 위젯은 애플리케이션의 루트입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 이곳은 애플리케이션의 테마입니다.
          //
          // TRY THIS: "flutter run"으로 애플리케이션을 실행해 보세요. 그러면
          // 애플리케이션이 파란색 툴바를 가지고 있음을 볼 수 있습니다. 그런 다음,
          // 앱을 종료하지 않고, 아래 색상 체계에서 seedColor를 Colors.green으로
          // 변경한 후 "hot reload"를 실행해 보세요 (변경 사항을 저장하거나
          // Flutter를 지원하는 IDE의 "hot reload" 버튼을 누르거나,
          // 명령줄에서 앱을 시작했다면 "r"을 누르세요).
          //
          // 카운터가 0으로 초기화되지 않았다는 것을 주목하세요; 애플리케이션의
          // 상태는 reload 중에 손실되지 않습니다. 상태를 초기화하려면 hot restart를
          // 사용하세요.
          //
          // 이 방법은 값뿐만 아니라 코드에도 적용됩니다: 대부분의 코드 변경은
          // 단순히 hot reload로 테스트할 수 있습니다.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SignUp());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 이 위젯은 애플리케이션의 홈 페이지입니다. 이는 stateful이며, State 객체를
  // (아래 정의됨) 가지고 있어 외관에 영향을 미치는 필드를 포함하고 있습니다.

  // 이 클래스는 상태의 구성입니다. 이는 부모(이 경우 App 위젯)로부터 제공된
  // 값(이 경우 제목)을 보유하며, State의 build 메소드에서 사용됩니다.
  // 위젯 서브클래스의 필드는 항상 "final"로 표시됩니다.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 이 setState 호출은 Flutter 프레임워크에 이 State에서 무언가가 변경되었다고
      // 알려주며, 이는 아래의 build 메소드를 다시 실행하여 디스플레이가 업데이트된
      // 값을 반영할 수 있도록 합니다. setState()를 호출하지 않고 _counter를 변경하면,
      // build 메소드는 다시 호출되지 않으며 아무 일도 일어나지 않는 것처럼 보일 것입니다.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이 메소드는 setState가 호출될 때마다 다시 실행됩니다. 예를 들어 위의
    // _incrementCounter 메소드에 의해 호출됩니다.
    //
    // Flutter 프레임워크는 build 메소드가 빠르게 다시 실행될 수 있도록 최적화되어
    // 있으므로, 개별 위젯 인스턴스를 변경하는 대신 업데이트가 필요한 모든 것을
    // 단순히 다시 구축할 수 있습니다.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: 여기의 색상을 특정 색상(예: Colors.amber)으로 변경하고
        // hot reload를 트리거하여 AppBar의 색상이 다른 색상은 그대로인 채로
        // 변경되는 것을 확인하세요.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 여기서 우리는 App.build 메소드에 의해 생성된 MyHomePage 객체의 값을
        // 가져와 appbar 제목을 설정하는 데 사용합니다.
        title: Text(widget.title),
      ),
      body: Center(
        // Center는 레이아웃 위젯입니다. 이는 단일 자식을 가져와 부모의 중앙에
        // 위치시킵니다.
        child: Column(
          // Column 또한 레이아웃 위젯입니다. 이는 자식 목록을 가져와 수직으로
          // 배열합니다. 기본적으로 자식들이 수평으로 맞도록 크기를 조정하고,
          // 가능한 한 부모만큼 높으려고 합니다.
          //
          // Column은 크기를 조정하는 방법과 자식을 배치하는 방법을 제어하는
          // 다양한 속성을 가지고 있습니다. 여기서는 mainAxisAlignment를 사용하여
          // 자식을 수직으로 중앙에 배치합니다; 여기서 main axis는 수직 축이며,
          // Column은 수직이기 때문입니다 (cross axis는 수평이 될 것입니다).
          //
          // TRY THIS: "debug painting"을 호출하세요 (IDE에서 "Toggle Debug Paint"
          // 작업을 선택하거나, 콘솔에서 "p"를 누르세요), 각 위젯의 와이어프레임을
          // 확인할 수 있습니다.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 이 끝에 있는 쉼표는 build 메소드의 자동 포맷팅을 더 깔끔하게 만듭니다.
    );
  }
}
