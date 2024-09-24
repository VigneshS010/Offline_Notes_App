import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight;

  String? _newTaskContent;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Column(
  children: [
     Text(
      "Taskly...!",
      style: TextStyle(
        fontSize: 25,
        color: Colors.white,
      ),
    ),
     SizedBox(height: 10),
     Text(
      "This is for you",
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  ],
),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 197, 7),
        elevation: 40, // Add this line to set the elevation and add a shadow
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);

        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(
            task.timestamp.toString(),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.green,
          ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(
              index,
              task.toMap(),
            );
            setState(() {
              
            });
            
          },
          onLongPress:(){
            _box!.deleteAt(index);
            setState(() {
              
            });
          },
        );
      },
    );
  }
  // Task _newTask = Task(content: "Go to Gym", timestamp: DateTime.now(), done: false);
  // _box?.add(_newTask.toMap());

  // ListTile(
  //   title: const Text(
  //     "Do Laundry",
  //     style: TextStyle(decoration: TextDecoration.lineThrough),
  //   ),
  //   subtitle: Text(
  //     DateTime.now().toString(),
  //   ),
  //   trailing: const Icon(
  //     Icons.check_box_outline_blank_outlined,
  //     color: Colors.green,
  //   ),
  // )

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      backgroundColor: const Color.fromARGB(255, 156, 255, 159),
      child: const Icon(
        Icons.add,
      ), // Set the background color to green
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //this alert dialogue used to blur the background
        return AlertDialog(
          title: const Text("Add new Task"),
          content: TextField(
            onSubmitted: (value) {
              if (_newTaskContent != null) {
                var task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(task.toMap());
                setState(() {
                  _newTaskContent = null;
                  Navigator.pop(context);
                });
              }
            },
            onChanged: (value) {
              setState(() {
                _newTaskContent = value;
              });
            },
          ),
        );
      },
    );
  }
}
