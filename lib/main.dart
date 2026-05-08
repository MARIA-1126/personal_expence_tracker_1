import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'services/storage/transaction_storage.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(TransactionStorage.boxName);
  runApp(const MyApp());
} // yhn future me async await use krna hoga taki storage initialize ho jaye uske baad hi app run ho

class MyApp extends StatelessWidget {
  // yhn stateless widget use krna hoga kyuki app ka state change nahi hoga
  const MyApp({
    super.key,
  }); // yhn super.key use krna hoga taki widget ka key pass ho jaye

  @override
  Widget build(BuildContext context) {
    // yhn build method use krna hoga taki widget tree build ho jaye
    return MaterialApp(
      // yhn material app use krna hoga taki material design ka use ho jaye
      title:
          'Personal Expense Tracker', // yhn title use krna hoga taki app ka title set ho jaye
      debugShowCheckedModeBanner:
          false, //is se uper debug ka banner nahi aayega
      theme:
          AppTheme.dark(), // dark theme use krna hoga taki app ka dark mode ho jaye

      home: Builder(
        // yhn builder use krna hoga taki context mile aur uske through storage initialize ho jaye
        builder: (context) {
          final box = GetStorage(
            TransactionStorage.boxName,
          ); // yhn box initialize krna hoga taki storage ka use ho jaye
          final storage = TransactionStorage(
            box,
          ); // yhn storage initialize krna hoga taki transaction storage ka use ho jaye
          return AppBottomNav(
            storage: storage,
          ); // yhn app bottom nav use krna hoga taki app ka bottom navigation bar show ho jaye aur usme storage pass ho jaye
        },
      ),
    );
  }
}
