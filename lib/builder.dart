library annotated_facade_generator;

import 'package:annotated_facade_generator/src/annotated_facade_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder generate(BuilderOptions options) => SharedPartBuilder(
      [AnnotatedFacadeGenerator()],
      'annotated_facade',
    );
