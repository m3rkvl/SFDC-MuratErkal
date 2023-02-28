trigger UpdateContactsPrimaryPhone on Contact (before insert, before update) {
  //Map for contacts which past the validation.
  Map<Id, Contact> primaryCons = new Map<Id, Contact>();
  //List for contacts which pass the first filter.
  List<Contact> conList = new List<Contact>();

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      //Filtering out the contacts without an AccountId and are set as primary contact.
      for (Contact con : Trigger.New) {
        if (con.AccountId != null && con.Is_Primary_Contact__c == true) {
          conList.add(con);
        }
      }
    }
    when BEFORE_UPDATE {
      //Filtering out the contacts without an AccountId and are set as primary contact.
      for (Contact con : Trigger.New) {
        if (con.AccountId != null && con.Is_Primary_Contact__c == true && Trigger.oldMap.get(con.Id).Is_Primary_Contact__c == false) {
          conList.add(con);
        }
      }
    }
  }

  //If the filtered contact list isn't empty, continue execution.
  if (conList.size() > 0) {
    
    Set<Id> conSetAccountIds = new Set<Id>();
    for (Contact conAccountId : conList) {
      conSetAccountIds.add(conAccountId.AccountId);
    }

    //Find the accounts related to contacts which already has a primary contact
    List<Contact> accsQuery = [SELECT AccountId
                 FROM Contact
                 WHERE Is_Primary_Contact__c = true
                 AND AccountId IN :conSetAccountIds];
  

    //List for storing the ids of accounts mentioned above.
    Set<Id> accsWithPrimary = new Set<Id>();

    if (accsQuery.size() > 0) {
      //Put the ids of those accounts in a list.
      for (Contact con : accsQuery) {
        accsWithPrimary.add(con.AccountId);
      }
    }

    //loop over the filtered list to add error on the contacts related to accounts with a primary contact set.
    //Map the contacts that aren't related to accounts with a primary contact, with account ids as keys.
    Map<Id, List<Contact>> conMapToCheck = new Map<Id, List<Contact>>();
    for (Contact con : conList) {
      //check if contact's account has primary contact set.
      if (accsWithPrimary.contains(con.AccountId)) {
        //if it does, add error.
        con.addError('Related account already has a primary contact set.');
      //if it doesn't.
      } else {
        //check if map already has a key with the contact's accountid.
        if (conMapToCheck.containsKey(con.AccountId)) {
          //if it does, add the contact to that list.
          conMapToCheck.get(con.AccountId).add(con);
        } else {
          //if it doesn't, set a new list of contacts with contact in it and account id as the key.
          conMapToCheck.put(con.AccountId, new Contact[]{con});
        }
      }

      //if the conMapToCheck map isn't empty, continue execution
      if(conMapToCheck.size() > 0) {
        //loop over the map to check if there are multiple contacts set as primary per account
        for (Id i : conMapToCheck.keySet()) {
          //if there are, add errors for each of them.
          if (conMapToCheck.get(i).size() > 1) {
            for (Contact c : conMapToCheck.get(i)) {
              c.addError('An account can have only 1 primary contact.');
            }
          //if there aren't, add them to the map to send them to UpdateContactsPhone class.
          } else {
            primaryCons.put(i, conMapToCheck.get(i)[0]);
          }
        }
      }
      
    }

    if (primaryCons.size() > 0) {
      UpdateContactsPhone updateJob = new UpdateContactsPhone(primaryCons);
    System.enqueueJob(updateJob);
    }
  }
}