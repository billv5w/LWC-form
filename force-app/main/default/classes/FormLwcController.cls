public with sharing class FormLwcController {
  @AuraEnabled
  public static Form__c getForm(Id formId) {
    return [
      SELECT
        Id,
        Name,
        DisplayDescription__c,
        DisplayName__c,
        Xid__c,
        ParentForm__c,
        ChildType__c,
        SortOrder__c,
        TargetObject__c,
        (
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
          FROM ChildForms__r
          ORDER BY SortOrder__c ASC
        )
      FROM Form__c
      WHERE Id = :formId
    ];
  }

  @AuraEnabled
  public static List<FormQuestion__c> getFormQuestions(Id formId) {
    return [
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
      WHERE Form__c = :formId
      ORDER BY SortOrder__c
    ];
  }
}
