@isTest
global class GetVehicleDetailsMockGenerator implements HttpCalloutMock {
  global HTTPResponse respond(HttpRequest req) {
    System.assertEquals('GET', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(
      '{"vinSerialNumber":"X13F310GH", "makeDescriptionText":"Ford", "modelDescriptionText":"Pinto", "vehicleModelYear":"1975", "vehicleColorText":"Black"}'
    );
    res.setStatusCode(200);
    return res;
  }
}
