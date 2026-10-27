import 'package:equatable/equatable.dart';
import 'key_value_param.dart';

enum RequestBodyType {
  none('None'),
  json('JSON'),
  formData('Form Data'),
  raw('Raw Text');

  final String label;
  const RequestBodyType(this.label);
}

class RequestBody extends Equatable {
  final RequestBodyType type;
  final String rawContent;
  final List<KeyValueParam> formDataFields;

  const RequestBody({
    this.type = RequestBodyType.none,
    this.rawContent = '',
    this.formDataFields = const [],
  });

  RequestBody copyWith({
    RequestBodyType? type,
    String? rawContent,
    List<KeyValueParam>? formDataFields,
  }) {
    return RequestBody(
      type: type ?? this.type,
      rawContent: rawContent ?? this.rawContent,
      formDataFields: formDataFields ?? this.formDataFields,
    );
  }

  @override
  List<Object?> get props => [type, rawContent, formDataFields];
}
