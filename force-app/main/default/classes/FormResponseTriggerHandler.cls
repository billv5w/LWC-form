public with sharing class FormResponseTriggerHandler {
  private static Set<Id> formIds = new Set<Id>();
  private static Map<Id, Form__c> formMap = new Map<Id, Form__c>();
  private static Set<Id> formResponseIds = new Set<Id>();
  private static Map<Id, List<Form__c>> formToChildFormsMap = new Map<Id, List<Form__c>>();
  private static Boolean recursive = false;

  public static void handleTrigger(
    List<FormResponse__c> responses,
    Boolean isAfter,
    Boolean isInsert,
    Boolean isUpdate
  ) {
    if (!isAfter && isInsert) {
      beforeInsert(responses);
    } else if (isAfter && isInsert) {
      afterInsert(responses);
    }
  }

  private static void beforeInsert(List<FormResponse__c> responses) {
    for (FormResponse__c response : responses) {
      formIds.add(response.Form__c);
    }
    formMap = new Map<Id, Form__c>(
      [
        SELECT
          Id,
          Name,
          DisplayName__c,
          DisplayDescription__c,
          ChildType__c,
          SortOrder__c,
          TargetObject__c
        FROM Form__c
        WHERE Id IN :formIds
      ]
    );
    for (FormResponse__c response : responses) {
      response.ChildType__c = formMap.get(response.Form__c).ChildType__c;
      response.DisplayName__c = formMap.get(response.Form__c).DisplayName__c;
      response.DisplayDescription__c = formMap.get(response.Form__c)
        .DisplayDescription__c;
      response.SortOrder__c = formMap.get(response.Form__c).SortOrder__c;
      response.TargetObject__c = formMap.get(response.Form__c).TargetObject__c;
    }
  }

  private static void afterInsert(List<FormResponse__c> responses) {
    // System.debug('recursive: ' + recursive);
    formToChildFormsMap = FormResponseTriggerHandlerUtil.buildFormToSectionsMap(
      formIds
    );
    for (List<Form__c> childForms : formToChildFormsMap.values()) {
      if (childForms == null) {
        continue;
      }
      for (Form__c childForm : childForms) {
        formIds.add(childForm.Id);
      }
    }

    Set<FormResponse__c> childResponses = new Set<FormResponse__c>();
    for (FormResponse__c response : responses) {
      formResponseIds.add(response.Id);
      List<FormResponse__c> localChildResponses = FormResponseTriggerHandlerUtil.createChildResponses(
        response,
        formToChildFormsMap.get(response.Form__c)
      );
      if (!localChildResponses.isEmpty()) {
        childResponses.addAll(localChildResponses);
        recursive = true;
      }
    }
    if (recursive) {
      insert new List<FormResponse__c>(childResponses);
    }

    for (FormResponse__c response : childResponses) {
      formResponseIds.add(response.Id);
    }

    if (recursive) {
      // System.debug('run once');
      FormResponseTriggerHandlerUtil.createFormQuestionResponses(
        new List<Id>(formResponseIds)
      );
      recursive = false;
    }
  }
}
