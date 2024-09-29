import 'package:appgeolocalizacao/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/*

MarkerLayer: Adiciona um marcador ao mapa na posição atual do usuário.
*/


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  //Instancia o serviço que obtém a localização do usuário.
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    //Método inicial do widget que chama _getCurrentLocation() para obter a localização do usuário 
    //ao iniciar o aplicativo.
    super.initState();
    _getCurrentLocation();
  }

  //Método assíncrono que chama o serviço de localização e armazena as coordenadas 
  Future<void> _getCurrentLocation() async {
    try {
      //obtém a localização do usuário.
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        //Armazena a localização atual do usuário como um objeto LatLng (latitude e longitude).
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      //Se houver um erro ao obter a localização, ele será registrado no console.
      print('Erro ao obter a localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Localização no Mapa'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          //O widget principal que exibe o mapa na tela.
          : FlutterMap(
              options: MapOptions(
                center: _currentPosition,
                zoom: 15,
              ),
              children: [
                //Define o provedor do mapa, que neste caso é o OpenStreetMap, um serviço gratuito de mapas.
                TileLayer(
                  //{s}: Subdomínio para balanceamento de carga.
                  //{z}: Nível de zoom do mapa.
                  //{x}: Coluna do tile.
                  //{y}: Linha do tile.
                  // exemplo: https://a.tile.openstreetmap.org/5/12/8.png
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',

                  //A configuração subdomains no carregamento de tiles de mapas é uma 
                  //técnica usada para melhorar a performance e a escalabilidade ao distribuir 
                  //as requisições de tiles entre vários subdomínios. 
                  subdomains: ['a', 'b', 'c'],
                ),
                //Adiciona um marcador ao mapa na posição atual do usuário.
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!, //! -> null assertion operator "forçando" a conversão de um valor nulo para um valor não nulo
                      width: 80,
                      height: 80,
                      builder: (ctx) => Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
