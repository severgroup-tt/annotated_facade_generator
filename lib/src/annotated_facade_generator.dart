import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:annotated_facade/annotated_facade.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class AnnotatedFacadeGenerator extends GeneratorForAnnotation<Facade> {
  static const _supportsNullability = false;
  static const _delegatePropertyName = "delegate";
  static const _wrapMethodName = "wrap";

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final delegateType = annotation.read('type').typeValue;

    assert(delegateType.element?.kind == ElementKind.CLASS);
    assert(element.kind == ElementKind.CLASS);

    final delegateElement = delegateType.element as ClassElement;
    final facadeElement = element as ClassElement;

    return _generateMixin(delegateElement, facadeElement);
  }

  String _generateMixin(ClassElement delegate, ClassElement facade) => """
    mixin _\$${facade.displayName} implements ${delegate.displayName} {
      ${delegate.displayName} get $_delegatePropertyName;
      Future<T> $_wrapMethodName<T>(Future<T> Function() source);
      ${_generateDelegatedMethods(delegate)}
    }
  """;

  String _generateDelegatedMethods(ClassElement delegate) => delegate.methods
      .map(
        (e) => "@override ${_generateMethodName(e)} => ${_generatedWrappedMethodBody(e)};",
      )
      .join("\n");

  String _generatedWrappedMethodBody(MethodElement method) =>
      "$_wrapMethodName(() => $_delegatePropertyName.${method.displayName}(${method.parameters.map(_generateParameter).join(", ")}))";

  String _generateMethodName(MethodElement method) => method.declaration.getDisplayString(withNullability: _supportsNullability);

  String _generateParameter(ParameterElement parameter) => parameter.isNamed ? "${parameter.displayName}: ${parameter.displayName}" : parameter.displayName;
}
