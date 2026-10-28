import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/json_isolate_service.dart';
import '../../../../core/utils/curl_parser.dart';
import '../../../environments/domain/usecases/substitute_env_variables_usecase.dart';
import '../../../environments/presentation/bloc/environments_bloc.dart';
import '../../../environments/presentation/bloc/environments_state.dart';
import '../../../history/domain/entities/history_item_entity.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../domain/entities/http_request_entity.dart';
import '../../domain/entities/key_value_param.dart';
import '../../domain/usecases/execute_request_usecase.dart';
import 'request_builder_event.dart';
import 'request_builder_state.dart';

class RequestBuilderBloc extends Bloc<RequestBuilderEvent, RequestBuilderState> {
  final ExecuteRequestUseCase executeRequestUseCase;
  final SaveHistoryItemUseCase? saveHistoryItemUseCase;
  final SubstituteEnvVariablesUseCase? substituteEnvVariablesUseCase;
  final EnvironmentsBloc? environmentsBloc;

  RequestBuilderBloc({
    required this.executeRequestUseCase,
    this.saveHistoryItemUseCase,
    this.substituteEnvVariablesUseCase,
    this.environmentsBloc,
  }) : super(RequestBuilderState.initial()) {
    on<ChangeMethodEvent>(_onChangeMethod);
    on<ChangeUrlEvent>(_onChangeUrl);
    on<AddQueryParamEvent>(_onAddQueryParam);
    on<UpdateQueryParamEvent>(_onUpdateQueryParam);
    on<ToggleQueryParamEvent>(_onToggleQueryParam);
    on<RemoveQueryParamEvent>(_onRemoveQueryParam);
    on<AddHeaderEvent>(_onAddHeader);
    on<UpdateHeaderEvent>(_onUpdateHeader);
    on<ToggleHeaderEvent>(_onToggleHeader);
    on<RemoveHeaderEvent>(_onRemoveHeader);
    on<ChangeBearerTokenEvent>(_onChangeBearerToken);
    on<ChangeBodyTypeEvent>(_onChangeBodyType);
    on<ChangeBodyContentEvent>(_onChangeBodyContent);
    on<FormatJsonBodyEvent>(_onFormatJsonBody);
    on<ImportCurlEvent>(_onImportCurl);
    on<SendRequestEvent>(_onSendRequest);
    on<LoadRequestEvent>(_onLoadRequest);
  }

  void _onLoadRequest(LoadRequestEvent event, Emitter<RequestBuilderState> emit) {
    emit(state.copyWith(
      request: event.request,
      clearResponse: true,
      clearError: true,
      clearInfo: true,
    ));
  }

  void _onChangeMethod(ChangeMethodEvent event, Emitter<RequestBuilderState> emit) {
    emit(state.copyWith(
      request: state.request.copyWith(method: event.method),
      clearInfo: true,
      clearError: true,
    ));
  }

  void _onChangeUrl(ChangeUrlEvent event, Emitter<RequestBuilderState> emit) {
    String input = event.url.trim();
    if (input.contains('?')) {
      final parts = input.split('?');
      final baseUrl = parts[0];
      final queryString = parts.sublist(1).join('?');
      final queryPairs = queryString.split('&');

      final List<KeyValueParam> newParams = List.from(state.request.queryParams);
      for (final pair in queryPairs) {
        if (pair.isEmpty) continue;
        final kv = pair.split('=');
        final key = Uri.decodeQueryComponent(kv[0]);
        final value = kv.length > 1 ? Uri.decodeQueryComponent(kv[1]) : '';

        final existingIdx = newParams.indexWhere((p) => p.key == key);
        if (existingIdx >= 0) {
          newParams[existingIdx] = newParams[existingIdx].copyWith(value: value, isEnabled: true);
        } else {
          newParams.add(KeyValueParam(key: key, value: value, isEnabled: true));
        }
      }

      emit(state.copyWith(
        request: state.request.copyWith(url: baseUrl, queryParams: newParams),
        clearInfo: true,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        request: state.request.copyWith(url: input),
        clearInfo: true,
        clearError: true,
      ));
    }
  }

  void _onAddQueryParam(AddQueryParamEvent event, Emitter<RequestBuilderState> emit) {
    final updated = List<KeyValueParam>.from(state.request.queryParams)
      ..add(KeyValueParam(key: '', value: ''));
    emit(state.copyWith(
      request: state.request.copyWith(queryParams: updated),
    ));
  }

