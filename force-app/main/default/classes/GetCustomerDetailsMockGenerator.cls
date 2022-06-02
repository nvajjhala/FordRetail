@isTest
global class GetCustomerDetailsMockGenerator implements HttpCalloutMock {
  global HTTPResponse respond(HttpRequest req) {
    System.assertEquals('GET', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(
      '{"name":"MOMMA SKAGGS", "email":"mommaskaggs@mailinator.com", "phone":"2125551212", "postalCode":"10101"}'
    );
    res.setStatusCode(200);
    return res;
  }
}
