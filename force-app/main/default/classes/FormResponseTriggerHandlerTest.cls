@isTest
public with sharing class FormResponseTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    Form__c form = new Form__c();
    form.Name = 'testFrom';
    form.DisplayDescription__c = 'testDisplayDescription';
    form.DisplayName__c = 'testDisplayName';
    insert form;

    List<Form__c> formSections = new List<Form__c>();
    for (Integer i = 0; i < 30; i++) {
      Form__c formSection = new Form__c();
      formSection.Name = 'testName' + i;
      formSection.ParentForm__c = form.Id;
      formSection.DisplayName__c = 'testDisplayName' + i;
      formSection.SortOrder__c = i;
      formSections.add(formSection);
    }
    insert formSections;
    List<Form__c> formSectionsInserted = [
      SELECT Id, DisplayName__c, SortOrder__c
      FROM Form__c
      WHERE parentForm__c != NULL
    ];
    FormQuestion__c formQuestionTextInput = new FormQuestion__c();
    formQuestionTextInput.QuestionText__c = 'test text input';
    formQuestionTextInput.Form__c = formSectionsInserted[0].Id;
    formQuestionTextInput.DataType__c = 'InputText';
    formQuestionTextInput.SortOrder__c = 1;
    insert formQuestionTextInput;

    FormQuestion__c formQuestionPicklist = new FormQuestion__c();
    formQuestionPicklist.QuestionText__c = 'test picklist parent input';
    formQuestionPicklist.Form__c = formSectionsInserted[0].Id;
    formQuestionPicklist.ResponseValues__c = 'Yes;No';
    // formQuestionPicklist.ParentDependent_Answer__c = 'Yes';
    formQuestionPicklist.DataType__c = 'InputPicklist';
    formQuestionPicklist.SortOrder__c = 2;
    insert formQuestionPicklist;

    FormQuestion__c formQuestionPicklistChild = new FormQuestion__c();
    formQuestionPicklistChild.QuestionText__c = 'test picklist input Child';
    formQuestionPicklistChild.Form__c = formSectionsInserted[0].Id;
    // formQuestionPicklistChild.ParentForm_Question__c = formQuestionPicklist.Id;
    formQuestionPicklistChild.ResponseValues__c = 'Yes;No';
    formQuestionPicklistChild.DataType__c = 'InputPicklist';
    formQuestionPicklistChild.SortOrder__c = 3;
    insert formQuestionPicklistChild;

    FormQuestion__c formQuestion2 = new FormQuestion__c();
    formQuestion2.QuestionText__c = 'test text input';
    formQuestion2.Form__c = formSectionsInserted[1].Id;
    formQuestion2.DataType__c = 'InputText';
    formQuestion2.SortOrder__c = 4;
    insert formQuestion2;

    FormQuestion__c formQuestionRequired = new FormQuestion__c();
    formQuestionRequired.QuestionText__c = 'test text input';
    formQuestionRequired.Form__c = formSectionsInserted[2].Id;
    formQuestionRequired.DataType__c = 'InputText';
    formQuestionRequired.SortOrder__c = 5;
    formQuestionRequired.Required__c = true;
    insert formQuestionRequired;

    Form__c f3 = new Form__c();
    f3.Name = 'testNameff';
    f3.ParentForm__c = formSectionsInserted[2].Id;
    f3.DisplayName__c = 'testDisplayName3';
    insert f3;
  }

  @IsTest
  private static void testBeforeInsert() {
    Form__c form = [
      SELECT Id, DisplayName__c, DisplayDescription__c
      FROM Form__c
      LIMIT 1
    ];
    FormResponse__c formResponse = new FormResponse__c();
    formResponse.Form__c = form.Id;
    insert formResponse;
    FormResponse__c formResponseInserted = [
      SELECT Id, DisplayName__c, DisplayDescription__c
      FROM FormResponse__c
      WHERE Id = :formResponse.Id
    ];
    System.assertEquals(
      form.DisplayName__c,
      formResponseInserted.DisplayName__c
    );
    System.assertEquals(
      form.DisplayDescription__c,
      formResponseInserted.DisplayDescription__c
    );
  }

  @isTest
  private static void testAfterInsert() {
    List<Form__c> form = [
      SELECT Id, DisplayName__c, DisplayDescription__c
      FROM Form__c
      WHERE parentForm__c = NULL
    ];
    System.debug('parent list ' + form.size());
    FormResponse__c formResponse = new FormResponse__c();
    formResponse.Form__c = form[0].Id;
    Test.startTest();
    insert formResponse;
    Test.stopTest();
    List<FormResponse__c> formResponseInserted = [
      SELECT Id, DisplayName__c, DisplayDescription__c
      FROM FormResponse__c
    ];
    System.debug('responses no. ' + formResponseInserted.size());
    List<FormQuestionResponse__c> formQuestionResponses = [
      SELECT Id, FormQuestion__c, FormResponse__c, Response__c
      FROM FormQuestionResponse__c
      WHERE FormResponse__c != :formResponse.Id
    ];
    System.assertEquals(5, formQuestionResponses.size());
  }
}
