global class GetAccountWeatherErrorHttpCalloutMock implements HttpCalloutMock{
    private final String json = '{'+
    '    \"cod\": 401,'+
    '    \"message\": \"Some error message.\"'+
    '}';

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(401);
        return res;
    }
}