public with sharing class LeadUtils {
    
    /**
    * Normalizes Lead Title fields upon Lead insert or update.
    * 
    * @param leadsToNormalize A list of Lead records
    */
    public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
		System.debug('in handler**************' + leadsToNormalize.size());
		for (Lead ld : leadsToNormalize) {
			if (ld.Title == null){
				continue;
			} else if (
				ld.Title.containsIgnoreCase('vp') ||
                ld.Title.containsIgnoreCase('v.p.') || 
				ld.Title.containsIgnoreCase('vice president')
			) {
				ld.Title = 'Vice President';
			} else if (
				ld.Title.containsIgnoreCase('mgr') ||
				ld.Title.containsIgnoreCase('manage') ||
				ld.Title.containsIgnoreCase('head of department')
			) {
				ld.Title = 'Manager';
			} else if (ld.Title.containsIgnoreCase('exec') || 
						ld.Title.containsIgnoreCase('chief') || 
						ld.Title.containsIgnoreCase('head')
			) {
				ld.Title = 'Executive';
			} else if (ld.Title.containsIgnoreCase('assist') || 
						ld.Title.containsIgnoreCase('deputy') || 
						ld.Title.containsIgnoreCase('jr')
			) {
				ld.Title = 'Assistant';
			}
		}
	}
    /**
    * Assigns a score to the Lead before it is inserted or updated.
    * 
    * @param leadsToScore A list of Lead records
    */
    public static void handleAutoLeadScoring(List<Lead> leadsToScore) {

		for (Lead ld : leadsToScore) {
			Integer score = 0;
			// Check and add points based on the specified conditions
			if (ld.LeadSource == 'Website' && ld.Email != null) {
				score += 3;
			}
			if (ld.Phone != null) {
				score += 5;
			}
			if (ld.Industry == 'Technology') {
				score += 10;
			}
			ld.Lead_Score__c = score; // Set the computed score back to the lead
		}
	}

    /**
    * Automatically converts Leads, which contain an email address that matches that of an existing Contact.
    *   - Will not convert if there are multiple matching contacts 
    *   - Occurs on Lead insert or when a lead's email address has been updated.
    *
    * @param leads A list of Lead records
    */
    public static void handleLeadAutoConvert(List<Lead> leads) {
		// Step 1: Gather all lead emails
        Map<Id,String> leadToEmailMap = new Map<Id,String>();
		for (Lead lead : leads) {
			if (lead.Email != null){ // avoid mapping leads that lack an email address
				leadToEmailMap.put(lead.Id, lead.Email);
			}
		}
		if (leadToEmailMap.isEmpty()){
			return; // avoids further processing if no email addresses exist
		}

		// Step 2: Find matching contacts based on email
		Map<String, Contact> emailToContactMap = new Map<String, Contact>();
		for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
			if (!emailToContactMap.containsKey(c.Email)) {
				emailToContactMap.put(c.Email, c); // First Match
			} else {
				// If we found another contact with the same email, we don't auto-convert.
				// So we remove the email from the map.
				emailToContactMap.remove(c.Email);
			}
		}

		// Step 3: Auto-convert leads
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		for (Id leadId : leadToEmailMap.keySet()) {
            String leadEmail = leadToEmailMap.get(leadId);
			if (emailToContactMap.containsKey(leadEmail)) {
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(leadId);
				lc.setContactId(emailToContactMap.get(leadEmail).Id); // Use existing Contact Id
				lc.setAccountId(emailToContactMap.get(leadEmail).AccountId); // Use existing Account Id
				lc.setDoNotCreateOpportunity(true); // Assuming we don't want to create an opportunity
				lc.setConvertedStatus(convertStatus.MasterLabel); // Set the converted status
				leadConverts.add(lc);
			}
		}

		if (!leadConverts.isEmpty()) {
			List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
		}
	}

}