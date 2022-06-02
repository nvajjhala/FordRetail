/*
 * @description: A service class to perform data masking as post refreshal step
 * @group: Service class
*/
public without sharing class PostDeploymentService implements SandboxPostCopy{

    /*
     * @description: post refresh script to Ad hoc change data
    */
    public void runApexClass(SandboxContext context){
        //1 - Mask custom and standard object records
        updateStandardCustomObjects();
    }

    /*
     * @description: method to update custom object records
    */
    public void updateStandardCustomObjects(){
        PostRefreshal_Batch refreshBatch = new PostRefreshal_Batch('Account','Id, PersonEmail,Phone,PersonMobilePhone, Sync_To_MC__c');
        Database.executeBatch(refreshBatch,200);

        PostRefreshal_Batch refreshContact = new PostRefreshal_Batch('Contact','Id, email, Phone,MobilePhone, Sync_To_MC__c');
        Database.executeBatch(refreshContact,200);

        PostRefreshal_Batch refreshUser = new PostRefreshal_Batch('User','Id, Email, Sync_To_MC__c, Phone');
        Database.executeBatch(refreshUser,200);
    }
}