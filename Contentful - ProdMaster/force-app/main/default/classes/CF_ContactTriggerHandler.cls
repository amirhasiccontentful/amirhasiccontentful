public with sharing class CF_ContactTriggerHandler {
	public static void CertifiedAccount(List<Contact> contacts) {
		Set<Id> accountIds = new Set<Id>();
		for (Contact contact : contacts) {
			accountIds.add(contact.AccountId);
		}

		List<Account> accounts = [SELECT Certified__c, (SELECT Id FROM Contacts WHERE Certified__c = true) FROM Account WHERE Id IN :accountIds];

		List<Account> updateAccounts = new List<Account>();
		for (Account account : accounts) {
			account.Certified__c = account.Contacts.size() > 0;
			updateAccounts.add(account);
		}

		if(!updateAccounts.isEmpty()) 
			update updateAccounts;
	}
}