import 'package:build/build.dart';
import 'package:rua_generator/src/build/shared/generator/shared_post_builder.dart';
import 'package:rua_generator/src/build/shared/generator/shared_pre_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder preBuilder(BuilderOptions options) => SharedPartBuilder(
      [
        SharedPreBuilder(),
      ],
      'rua_pre_builder',
    );

Builder postBuilder(BuilderOptions options) => LibraryBuilder(
      SharedPostBuilder(),
      generatedExtension: '.rua_share.dart',
    );
