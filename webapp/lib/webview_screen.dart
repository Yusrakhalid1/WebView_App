import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  var initialUrl = "https://www.google.com/";
  double progress = 0;
  var urlController = TextEditingController();
  var isloading = false;

  @override
  void initstate(){
    super.initState();
    refreshController = PullToRefreshController(
      onRefresh: (){
        webViewController!.reload();
      },
       options: PullToRefreshOptions(
        color: Colors.white,
        backgroundColor: Colors.black87
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ()async{
            if(await webViewController!.canGoBack()){
              webViewController!.goBack();
            }
          },
           icon: const Icon(Icons.arrow_back_ios)
           ),
           title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12)
            ),
             child: TextField(
              onSubmitted: (value){
                url = Uri.parse(value);
                if(url.scheme.isEmpty){
                  url = Uri.parse("${initialUrl}search?q=$value");
                }
                webViewController!.loadUrl(urlRequest: URLRequest(url: url));
              },
              controller: urlController,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "eg. Yusra Khalid"
              ),
             ),
           ),
           actions: [
            IconButton(
            onPressed: (){
              webViewController!.reload();
            }, 
            icon: const Icon(Icons.refresh)
            )
           ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  onLoadStart: (controller , url){
                   var v = url.toString();
                   setState(() {
                     urlController.text = v;
                     isloading = true;
                   });
                  },
                  onLoadStop: (controller , url){
                    refreshController!.endRefreshing();
                    isloading = false;
                  },
                  onProgressChanged: (controller , progress){
                    if(progress == 100){
                      refreshController!.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onWebViewCreated: (controller) => webViewController = controller,
                 initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                 pullToRefreshController: refreshController,
          ),
           Visibility(
            visible: isloading,
            child: CircularProgressIndicator(
              value: progress,
            valueColor: const AlwaysStoppedAnimation(Colors.red),
          ))
              ],
            ))
        ],
      ),
    );
  }
}