  void _onUpdateQueryParam(UpdateQueryParamEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.queryParams.map((p) {
      if (p.id == event.id) {
        return p.copyWith(key: event.key, value: event.value);
      }
      return p;
    }).toList();

    emit(state.copyWith(
      request: state.request.copyWith(queryParams: updated),
    ));
  }

  void _onToggleQueryParam(ToggleQueryParamEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.queryParams.map((p) {
      if (p.id == event.id) {
        return p.copyWith(isEnabled: !p.isEnabled);
      }
      return p;
    }).toList();

    emit(state.copyWith(
      request: state.request.copyWith(queryParams: updated),
    ));
  }

  void _onRemoveQueryParam(RemoveQueryParamEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.queryParams.where((p) => p.id != event.id).toList();
    emit(state.copyWith(
      request: state.request.copyWith(queryParams: updated),
    ));
  }

  void _onAddHeader(AddHeaderEvent event, Emitter<RequestBuilderState> emit) {
    final updated = List<KeyValueParam>.from(state.request.headers)
      ..add(KeyValueParam(key: '', value: ''));
    emit(state.copyWith(
      request: state.request.copyWith(headers: updated),
    ));
  }

  void _onUpdateHeader(UpdateHeaderEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.headers.map((h) {
      if (h.id == event.id) {
        return h.copyWith(key: event.key, value: event.value);
      }
      return h;
    }).toList();

    emit(state.copyWith(
      request: state.request.copyWith(headers: updated),
    ));
  }

  void _onToggleHeader(ToggleHeaderEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.headers.map((h) {
      if (h.id == event.id) {
        return h.copyWith(isEnabled: !h.isEnabled);
      }
      return h;
    }).toList();

    emit(state.copyWith(
      request: state.request.copyWith(headers: updated),
    ));
  }

  void _onRemoveHeader(RemoveHeaderEvent event, Emitter<RequestBuilderState> emit) {
    final updated = state.request.headers.where((h) => h.id != event.id).toList();
    emit(state.copyWith(
      request: state.request.copyWith(headers: updated),
    ));
  }

  void _onChangeBearerToken(ChangeBearerTokenEvent event, Emitter<RequestBuilderState> emit) {
    emit(state.copyWith(
      request: state.request.copyWith(bearerToken: event.token),
    ));
  }

  void _onChangeBodyType(ChangeBodyTypeEvent event, Emitter<RequestBuilderState> emit) {
    emit(state.copyWith(
      request: state.request.copyWith(
        body: state.request.body.copyWith(type: event.bodyType),
      ),
    ));
  }

  void _onChangeBodyContent(ChangeBodyContentEvent event, Emitter<RequestBuilderState> emit) {
    emit(state.copyWith(
      request: state.request.copyWith(
        body: state.request.body.copyWith(rawContent: event.content),
      ),
    ));
  }

  Future<void> _onFormatJsonBody(FormatJsonBodyEvent event, Emitter<RequestBuilderState> emit) async {
    final raw = state.request.body.rawContent;
    if (raw.trim().isEmpty) return;
    final formatted = await JsonIsolateService.formatJson(raw);
    emit(state.copyWith(
      request: state.request.copyWith(
        body: state.request.body.copyWith(rawContent: formatted),
      ),
      infoMessage: 'JSON formatted',
    ));
  }

  void _onImportCurl(ImportCurlEvent event, Emitter<RequestBuilderState> emit) {
    final parsed = CurlParser.parse(event.curl);
    if (parsed != null) {
      emit(state.copyWith(
        request: parsed,
        infoMessage: 'cURL successfully imported!',
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Invalid cURL command in clipboard',
        clearInfo: true,
      ));
    }
  }

  Future<void> _onSendRequest(SendRequestEvent event, Emitter<RequestBuilderState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearInfo: true,
    ));

    // Substitute {{variables}} using active environment if configured
    HttpRequestEntity effectiveRequest = state.request;
    if (substituteEnvVariablesUseCase != null && environmentsBloc != null) {
      final envState = environmentsBloc!.state;
      if (envState is EnvironmentsLoadedState && envState.selectedEnvironment != null) {
        effectiveRequest = substituteEnvVariablesUseCase!(state.request, envState.selectedEnvironment);
      }
    }

    final response = await executeRequestUseCase(effectiveRequest);

    // Automatically persist to history
    if (saveHistoryItemUseCase != null) {
      try {
        await saveHistoryItemUseCase!(
          HistoryItemEntity(
            id: const Uuid().v4(),
            request: effectiveRequest,
            response: response,
            executedAt: DateTime.now(),
          ),
        );
      } catch (_) {}
    }

    emit(state.copyWith(
      isLoading: false,
      response: response,
    ));
  }
}
