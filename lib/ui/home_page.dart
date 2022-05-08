import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:async';
import 'dart:convert';

import './gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;

  Future<Map> _getSearch() async {
    http.Response response;
    try {
      if (_search == null) {
        response = await http.get(Uri.parse(
            "https://api.giphy.com/v1/gifs/trending?api_key=3lqGktVeGt1waxGK0mcgR125fNG94P2d&limit=25&rating=g"));
      } else {
        response = await http.get(Uri.parse(
            "https://api.giphy.com/v1/gifs/search?api_key=3lqGktVeGt1waxGK0mcgR125fNG94P2d&q=$_search&limit=19&offset=$_offset&rating=g&lang=en"));
      }
      return json.decode(response.body);
    } catch (erro) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _getSearch().then((map) => print(map));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 132, 54, 196), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                // prefixIconColor: kColorWhite,

                labelText: "Pesquise por GIF's",
                labelStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                hintText: 'Digite...',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _getSearch(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:

                case ConnectionState.none:
                  return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5.0,
                    ),
                  );
                default:
                  if (snapshot.hasError) Container();
                  return _createGifGrid(context, snapshot);
              }
            },
          ))
        ],
      ),
    );
  }

  Widget _createGifGrid(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text(
                      "Ver mais...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
