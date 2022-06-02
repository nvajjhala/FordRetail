@isTest
private with sharing class GetVehicleDetailsTest {
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
  static void testVehicleDetailsClass() {
    string jsonSample = '{"vinSerialNumber":"X13F310GH", "makeDescriptionText":"Ford", "modelDescriptionText":"Pinto", "vehicleModelYear":"1975", "vehicleColorText":"Black"}';
    VehicleDetails vi = VehicleDetails.parse(jsonSample);
    System.assertEquals(vi.makeDescriptionText, 'Ford');
  }

  @isTest
  static void testCallout() {
    LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new GetVehicleDetailsMockGenerator());
    // Test LWC call
    VehicleDetails viResult = GetVehicleDetails.getInfoByTranscriptId(lct.Id);
    System.assertEquals(viResult.makeDescriptionText, 'Ford');

    // Test Flow call
    List<Id> ids = new List<id>();
    ids.add(lct.Id);
    List<VehicleDetails> vehicles = GetVehicleDetails.getVehicles(ids);
    System.assertEquals(vehicles[0].makeDescriptionText, 'Ford');

    // Force error to cover catch
    try {
      VehicleDetails viFail = GetVehicleDetails.getInfo('NOT ID');
      System.debug('good');
    } catch (Exception e) {
      System.debug('exception ' + e);
      System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
    }

    VehicleDetails viPass = GetVehicleDetails.getInfo(lct.Id);
    System.assertEquals(viPass.makeDescriptionText, 'Ford');

    Test.stopTest();
  }
}
