@isTest
 global with sharing class FordDirectDeliverServiceMockGenerator implements HttpCalloutMock {
     protected String status {get; set;}
 	protected String bodyAsString{get; set;}

     global FordDirectDeliverServiceMockGenerator(String status, String body){
         this.status = status;
         this.bodyAsString = body;
     }

     global HTTPResponse respond(HttpRequest req) {
         System.assertEquals('POST', req.getMethod());
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setBody(this.bodyAsString);
         res.setStatus(this.status);
         return res;
     }
 }
