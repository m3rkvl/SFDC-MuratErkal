/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* A queueable class for updating Primary Contact Phone field of all secondary contacts of an account when a primary contact is set.
* Takes a Map of AccountId-Contact key-value pair,
* Finds all the secondary contacts of the account,
* Updates their Primary Contact Phone field to the primary contact's phone value,
* Sends the Database.SaveResult list to the 'HandleDatabaseError' utility class to log possible errors as custom error objects.
──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        27-02-2023
* @modified       27-02-2023
* @utilClasses    HandleDatabaseError.cls
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class UpdateContactsPhone implements Queueable {
    private Map<Id, Contact> conMap;

    public UpdateContactsPhone(Map<Id, Contact> contactsMap) {
        this.conMap = contactsMap;
    }
    
    public void execute(QueueableContext context) {
        //get the account ids  
        Set<Id> accIds = conMap.keySet(); 

        //query for all the secondary contacts to update
        List<Contact> consToUpdate = [SELECT Primary_Contact_Phone__c, AccountId
                                      FROM Contact
                                      WHERE AccountId IN :accIds
                                      AND Is_Primary_Contact__c = false];

        if (consToUpdate.size() > 0) {
            //loop over the contacts to update
            for (Contact con : consToUpdate) {
                //get the primary contact related to secondary contact from the map with its account id.
                Contact pCon = conMap.get(con.AccountId);
                //update the secondary contact's phone to the primary contact's phone.
                con.Primary_Contact_Phone__c = pCon.Phone;
            }
    
            //update the secondary contacts and save the results.
            Database.SaveResult[] results = Database.update(consToUpdate, false);
    
            //send the result list for errors to be logged.
            HandleDatabaseError.logError(results, consToUpdate, 'Contact Primary Phone Update', 'UpdateContactsPhone');
        }
    }
}