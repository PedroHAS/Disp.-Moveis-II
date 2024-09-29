import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Personaliza o AppBar
      appBar: AppBar(
        title: Text(
          'Minha Localização no Mapa',
          style: TextStyle(
            color: Colors.white, // Cor do texto do título
            fontWeight: FontWeight.bold, // Texto em negrito
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal, // Cor do fundo do AppBar
        centerTitle: true, // Centraliza o título
      ),
      body: _currentPosition == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Personaliza o indicador de progresso
                  CircularProgressIndicator(
                    color: Colors.teal, // Cor personalizada
                  ),
                  SizedBox(
                      height: 16), // Espaçamento entre o indicador e o texto
                  Text(
                    'Carregando localização...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700], // Cor do texto
                    ),
                  ),
                ],
              ),
            )
          : FlutterMap(
              options: MapOptions(
                center: _currentPosition,
                zoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 100, // Aumenta o tamanho da área do marcador
                      height: 100,
                      builder: (ctx) => Icon(
                        Icons.location_on, // Ícone de localização moderno
                        color: Colors.blueAccent, // Cor personalizada do ícone
                        size: 50, // Aumenta o tamanho do ícone
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
