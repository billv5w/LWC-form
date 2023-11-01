public with sharing class FormResponseLwcController {
  @AuraEnabled
  public static FormResponse__c getFormResponse(Id formResponseId) {
    return [
      SELECT
        Id,
        OwnerId,
        Name,
        DisplayDescription__c,
        DisplayName__c,
        Form__c,
        JSONResponse__c,
        Status__c,
        Xid__c,
        ReadOnly__c,
        ParentFormResponse__c,
        ChildType__c,
        TargetObject__c,
        TargetRecord__c,
        RequiredCompleted__c,
        SortOrder__c,
        (
          SELECT
            Id,
            OwnerId,
            Name,
            DisplayDescription__c,
            DisplayName__c,
            Form__c,
            JSONResponse__c,
            Status__c,
            Xid__c,
            ReadOnly__c,
            ParentFormResponse__c,
            ChildType__c,
            TargetObject__c,
            TargetRecord__c,
            RequiredCompleted__c,
            SortOrder__c
          FROM ChildFormResponses__r
          ORDER BY SortOrder__c ASC
        )
      FROM FormResponse__c
      WHERE Id = :formResponseId
    ];
  }

  @AuraEnabled
  public static FormResponse__c saveFormResponse(FormResponse__c response) {
    List<FormResponse__c> responses = new List<FormResponse__c>();
    responses.add(response);
    if (response.Status__c == 'Submitted') {
      for (FormResponse__c childResponse : [
        SELECT Id, Status__c, RequiredCompleted__c
        FROM FormResponse__c
        WHERE RootResponse__c = :response.Id AND Status__c != 'Submitted'
      ]) {
        if (!childResponse.RequiredCompleted__c) {
          throw new AuraHandledException(
            'Please complete all required fields before submitting.'
          );
        }
        childResponse.Status__c = 'Submitted';
        responses.add(childResponse);
      }
    }
    update responses;
    return getFormResponse(response.Id);
  }

  @AuraEnabled
  public static List<FormQuestionResponse__c> getFormQuestionResponses(
    Id formResponseId
  ) {
    return [
      SELECT
        Id,
        Name,
        FormResponse__c,
        Alignment__c,
        DataType__c,
        DisplayRichText__c,
        DisplayText__c,
        DisplayClass__c,
        HelpText__c,
        LargeDeviceSize__c,
        MediumDeviceSize__c,
        QuestionText__c,
        Required__c,
        ResponseValues__c,
        SmallDeviceSize__c,
        SortOrder__c,
        Xid__c,
        InputCheckbox__c,
        InputCurrency__c,
        InputDate__c,
        InputDateTime__c,
        InputEmail__c,
        InputNumber__c,
        InputText__c,
        InputTextArea__c,
        InputTime__c,
        InputUrl__c,
        Response__c,
        FormQuestion__c,
        DefaultValue__c,
        Maximum__c,
        Minimum__c,
        PatternMismatchMessage__c,
        Pattern__c,
        Step__c,
        TargetField__c,
        TargetObject__c,
        TargetRecord__c
      FROM FormQuestionResponse__c
      WHERE FormResponse__c = :formResponseId
      ORDER BY SortOrder__c ASC
    ];
  }

  @AuraEnabled
  public static void saveFormQuestionResponses(
    Id formResponseId,
    List<FormQuestionResponse__c> formQuestionResponses
  ) {
    for (FormQuestionResponse__c response : formQuestionResponses) {
      System.debug('response: ' + response);
    }
    update formQuestionResponses;

    FormResponse__c response = new FormResponse__c(
      Id = formResponseId,
      Status__c = 'In Progress'
    );
    update response;
  }

  @AuraEnabled
  public static List<ContentVersion> getFiles(String recordId, String title) {
    List<ContentDocumentLink> links = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recordId
    ];

    Set<Id> docIds = new Set<Id>();
    for (ContentDocumentLink link : links) {
      docIds.add(link.ContentDocumentId);
    }

    title = title + '%';

    List<ContentVersion> versions = [
      SELECT
        Id,
        Title,
        PathOnClient,
        ContentDocumentId,
        ContentUrl,
        FileExtension,
        FileType,
        ContentSize,
        OwnerId,
        ContentModifiedDate
      FROM ContentVersion
      WHERE ContentDocumentId IN :docIds AND Title LIKE :title
    ];

    return versions;
  }

  @AuraEnabled
  public static void renameFiles(List<Id> contentVersionIds, String name) {
    List<ContentVersion> versions = [
      SELECT Id, Title, FileExtension
      FROM ContentVersion
      WHERE Id IN :contentVersionIds
    ];

    for (ContentVersion v : versions) {
      v.Title = name;
    }

    update versions;
  }

  @AuraEnabled
  public static void deleteFile(Id contentDocumentId) {
    ContentDocument cd = new ContentDocument();
    cd.Id = contentDocumentId;
    delete cd;
  }
}
