/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller extension of Standard Account Controller, for SetPrimaryContact Visualforce page.
* Makes use of the utility class "HandleException.cls" for logging errors.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        25-02-2023
* @modified       26-02-2023
* @utilClasses    HandleException.cls
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class setPrimaryContactExtension {
    public Account acct{get; set;}

    // Initializing pagination variables.
    Public Integer size{get;set;} 
    Public Integer offset{get; set;}
    Public Integer noOfRecords{get; set;}
    Public Integer page{get; set;}
    public List<SelectOption> paginationSizeOptions{get;set;}

    // Initializing search variables.
    Public String inputText{get; set;}
    Public String nameInput{get{
        if (nameInput == null) {
            nameInput = '%';
        }
        return nameInput;
    } set;}


    // Initializing contact variables.
    public String contactToUpdateId{get; set;}
    public Contact contactToUpdate{get; set;}

    // Initializing conditional rendering variables.
    public Boolean IsShowPopUp{get; set;}
    public Boolean isErrorShown{get; set;}

    // Initializing the class with default values.
    public setPrimaryContactExtension(ApexPages.StandardController sc) {
        // Getting the account Id.
        this.acct = (Account)sc.getRecord();

        // Initializing pagination values;
        size = 10;
        offset = 0;
        page = 1;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('25','25'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        noOfRecords = [SELECT Count()
                       FROM Contact
                       WHERE AccountId = :acct.Id
                       AND Name LIKE :nameInput];
    }

    // Getter of HasNext value for disabling Next Page button if there is no next page.
    public boolean getHasNext() {
        if (offset + size < noOfRecords) {
            return true;
        } else {
            return false;
        }
    }

    // Getter of HasPrev value for disabling Previous Page button if there is no previous page.
    public boolean getHasPrev() {
        if (offset > 0) {
            return true;
        } else {
            return false;
        }
    }

    // Method for refreshing the records per page value in the query and the UI.
    public PageReference refreshPageSize() {
        this.size = size;
        return null;
   }

   // Method for updating the query and the UI to the next page in the contact list.
    public PageReference nextPage() {
        page += 1;
        offset += size;
        return null;
    }

   // Method for updating the query and the UI to the previous page in the contact list.
    public PageReference prevPage() {
        page -= 1;
        offset -= size;
        return null;
    }

   // Method for updating the query and the UI to the first page in the contact list.
    public PageReference firstPage() {
        page = 1;
        offset = 0;
        return null;
    }

   // Method for updating the query and the UI to the last page in the contact list.
    public PageReference lastPage() {
        page = noOfRecords / size;
        offset = noOfRecords - Math.mod(noOfRecords, size);
        return null;
    }

   // Method for filtering the query and the UI regarding user input.
    public PageReference refreshNameInput() {
        this.nameInput = inputText + '%';
        return null;
    }
    
   // Getter for the related contacts of the account.
    public List<Contact> getContacts() {
        List<Contact> results = [
            SELECT Id, Name, Title, Phone, Is_Primary_Contact__c
            FROM Contact
            WHERE AccountId = :acct.Id
            AND Name LIKE :nameInput
            ORDER BY Is_Primary_Contact__c DESC, Name
            LIMIT :size
            OFFSET :offset
            ];
        return results;
    }

    // Saving the chosen contact record, and displaying the confirmation pop-up.
    public PageReference showPopUp() {
        List<Contact> result = [SELECT Id, Name,
                                Is_Primary_Contact__c
                                FROM Contact
                                WHERE Id = :contactToUpdateId];
        if(result.size() > 0) {
            contactToUpdate = result[0];
        }

        isShowPopUp = true;
        return null;
    }

    // Closing the confirmation pop-up, and the error pop-up.
    public PageReference closePopUp() {
        isShowPopUp = false;
        isErrorShown = false;
        return null;
    }

    // Method to update the chosen contact as primary contact, and others as not primary contact.
    public PageReference updateContacts() {
        try {
        // Setting the chosen contact's related field to true.
        contactToUpdate.Is_Primary_Contact__c = true;

        // Querying other contacts' with related field set to true.
        List<Contact> results;
        results = [SELECT Id, Name, LastName, Is_Primary_Contact__c
                   FROM Contact
                   WHERE AccountId = :acct.Id
                   AND Is_Primary_Contact__c = true];
        // If the list is not empty, setting their related fields to false;
        if(results.size() > 0) {
            for (Contact con : results) {
                con.Is_Primary_Contact__c = false;
            }
            // Updating the old primary contact(s).
            update results;
        }

        // Updating the chosen contact to be the primary contact.
        update contactToUpdate;
    } catch(Exception e) {
        // If an error occurs, error is logged as a "Error__c" record. (See HandleException.cls)
        HandleException.LogError(e);

        // Error pop-up is shown to let the user know that there was an error.
        IsShowPopUp = false;
        isErrorShown = true;
        return null;
    }

    // If there are no errors, user is redirected to the Account page.
    Pagereference p = new Pagereference('/' + acct.Id);
    p.setRedirect(true);

    return p;
    }
}