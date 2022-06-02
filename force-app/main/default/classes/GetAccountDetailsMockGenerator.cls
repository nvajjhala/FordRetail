@isTest
global class GetAccountDetailsMockGenerator implements HttpCalloutMock {
  global HTTPResponse respond(HttpRequest req) {
    System.assertEquals('GET', req.getMethod());

    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(
      '{"receivableAccountNumber":"52139639", "productType":"Lease", "scheduledPaymentAmount":"412.33",  "contractTermInMonths":"24",  "lastPaymentDate":"8-10-2023", "currentScheduledTerminationDate":"8-11-2023"}'
    );
    res.setStatusCode(200);
    return res;
  }

}
