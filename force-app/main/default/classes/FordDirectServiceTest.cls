@isTest
 public with sharing class FordDirectServiceTest {

     @TestSetup
     static void makeData() {
     LiveChatVisitor lcv = new LiveChatVisitor();
     insert lcv;

     LiveChatTranscript lct = new LiveChatTranscript();
     lct.LiveChatVisitorId = lcv.id;
     lct.Receivable_Acct_Number__c = '12345';
     insert lct;
   }

   @isTest
   static void submitDealerLead_Success_Test() {
     LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];
     FordDirectDeliverRequest request = new FordDirectDeliverRequest();
     request.firstName = 'John';
     request.lastName = 'Doe';
     request.dealerName = 'Carmax';
     request.emailAddress = 'john.doe@gmail.com';
     request.dealerPaCode = '2750';
     request.receivableAccountNumber = 48349091;
     request.phoneNumber = '7086696666';
     VehicleToken recommendedVehicleToken = new VehicleToken();
     recommendedVehicleToken.make = 'Ford';
     recommendedVehicleToken.model = 'Flex';
     recommendedVehicleToken.year = '2022';
     request.recommendedVehicleToken = recommendedVehicleToken;

     String successResponse = '{"statuscode":"100", "trackingcode":"90174335", "message":"Success"}';
     String status = '200';

     Test.startTest();
     Test.setMock(HttpCalloutMock.class, new FordDirectDeliverServiceMockGenerator(status, successResponse));
     String response = FordDirectService.submitDealerLead(request, lct.Id);
     Test.stopTest();
     System.assertEquals(response, 'Success');
   }

   @isTest
   static void submitDealerLead_Failure_Test() {
     LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];
     FordDirectDeliverRequest request = new FordDirectDeliverRequest();
     request.firstName = 'John';
     request.lastName = 'Doe';
     request.dealerName = 'Carmax';
     request.emailAddress = 'john.doe@gmail.com';
     request.dealerPaCode = '2750';
     request.receivableAccountNumber = 48349091;
     request.phoneNumber = '7086696666';
     VehicleToken recommendedVehicleToken = new VehicleToken();
     recommendedVehicleToken.make = 'Honda';
     recommendedVehicleToken.model = 'Flex';
     recommendedVehicleToken.year = '2022';
     request.recommendedVehicleToken = recommendedVehicleToken;

     String failureResponse ='{'+
 		'    \"type\": \"https://apiguide.ford.com/metadata/ford-standard-error\",'+
 		'    \"title\": \"This error is detailed using Ford\'s standard error format.\",'+
 		'    \"status\": 500,'+
 		'    \"error\": {'+
 		'        \"messages\": ['+
 		'            \"Ford direct Delivr service request not successfully submitted. StatusCode : 600 Message : Invalid Vehicle Make\"'+
 		'        ],'+
 		'        \"attributes\": {'+
 		'            \"referenceId\": \"23986e9cca3efb71e19a7e03d2ccc3e7\",'+
 		'            \"timestamp\": 1653284196'+
 		'        }'+
 		'    }'+
 		'}';
     String status = '500';

     Test.startTest();
     Test.setMock(HttpCalloutMock.class, new FordDirectDeliverServiceMockGenerator(status, failureResponse));
     String response = FordDirectService.submitDealerLead(request, lct.Id);
     Test.stopTest();
     System.debug(response);
     System.assertEquals(response, 'Ford direct Delivr service request not successfully submitted. StatusCode : 600 Message : Invalid Vehicle Make');
   }

 }