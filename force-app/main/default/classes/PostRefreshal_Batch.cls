/*
 * @description: Batch class to run posy sandbox refreshal activities
 * @group: Batch class
*/
public without sharing class PostRefreshal_Batch implements Database.Batchable<sObject> {
    String objectName = '';
    String fieldsToQuery = '';
    public PostRefreshal_Batch(String objectName, String fieldsToQuery){
        this.objectName = objectName;
        this.fieldsToQuery = fieldsToQuery;
    }

    /*
     * @description: start method to query records
     * @param: Database.BatchableContext bc
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT '+ fieldsToQuery+ ' FROM ' + objectName+ ' WHERE Sync_To_MC__c = true WITH SECURITY_ENFORCED';
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            system.debug('exception in query--'+e);
            return null;
        }
    }

    /*
     * @description: execute method to perform update on Account, Contact, User
     * @param: Database.BatchableContext bc
     * @param: List<sObject> recordList
    */
    public void execute (Database.BatchableContext bc, List<sObject> recordList){
        Schema.SObjectType sObjectType = recordList.getSObjectType();
        if (sObjectType == Schema.Account.sObjectType){
            updateAccountRecords((List<Account>)recordList);
        }
        else if(sObjectType == Schema.Contact.sObjectType){
            updateContactRecords((List<Contact>)recordList);
        }
        else if(sObjectType == Schema.User.sObjectType){
            updateUserRecords((List<User>)recordList);
        }
    }

    /*
     * @description: method to perform record masking on Account
     * @param: List<Account> accountList
    */
    private static void updateAccountRecords(List<Account> accountList){
        for(Account acc : accountList){
            acc.Sync_To_MC__c = false;
          }
        if(Account.sObjectType.getDescribe().isUpdateable()){
            List<Database.SaveResult> accSave = Database.Update(accountList, false);
            for(Database.SaveResult s : accSave){
                system.debug('error in account update--'+ s.getErrors());
            }
        }
    }

    /*
     * @description: method to perform record masking on Contact
     * @param: List<Contact> allContacts
    */
    private static void updateContactRecords(List<Contact> allContacts){
        for(Contact c : allContacts){
            c.Sync_To_MC__c = false;
        }
        if(Contact.sObjectType.getDescribe().isUpdateable()){
            List<Database.SaveResult> conSave = Database.Update(allContacts, false);
            for(Database.SaveResult s : conSave){
                system.debug('error in contact update--'+ s.getErrors());
            }
        }
    }

    /*
     * @description: method to perform record masking on User
     * @param: List<user> userList
    */
    private static void updateUserRecords(List<User> userList){
        for(User usr : userList){
            usr.Sync_To_MC__c = false;
        }
        if(User.sObjectType.getDescribe().isUpdateable()){
            List<Database.SaveResult> usrSave = Database.Update(userList, false);
            for(Database.SaveResult s : usrSave){
                system.debug('error in user update--'+ s.getErrors());
            }
        }
    }

    /*
     * @description: finish method
     * @param: Database.BatchableContext bc
    */
    public void finish(Database.BatchableContext bc){
        system.debug('Post refreshal activities are executed');
    }
}