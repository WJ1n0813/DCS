import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import '../amplifyconfiguration.dart';
import 'package:amplify_api/amplify_api.dart';

Future<void> configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final api = AmplifyAPI();
  final s3 = AmplifyStorageS3();

  try {
    Amplify.addPlugins([auth,api,s3]);

    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException catch (e) {
    print(e);
  }
}
