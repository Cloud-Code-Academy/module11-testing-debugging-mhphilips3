
/**
 * LeadTriggerHandler class extends the TriggerHandler framework to handle Lead trigger events.
 * 
 * This class handles different trigger events on the Lead object:
 * - beforeInsert: Normalizes the Lead title and scores the Lead based on defined criteria.
 * - beforeUpdate: Normalizes the Lead title and updates the Lead score if required.
 * - afterInsert: Automatically converts the Lead to a Contact if a single matching Contact is found by email.
 * - afterUpdate: Attempts Lead auto-conversion based on email updates.
 */ 
public with sharing class LeadTriggerHandler extends TriggerHandler{
	
	private List<Lead> leadList;
	
	public LeadTriggerHandler(){
		this.leadList = (List<Lead>)Trigger.new;
	}
	
	
	/**
    * beforeInsert && beforeUpdate handlers
    * Normalizes the Lead's title and assigns a score to the Lead before it is inserted or updated.
    * 
    * Business Rule 1: Before a Lead is inserted or updated, standardize the title to a predefined set 
    * (e.g., 'Vice President', 'Manager', 'Executive', 'Assistant') based on common variations.
    * 
    * Business Rule 2: Assign a score to the Lead based on the following criteria:
    * - +3 points if the Lead Source is 'Website' and the Lead has an email.
    * - +5 points if the Lead has a phone number.
    * - +10 points if the Lead's Industry is 'Technology'.
    */
	public override void beforeInsert(){
		LeadUtils.handleAutoLeadScoring(leadList);
		LeadUtils.handleTitleNormalization(leadList);		
	}
	
	public override void beforeUpdate(){
		LeadUtils.handleTitleNormalization(leadList);
		LeadUtils.handleAutoLeadScoring(leadList);
	}
	
    /**
	 * afterInsert && afterUpdate handlers
	 * Automatically converts the Lead to a Contact if an existing Contact with a matching email is found.
	 * 
	 * Business Rule 1: After a Lead is inserted, check if the Lead's email matches an existing Contact's email. 
	 * If a single matching Contact is found, convert the Lead into the Contact and merge their details.
	 * 
	 * Business Rule 2: If multiple Contacts share the same email or if no match is found, the Lead 
	 * remains unconverted and no changes are made.
	 */
	public override void afterInsert(){

		LeadUtils.handleLeadAutoConvert(leadList);
		
	}
	
	public override void afterUpdate(){

		// Avoid recursion by removing converted leads
		List<Lead> leadsToCheck = new List<Lead>();
		for (Lead l : leadList){
			if(l.IsConverted){
				continue;
			}
			leadsToCheck.add(l);
		}
		LeadUtils.handleLeadAutoConvert(leadsToCheck);
		
	}
	
	
	
	
	
	/*
	 * The `LeadTriggerHandler` class contains methods designed to handle various business requirements around
	 * the Lead object in Salesforce. This includes functionality like normalizing the title field of a lead, 
	 * automatically scoring leads based on certain criteria, and auto-converting leads when certain conditions are met.
	 * - Create a test class for `LeadTriggerHandler` to ensure all methods work as expected.
	 * - Update the LeadTrigger class to call the `LeadTriggerHandler` methods as needed.
	 *
	 * Students should note:
	 * - This class may contain intentional errors that need to be fixed for proper functionality.
	 * - Create a corresponding test class for `LeadTriggerHandler` to ensure all methods work as expected.
	 *   Both positive and negative test cases should be considered.
	 *
	 * Documentation on Lead conversion and Test Classes can be found here:
	 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
	 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm
	 */
	
	
	
	
	/* 
	* Question 1
	* Requirement Lead Title Normalization - handleTitleNormalization
	* Occasionally, users input titles in a variety of ways. Streamline these titles for consistency:
	 *
	 * Criteria:
	 * - If the title contains terms such as 'vp', 'v.p.', or 'vice president',
	 *   change the title to 'Vice President'.
	 * - If the title contains terms like 'mgr', 'manage', or 'head of department',
	 *   change the title to 'Manager'.
	 * - Should the title include words like 'exec', 'chief', or 'head',
	 *   change the title to 'Executive'.
	 * - If the title contains terms like 'assist', 'deputy', or 'jr',
	 *   change the title to 'Assistant'.
	 */
	//    MOVED TO LeadUtils
	//public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
	// 	System.debug('in handler**************' + leadsToNormalize.size());
	// 	for (Lead ld : leadsToNormalize) {
	// 		if (ld.Title.containsIgnoreCase('vp') ||
	// 		    ld.Title.containsIgnoreCase('v.p.') || 
	// 			ld.Title.containsIgnoreCase('vice president')
	// 		) {
	// 			ld.Title = 'Vice President';
	// 		} else if (
	// 			ld.Title.containsIgnoreCase('mgr') ||
	// 			ld.Title.containsIgnoreCase('manage') ||
	// 			ld.Title.containsIgnoreCase('head of department')
	// 		) {
	// 			ld.Title = 'Manager';
	// 		} else if (ld.Title.containsIgnoreCase('exec') || 
	// 					ld.Title.containsIgnoreCase('chief') || 
	// 					ld.Title.containsIgnoreCase('head')
	// 		) {
	// 			ld.Title = 'Executive';
	// 		} else if (ld.Title.containsIgnoreCase('assist') || 
	// 					ld.Title.containsIgnoreCase('deputy') || 
	// 					ld.Title.containsIgnoreCase('jr')
	// 		) {
	// 			ld.Title = 'Assistant';
	// 		}
	// 	}
	// }

	/* 
	 * Question 2
	 * Requirement Auto Lead Scoring - handleAutoLeadScoring
	 * Implement logic to automatically assign scores to leads based on specific criteria.
	 * 18 should be highest possible score a lead can have.
	 *
	 * Criteria:
	 * - If the lead source is from the website and an email exists, increment score by 3 points.
	 * - If the lead provides a phone number, increment score by 5 points.
	 * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
	 */
	// public static void handleAutoLeadScoring(List<Lead> leadsToScore) {
	// 	for (Lead ld : leadsToScore) {
	// 		Integer score = 0;

	// 		// Check and add points based on the specified conditions
	// 		if (ld.LeadSource == 'Website' && ld.Email != null) {
	// 			score += 3;
	// 		}

	// 		if (ld.Phone != null) {
	// 			score += 5;
	// 		}

	// 		if (ld.Industry == 'Technology') {
	// 			score += 10;
	// 		}

	// 		ld.Lead_Score__c = score; // Set the computed score back to the lead
	// 	}
	// }

	/* 
	 * Question 3
	 * Requirement Automatic Lead Conversion Based on Email Match - handleLeadAutoConvert
	 * Whenever a new Lead is created or an existing Lead's email address is updated,
	 * check for a matching Contact based on the email address. If a single matching
	 * Contact is identified, auto-convert the Lead.
	 * Use the Salesforce report Converted Lead to verify that the Lead was converted to the correct Contact.
	 *
	 * Criteria:
	 * - Monitor the "Email" field on the Lead object for creation or updates.
	 * - On Lead creation or email update, search the Contact object for records with the
	 *   same email address.
	 * - If a single matching Contact is identified:
	 *     - Auto-convert the Lead.
	 *     - Merge the Lead details with the existing Contact, ensuring that crucial
	 *       Contact information is preserved.
	 * - If multiple Contacts with the same email are found or no match is identified,
	 *   leave the Lead unconverted.
	 * 
	 * Hint: 
	 * - One of the errors is recursion related. Check if the lead is already converted or check if the email has changed/is null
	 * - One of the errors is map related. Make sure you are using the correct contact map key
	 */
	// public static void handleLeadAutoConvert(List<Lead> leads) {
	// 	// Step 1: Gather all lead emails
    //     Map<Id,String> leadToEmailMap = new Map<Id,String>();
	// 	for (Lead lead : leads) {
	// 		if (lead.Email != null){ // avoid mapping leads that lack an email address
	// 			leadToEmailMap.put(lead.Id, lead.Email);
	// 		}
	// 	}

	// 	if (leadToEmailMap.isEmpty()){
	// 		return; // avoids further processing if no email addresses exist
	// 	}


	// 	// Step 2: Find matching contacts based on email
	// 	Map<String, Contact> emailToContactMap = new Map<String, Contact>();
	// 	for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
	// 		if (!emailToContactMap.containsKey(c.Email)) {
	// 			emailToContactMap.put(c.Email, c); // First Match
	// 		} else {
	// 			// If we found another contact with the same email, we don't auto-convert.
	// 			// So we remove the email from the map.
	// 			emailToContactMap.remove(c.Email);
	// 		}
	// 	}

	// 	// Step 3: Auto-convert leads
	// 	List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
	// 	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
	// 	for (Id leadId : leadToEmailMap.keySet()) {
    //         String leadEmail = leadToEmailMap.get(leadId);
	// 		if (emailToContactMap.containsKey(leadEmail)) {
	// 			Database.LeadConvert lc = new Database.LeadConvert();
	// 			lc.setLeadId(leadId);
	// 			lc.setContactId(emailToContactMap.get(leadEmail).Id); // Use existing Contact Id
	// 			lc.setAccountId(emailToContactMap.get(leadEmail).AccountId); // Use existing Account Id
	// 			lc.setDoNotCreateOpportunity(true); // Assuming we don't want to create an opportunity
	// 			lc.setConvertedStatus(convertStatus.MasterLabel); // Set the converted status
	// 			leadConverts.add(lc);
	// 		}
	// 	}

	// 	if (!leadConverts.isEmpty()) {
	// 		List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
	// 	}
	// }
}