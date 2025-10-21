import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/appBarCliente.dart';
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/controllers/image_controller.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/image_repository.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/home/home.dart';
import 'package:imogoat/screens/home/homeOwner.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StapeFourCreateImmobilePage extends StatefulWidget {
  const StapeFourCreateImmobilePage({super.key});

  @override
  State<StapeFourCreateImmobilePage> createState() => _StapeFourCreateImmobilePageState();
}

class _StapeFourCreateImmobilePageState extends State<StapeFourCreateImmobilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  final controller = ControllerImmobile(
    immobileRepository: ImmobileRepository(restClient: GetIt.I.get<RestClient>()),
  );
  final controllerImage = ControllerImage(imageRepository: ImageRepository(restClient: GetIt.I.get<RestClient>()));


  Future<void> createImage() async {
    await controller.getLastCreatedImmobileId();
    final lastId = controller.lastCreatedImmobileId;
    print('Id do imóvel: $lastId');

    if (lastId == null) {
      print('Erro: ID do último imóvel não encontrado');
      return;
    }

    try {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            context = context;
            return const Loading();
          }, 
        );
      print('Imagens selecionadas: $_selectedImages');
      print('Primeira imagem: ${_selectedImages[0]}');

      await controllerImage.createImage('/create-image', _selectedImages, lastId);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePageOwner()),
      );
    } catch (error) {
      print('Erro ao criar imagem: $error');
    }
  }


  Future<void> _selectImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.length <= 5) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você só pode selecionar até 5 imagens.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verde_medio,
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Cadastre o seu imóvel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F7C70),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _selectImages,
                    child: const Text('Selecionar Imagens'),
                  ),
                  const SizedBox(height: 10),
                  _selectedImages.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Image.file(_selectedImages[index], fit: BoxFit.cover);
                          },
                        )
                      : const Text('Nenhuma imagem selecionada'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 365,
                    child: ElevatedButton(
                      onPressed: () {
                        createImage();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF265C5F)),
                        side: MaterialStateProperty.all(const BorderSide(color: Color(0xFF265C5F), width: 1.5)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return null;
                        }),
                        elevation: MaterialStateProperty.all(0),
                        minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                      ),
                      child: const Text(
                        'Cadastrar Imóvel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
