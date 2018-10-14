import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './actionsButton.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TasksModel m = new TasksModel();
  m.loadFromDb();
  return runApp(new MyApp(
    modal: m,
  ));
}

class Task {
  String _task;

  String get task => _task;

  set task(String task) {
    _task = task;
  }

  DateTime _createdAt;

  DateTime get createdAt => _createdAt;

  set createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  DateTime _finishedAt;

  DateTime get finishedAt => _finishedAt;

  set finishedAt(DateTime finishedAt) {
    _finishedAt = finishedAt;
  }

  bool _isFinshed = false;

  bool get isFinshed => _isFinshed;

  set isFinshed(bool isFinshed) {
    _isFinshed = isFinshed;
  }

  void toggleIsFinshed() {
    _isFinshed = !_isFinshed;
    if (_isFinshed) {
      _finishedAt = DateTime.now();
    }
  }

  Task(t) {
    _task = t;
    _createdAt = DateTime.now();
  }
  Task.fromJson(Map<String, dynamic> json)
      : _task = json['_task'],
        _createdAt = DateTime.parse(json['_createdAt']),
        _finishedAt = json['_finishedAt'] != null
            ? DateTime.parse(json['_finishedAt'])
            : null,
        _isFinshed = json['_isFinshed'];
  Map<String, dynamic> toJson() => {
        '_task': this._task,
        '_isFinshed': this._isFinshed,
        '_createdAt': this._createdAt,
        '_finishedAt': this._finishedAt,
      };
}

class TasksModel extends Model {
  List<Task> tasks = [];
  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    if (item is Task) {
      return item.toJson();
    }
    return item;
  }

  // dynamic myr(dynamic key, dynamic value) {
  //   if (key == null && value is List) {
  //     debugPrint("");
  //     return value.toList().map((f) => Task.fromJson(f));
  //   }
  //   return value;
  // }

  void _addTask(String text) {
    if (!isExist(text)) {
      tasks.add(new Task(text));
    }
    notifyListeners();
    saveDb();
  }

  void pushToTop(int index) {
    var task = tasks[index];
    tasks.removeAt(index);
    tasks.insert(0, task);
    notifyListeners();
    saveDb();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
    saveDb();
  }

  void finishTask(int index) {
    tasks[index].toggleIsFinshed();
    notifyListeners();
    saveDb();
  }

  bool isExist(String text) {
    int idx = tasks.lastIndexWhere((i) => i.task == text);
    return idx >= 0;
  }

  void loadFromDb() async {
    debugPrint('loadFromDb');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String d = await prefs.get('tasks') ?? '[]';
    if (d != null) {
      List k = json.decode(d);
      for (int x = 0; x < k.length; x++) {
        Map j = k[x];
        debugPrint("");
        this.tasks.add(Task.fromJson(j));
      }
      notifyListeners();
    }
  }

  void saveDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String x = json.encode(tasks, toEncodable: myEncode);
    prefs.setString('tasks', x);
  }
}

class MyApp extends StatelessWidget {
  MyApp({this.modal});
  final TasksModel modal;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new ScopedModel<TasksModel>(
      model: modal,
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyHomePage(),
        routes: {
          '/second': (context) => new SecondScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Column(
          children: <Widget>[Upper(), Lower()],
        ),
      ),
    );
  }
}

