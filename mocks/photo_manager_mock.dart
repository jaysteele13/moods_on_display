import 'package:photo_manager/photo_manager.dart';
import 'package:mockito/annotations.dart';

abstract class IPhotoManagerService {
  Future<PermissionState> requestPermission();
}

class PhotoManagerService implements IPhotoManagerService {
  final bool forceAuth;

  /// Constructor allows enabling forced authentication
  PhotoManagerService({this.forceAuth = true});

  @override
  Future<PermissionState> requestPermission() async {
    if (forceAuth) {
      return PermissionState.authorized; // Always return authorized if forced
    }
    return PhotoManager.requestPermissionExtend();
  }
}



// Create a Mock class
@GenerateMocks([IPhotoManagerService]) 
void main() {}

