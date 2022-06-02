@isTest
private with sharing class GetDealershipDetailsTest {
    @TestSetup
    static void makeData() {

        Contact primarySalesRep = new Contact();
        primarySalesRep.FirstName = 'Melissa';
        primarySalesRep.LastName = 'Nelson';
        primarySalesRep.Email = 'Melissa.Nelson@avisford.com';
        primarySalesRep.Phone = '(888) 840-0998';

        Contact backupSalesRep = new Contact();
        backupSalesRep.FirstName = 'TJ';
        backupSalesRep.LastName = 'Massey';
        backupSalesRep.Email = 'tj.massey@avisford.com';
        backupSalesRep.Phone = '(248) 226-2527';

        Account dealership = new Account();
        dealership.name = 'AVIS FORD, INC.';
        dealership.DealerPrimaryPAAccountCode__c = '2750';
        dealership.BillingStreet = '29200 Telegraph Rd.';
        dealership.BillingCity = 'Southfield';
        dealership.BillingState = 'MI';
        dealership.BillingPostalCode = '48034';
        dealership.Sales_Hours__c = 'M-S 9 AM to 8 PM S 10 AM to 6 PM';
        dealership.Services_Offered__c = 'Remote delivery, Deposit over phone';
        dealership.Participating_Programs__c = 'A/Z/X/D Plan';

        insert dealership;
        insert primarySalesRep;
        primarySalesRep.AccountId = dealership.Id;
        backupSalesRep.AccountId = dealership.Id;
        insert backupSalesRep;
    }

    @isTest
    static void testDealershipDetailsClass() {
        Test.startTest();

        Account testDealership = GetDealershipDetails.getDealershipByPACode('2750');
        Account invalidDealership = GetDealershipDetails.getDealershipByPACode('0000');
        
        Test.stopTest();

        System.assertEquals(testDealership.Name, 'AVIS FORD, INC.', 'Assert Name Failed');
        System.assertEquals(testDealership.BillingCity, 'Southfield', 'Assert City Failed');
        System.assertEquals(invalidDealership?.Name, null, 'Assert Name Failed');
    }
}