class Upper extends StatelessWidget {
  Widget Title = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          new DateFormat.yMMMEd().format(new DateTime.now()),
          style: TextStyle(fontSize: 12.0, color: Colors.black54),
        ),
        new Text(
          "To-Do List",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              color: Colors.black87),
        ),
      ]);
  @override
  Widget build(BuildContext context) {
    final DateTime today = new DateTime.now();
    List<Widget> CalList = [];
    final weekDayString = ["S", "M", "T", "W", "T", "F", "S"];
    for (int x = 0; x < 7; x++) {
      DateTime d = today.subtract(new Duration(days: today.weekday - x));
      var k = new Column(
        children: <Widget>[
          new Text(
            weekDayString[x],
            style: new TextStyle(color: Colors.black38),
          ),
          new Container(
            margin: EdgeInsets.only(top: 10.0),
            child: new Text(
              d.day.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          new Container(
            margin: EdgeInsets.only(top: 8.0),
            height: 2.0,
            width: 10.0,
            decoration: BoxDecoration(
                color: d.day == today.day
                    ? Color.fromRGBO(91, 137, 255, 1.0)
                    : Colors.transparent),
          )
        ],
      );
      CalList.add(new Expanded(
        child: k,
      ));
    }
    Widget Cal = Container(
      alignment: Alignment(0.0, -10.0),
      margin: EdgeInsets.only(bottom: 0.0),
      child: new Row(
        children: CalList,
      ),
    );

    return new Expanded(
      flex: 1,
      child: new Container(
        decoration: new BoxDecoration(color: Colors.white, boxShadow: [
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ]),
        child:
            new Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          new Expanded(
            child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 20.0),
                child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Title,
                      // new Icon(Icons.search)
                    ])),
          ),
          Cal,
        ]),
      ),
    );
  }
}

class Lower extends StatelessWidget {
  Widget _buildItem(Task task, int idx, TasksModel model) {
    return new Slidable(
      secondaryActions: <Widget>[
        new IconSlideAction2(
          caption: null,
          foregroundColor: Colors.black26,
          icon: Icons.vertical_align_top,
          onTap: () => model.pushToTop(idx),
        ),
        new IconSlideAction2(
          caption: null,
          foregroundColor: Colors.black26,
          icon: Icons.remove_circle,
          onTap: () => model.removeTask(idx),
        ),
      ],
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
          // TODO: better format?
          // subtitle: task.isFinshed
          //     ? new Text(task.createdAt.toIso8601String())
          //     : null,
          title: new Text(
            task.task,
            style: TextStyle(
              color: task.isFinshed ? Colors.black38 : Colors.black87,
              decoration: task.isFinshed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          trailing: new IconButton(
            onPressed: () => model.finishTask(idx),
            icon: task.isFinshed
                ? Icon(Icons.check_box)
                : Icon(Icons.check_box_outline_blank),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new ScopedModelDescendant<TasksModel>(
      builder: (context, child, model) => Expanded(
          flex: 2,
          child: new Column(children: [
            Expanded(
                child: new Container(
              child: new ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemCount: model.tasks.length,
                  itemBuilder: (context, i) {
                    return Column(
                      children: <Widget>[
                        _buildItem(model.tasks[i], i, model),
                        new Divider(color: Colors.black12)
                      ],
                    );
                  }),
            )),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: FloatingActionButton(
                backgroundColor: Color.fromRGBO(91, 137, 255, 1.0),
                onPressed: () => Navigator.pushNamed(context, "/second"),
                child: Icon(Icons.add),
              ),
            )
          ])),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String text = "";
  void _onChange(t) {
    setState(() {
      text = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<TasksModel>(
      builder: (c, b, m) => Scaffold(
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          alignment: new Alignment(-10.0, 0.0),
                          icon: Icon(
                            Icons.close,
                            size: 30.0,
                          ),
                        )
                      ],
                    ),
                    new Expanded(
                      flex: 1,
                      child: new TextField(
                        style: TextStyle(
                            fontSize: 30.0,
                            color: Color.fromRGBO(51, 51, 51, 1.0)),
                        onChanged: _onChange,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(194, 194, 194, 1.0),
                            ),
                            hintText: 'Write Task Here'),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(bottom: 20.0),
                      width: double.infinity,
                      child: RaisedButton(
                        color: new Color.fromRGBO(91, 137, 255, 1.0),
                        onPressed: text.isEmpty
                            ? null
                            : () {
                                m._addTask(text);
                                Navigator.pop(context);
                              },
                        child: new Text(
                          'ADD',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
