import 'package:equatable/equatable.dart';
import '../../domain/entities/http_method.dart';
import '../../domain/entities/request_body.dart';

abstract class RequestBuilderEvent extends Equatable {
  const RequestBuilderEvent();

  @override
  List<Object?> get props => [];
}

class ChangeMethodEvent extends RequestBuilderEvent {
  final HttpMethod method;
  const ChangeMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class ChangeUrlEvent extends RequestBuilderEvent {
  final String url;
  const ChangeUrlEvent(this.url);

  @override
  List<Object?> get props => [url];
}

class AddQueryParamEvent extends RequestBuilderEvent {
  const AddQueryParamEvent();
}

class UpdateQueryParamEvent extends RequestBuilderEvent {
  final String id;
  final String key;
  final String value;
  const UpdateQueryParamEvent(this.id, this.key, this.value);

  @override
  List<Object?> get props => [id, key, value];
}

class ToggleQueryParamEvent extends RequestBuilderEvent {
  final String id;
  const ToggleQueryParamEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RemoveQueryParamEvent extends RequestBuilderEvent {
  final String id;
  const RemoveQueryParamEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddHeaderEvent extends RequestBuilderEvent {
  const AddHeaderEvent();
}

class UpdateHeaderEvent extends RequestBuilderEvent {
  final String id;
  final String key;
  final String value;
  const UpdateHeaderEvent(this.id, this.key, this.value);

  @override
  List<Object?> get props => [id, key, value];
}

class ToggleHeaderEvent extends RequestBuilderEvent {
  final String id;
  const ToggleHeaderEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RemoveHeaderEvent extends RequestBuilderEvent {
  final String id;
  const RemoveHeaderEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ChangeBearerTokenEvent extends RequestBuilderEvent {
  final String token;
  const ChangeBearerTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}

class ChangeBodyTypeEvent extends RequestBuilderEvent {
  final RequestBodyType bodyType;
  const ChangeBodyTypeEvent(this.bodyType);

  @override
  List<Object?> get props => [bodyType];
}

class ChangeBodyContentEvent extends RequestBuilderEvent {
  final String content;
  const ChangeBodyContentEvent(this.content);

  @override
  List<Object?> get props => [content];
}

class FormatJsonBodyEvent extends RequestBuilderEvent {
  const FormatJsonBodyEvent();
}

class ImportCurlEvent extends RequestBuilderEvent {
  final String curl;
  const ImportCurlEvent(this.curl);

  @override
  List<Object?> get props => [curl];
}

class SendRequestEvent extends RequestBuilderEvent {
  const SendRequestEvent();
}
