import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/buttonHomeCliente.dart';
import 'package:imogoat/components/buttonHomeSearch.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/styles/color_constants.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  bool _isLoading = true;
  List<Immobile> filteredImmobiles = [];

  Animation<double> animation = AlwaysStoppedAnimation(0.5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadImmobiles();
  }

  Future<void> _loadImmobiles() async {
    if (filteredImmobiles.isEmpty && !_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await controller.buscarImmobiles();
    filteredImmobiles = controller.immobile;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _searchImmobiles() async {
    setState(() {
      _isLoading = true;
    });
    await controller.buscarImmobiles();
    setState(() {
      filteredImmobiles = controller.immobile;
      _isLoading = false;
    });
  }

  Future<void> _searchImmobilesByType(String type) async {
    setState(() {
      _isLoading = true;
    });

    await controller.buscarImmobiles();

    filteredImmobiles =
        controller.immobile.where((immobile) => immobile.type == type).toList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: verde_escuro,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        child: Image.asset(
                          "assets/images/header.jpeg",
                          fit: BoxFit.cover,
                          opacity: animation,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Encontre facilmente onde ficar!',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SubmitButtonHome(
                                          texto: 'Todos',
                                          onPressed: () {
                                            _loadImmobiles();
                                          }),
                                      const SizedBox(width: 2.5),
                                      SubmitButtonHome(
                                          texto: 'AP',
                                          onPressed: () {
                                            _searchImmobilesByType('apartment');
                                          }),
                                      const SizedBox(width: 2.5),
                                      SubmitButtonHome(
                                          texto: 'Casa',
                                          onPressed: () {
                                            _searchImmobilesByType('house');
                                          }),
                                      const SizedBox(width: 2.5),
                                      SubmitButtonHome(
                                          texto: 'Quitinete',
                                          onPressed: () {
                                            _searchImmobilesByType(
                                                'studioApartment');
                                          }),
                                      const SizedBox(width: 2.5),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: TextFormField(
                                            cursorColor: Colors.black,
                                            onChanged: (value) {
                                              setState(() {
                                                controller.changeSearch(value);
                                                filteredImmobiles =
                                                    controller.immobile;
                                              });
                                            },
                                            decoration: const InputDecoration(
                                              prefixIcon: Icon(Icons.search),
                                              labelText: 'Bairro de interese',
                                              labelStyle: TextStyle(
                                                  color: verde_black,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              contentPadding: EdgeInsets.zero,
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      CustomButtonSearch(
                                        text: 'Pesquisar',
                                        onPressed: () {
                                          _searchImmobiles();
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                filteredImmobiles.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum imóvel encontrado",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          SizedBox(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isLandscape =
                                    MediaQuery.of(context).orientation ==
                                        Orientation.landscape;

                                int crossAxisCount = isLandscape
                                    ? (constraints.maxWidth ~/
                                        250)
                                    : 2;

                                double aspectRatio = isLandscape ? 1.2 : 1;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: filteredImmobiles.length,
                                  itemBuilder: (context, index) {
                                    final immobile = filteredImmobiles[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImmobileDetailPage(
                                                    immobile: immobile),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 5.0,
                                        margin: const EdgeInsets.all(7.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: immobile
                                                        .images.isNotEmpty
                                                    ? Image.network(
                                                        immobile
                                                            .images.first.url,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Center(
                                                        child: Text(
                                                            'Imagem indisponível')),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      immobile.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF265C5F),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {});
                                                      final immobileId =
                                                          controller
                                                              .immobile[index]
                                                              .id;
                                                    },
                                                    icon: Icon(Icons.favorite,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color: Color(0xFF265C5F),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      immobile.neighborhood,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF265C5F),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                SizedBox(
                  height: 40,
                )
              ],
            ),
          );
  }
}
