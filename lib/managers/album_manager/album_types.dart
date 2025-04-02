// retrieve amount of assets and a list of assets stop (5)

import 'dart:typed_data';

class AlbumData {
  List<Uint8List>? images; // cap at 5
  int amount;
  
  AlbumData({
    this.images,
    required this.amount
  });

}

