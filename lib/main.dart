import 'dart:developer';
import 'dart:js' as js;

import 'package:blockchain_week6_ex2/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/flutter_web3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFT',
      theme: ThemeData(
        platform: TargetPlatform.android,
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: Column(children: [
              const Text('Please use the SOKOL testnet'),
              GestureDetector(
                onTap: () {
                  js.context.callMethod(
                      'open', ['https://blockscout.com/poa/sokol/']);
                },
                child: const Text('Link to the testnet (click)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectionPage(),
                    ),
                  );
                },
                child: const Text('Create collection'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MintingPage(),
                    ),
                  );
                },
                child: const Text('Minting'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  Future<void> setupEth() async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    busd = Contract(
      generatorAddress,
      Interface(generatorAbi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs;
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  Future<String> callReadOnlyMethod(String method, List<dynamic> args) async {
    try {
      final result = await busd.call(method, args);
      showToast(result.toString());
      return result.toString();
    } catch (e) {
      log(e.toString());
      showToast(e.toString());
      return e.toString();
    }
  }

  Future<void> callPayableMethod(
    String method,
    List<dynamic> args, {
    TransactionOverride? override,
  }) async {
    final navigator = Navigator.of(context);
    try {
      final send = await busd.send(method, args, override);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
                child: SizedBox(
                  height: 10,
                  width: 300,
                  child: LinearProgressIndicator(),
                ),
              ));
      final result = await send.wait();
      navigator.pop();
      showToast(result.logs.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  late Contract busd;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  String collections = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  await setupEth();
                },
                child: const Text('Connect'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _symbolController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Symbol',
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await callPayableMethod(
                    'createCollection',
                    [
                      _nameController.text,
                      _symbolController.text,
                    ],
                  );
                },
                child: const Text('Create'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  final result = await callReadOnlyMethod(
                    'getCollections',
                    [],
                  );
                  setState(() {
                    collections = result;
                  });
                },
                child: const Text('Get collections'),
              ),
              const SizedBox(height: 20),
              SelectableText(collections),
            ],
          ),
        ),
      ),
    );
  }
}

class MintingPage extends StatefulWidget {
  const MintingPage({super.key});

  @override
  State<MintingPage> createState() => _MintingPageState();
}

class _MintingPageState extends State<MintingPage> {
  Future<void> setupEth({required String customContractAddress}) async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    busd = Contract(
      customContractAddress,
      Interface(nftAbi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs;
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  Future<String> callReadOnlyMethod(String method, List<dynamic> args) async {
    try {
      final result = await busd.call(method, args);
      showToast(result.toString());
      return result.toString();
    } catch (e) {
      log(e.toString());
      showToast(e.toString());
      return e.toString();
    }
  }

  Future<void> callPayableMethod(
    String method,
    List<dynamic> args, {
    TransactionOverride? override,
  }) async {
    final navigator = Navigator.of(context);
    try {
      final send = await busd.send(method, args, override);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
                child: SizedBox(
                  height: 10,
                  width: 300,
                  child: LinearProgressIndicator(),
                ),
              ));
      final result = await send.wait();
      navigator.pop();
      showToast(result.logs.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  late Contract busd;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.3),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Collection address',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'TokenURI',
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await setupEth(customContractAddress: _controller.text);
                  await callPayableMethod(
                    'mintNFT',
                    [
                      _controller2.text,
                      _controller3.text,
                    ],
                  );
                },
                child: const Text('Mint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
