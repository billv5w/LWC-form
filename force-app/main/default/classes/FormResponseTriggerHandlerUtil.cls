public with sharing class FormResponseTriggerHandlerUtil {
  public static Map<Id, List<FormQuestion__c>> buildFormToQuestionsMap(
    Set<Id> formIds
  ) {
    Map<Id, List<FormQuestion__c>> formToQuestionsMap = new Map<Id, List<FormQuestion__c>>();
    Map<Id, FormQuestion__c> formQuestionsMap = new Map<Id, FormQuestion__c>(
      [
        SELECT
          Id,
          Name,
          Form__c,
          DataType__c,
          QuestionText__c,
          HelpText__c,
          ResponseValues__c,
          Alignment__c,
          DisplayRichText__c,
          DisplayText__c,
          LargeDeviceSize__c,
          MediumDeviceSize__c,
          Required__c,
          SmallDeviceSize__c,
          SortOrder__c,
          Xid__c,
          InputText__c,
          DefaultValue__c,
          Maximum__c,
          Minimum__c,
          PatternMismatchMessage__c,
          Pattern__c,
          Step__c,
          TargetObject__c,
          TargetField__c
        FROM FormQuestion__c
        WHERE Form__c IN :formIds
        ORDER BY SortOrder__c
      ]
    );
    for (FormQuestion__c formQuestion : formQuestionsMap.values()) {
      if (!formToQuestionsMap.containsKey(formQuestion.Form__c)) {
        formToQuestionsMap.put(
          formQuestion.Form__c,
          new List<FormQuestion__c>()
        );
      }
      formToQuestionsMap.get(formQuestion.Form__c).add(formQuestion);
    }
    // System.debug('formToQuestionsMap: ' + formToQuestionsMap);
    return formToQuestionsMap;
  }

  public static Map<Id, List<Form__c>> buildFormToSectionsMap(Set<Id> formIds) {
    Map<Id, List<Form__c>> formToSectionsMap = new Map<Id, List<Form__c>>();
    List<Form__c> sections = [
      SELECT
        Id,
        Name,
        DisplayDescription__c,
        DisplayName__c,
        Xid__c,
        ParentForm__c,
        ChildType__c,
        SortOrder__c,
        TargetObject__c
      FROM Form__c
      WHERE ParentForm__c IN :formIds
    ];
    for (Form__c section : sections) {
      if (!formToSectionsMap.containsKey(section.ParentForm__c)) {
        formToSectionsMap.put(section.ParentForm__c, new List<Form__c>());
      }
      formToSectionsMap.get(section.ParentForm__c).add(section);
    }
    // System.debug('formToSectionsMap: ' + formToSectionsMap);
    return formToSectionsMap;
  }

  public static List<FormResponse__c> createChildResponses(
    FormResponse__c formResponse,
    List<Form__c> forms
  ) {
    List<FormResponse__c> childResponses = new List<FormResponse__c>();
    if (forms == null) {
      return childResponses;
    }
    for (Form__c form : forms) {
      FormResponse__c childResponse = new FormResponse__c();
      childResponse.Form__c = form.Id;
      childResponse.ParentFormResponse__c = formResponse.Id;
      childResponse.Name = form.Name + ' Response';
      childResponse.DisplayName__c = form.DisplayName__c;
      childResponse.DisplayDescription__c = form.DisplayDescription__c;
      childResponse.Status__c = 'New';
      childResponse.RootResponse__c = formResponse.RootResponse__c != null
        ? formResponse.RootResponse__c
        : formResponse.Id;
      childResponses.add(childResponse);
    }
    // System.debug('childResponses: ' + childResponses);
    return childResponses;
  }

  public static List<FormResponse__c> createResponses(List<Form__c> forms) {
    return createChildResponses(null, forms);
  }

  public static void createFormQuestionResponses(List<Id> formResponseIds) {
    Set<Id> formIds = new Set<Id>();
    List<FormResponse__c> formResponse = [
      SELECT Id, Name, ChildType__c, Form__c, ParentFormResponse__c, Xid__c
      FROM FormResponse__c
      WHERE Id IN :formResponseIds
    ];
    for (FormResponse__c response : formResponse) {
      formIds.add(response.Form__c);
    }
    Map<Id, List<FormQuestion__c>> formToQuestionsMap = buildFormToQuestionsMap(
      formIds
    );
    List<FormQuestionResponse__c> questionResponses = new List<FormQuestionResponse__c>();
    for (FormResponse__c response : formResponse) {
      List<FormQuestion__c> questions = formToQuestionsMap.get(
        response.Form__c
      );
      if (questions == null) {
        continue;
      }
      for (FormQuestion__c question : questions) {
        FormQuestionResponse__c questionResponse = new FormQuestionResponse__c();
        questionResponse.FormResponse__c = response.Id;
        questionResponse.FormQuestion__c = question.Id;
        questionResponse.Name = question.Name + ' Response';
        questionResponse.Alignment__c = question.Alignment__c;
        questionResponse.LargeDeviceSize__c = question.LargeDeviceSize__c;
        questionResponse.MediumDeviceSize__c = question.MediumDeviceSize__c;
        questionResponse.SmallDeviceSize__c = question.SmallDeviceSize__c;
        questionResponse.DataType__c = question.DataType__c;
        questionResponse.DisplayRichText__c = question.DisplayRichText__c;
        questionResponse.DisplayText__c = question.DisplayText__c;
        questionResponse.HelpText__c = question.HelpText__c;
        questionResponse.InputText__c = question.InputText__c;
        questionResponse.Maximum__c = question.Maximum__c;
        questionResponse.Minimum__c = question.Minimum__c;
        questionResponse.Pattern__c = question.Pattern__c;
        questionResponse.PatternMismatchMessage__c = question.PatternMismatchMessage__c;
        questionResponse.QuestionText__c = question.QuestionText__c;
        questionResponse.Required__c = question.Required__c;
        questionResponse.ResponseValues__c = question.ResponseValues__c;
        questionResponse.SortOrder__c = question.SortOrder__c;
        questionResponse.Step__c = question.Step__c;
        questionResponse.TargetField__c = question.TargetField__c;
        questionResponse.TargetObject__c = question.TargetObject__c;
        // System.debug('questionResponse: ' + questionResponse);
        questionResponses.add(questionResponse);
      }
    }
    insert questionResponses;
  }

  @future
  public static void debugIds(List<Id> ids) {
    System.debug('ids: ' + ids.size());
  }
}
