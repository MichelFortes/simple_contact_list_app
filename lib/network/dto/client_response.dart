class ClientResponse<T> {

  final String requestId;
  final T wrappedResponse;

  ClientResponse({required this.requestId, required this.wrappedResponse});

}