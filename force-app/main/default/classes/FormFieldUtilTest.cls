@isTest
public with sharing class FormFieldUtilTest {
  @isTest
  static void test_getDynamicDescribe() {
    List<Account> accounts = createTestAccounts();
    String accountNumberLabel2 = FormFieldUtil.getDynamicDescribe(accounts[0])
      .fields.getMap()
      .get('AccountNumber')
      .getDescribe()
      .getLabel();
    Assert.areEqual(
      accountNumberLabel2,
      'Account Number',
      'Expected accountNumberLabel2 to be "Account Number"'
    );

    String accountNumberLabel = FormFieldUtil.getDynamicDescribe('Account')
      .fields.getMap()
      .get('AccountNumber')
      .getDescribe()
      .getLabel();
    Assert.areEqual(
      accountNumberLabel,
      'Account Number',
      'Expected accountNumberLabel to be "Account Number"'
    );
  }

  @isTest
  static void test_getFieldMap() {
    List<Account> accounts = createTestAccounts();
    String accountNumberLabel = FormFieldUtil.getFieldMap(accounts[0])
      .get('AccountNumber')
      .getDescribe()
      .getLabel();
    Assert.areEqual(
      accountNumberLabel,
      'Account Number',
      'Expected accountNumberLabel to be "Account Number"'
    );

    String accountNumberLabel2 = FormFieldUtil.getFieldMap('Account')
      .get('AccountNumber')
      .getDescribe()
      .getLabel();
    Assert.areEqual(
      accountNumberLabel2,
      'Account Number',
      'Expected accountNumberLabel2 to be "Account Number"'
    );
  }

  @isTest
  static void test_parseValueFromFieldPath() {
    List<Account> accounts = createTestAccounts();

    List<Contact> contactList = new List<Contact>();
    contactList.add(createTestContact(accounts[0]));
    insert contactList;

    Contact queriedContact = [
      SELECT Id, Name, Account.Name
      FROM Contact
      WHERE Id = :contactList[0].Id
      LIMIT 1
    ];

    Test.startTest();
    String accountName = (String) FormFieldUtil.parseValueFromFieldPath(
      queriedContact,
      'Account.Name'
    );
    String contactName = (String) FormFieldUtil.parseValueFromFieldPath(
      queriedContact,
      'Name'
    );
    String blah = (String) FormFieldUtil.parseValueFromFieldPath(
      queriedContact,
      'BLAH'
    );
    Test.stopTest();

    Assert.areEqual(
      accountName,
      queriedContact.Account.Name,
      'Expected accountName to be equal to the queried contact\'s account name'
    );
    Assert.areEqual(
      contactName,
      queriedContact.Name,
      'Expected contactName to be equal to the queried contact\'s name'
    );
    Assert.isNull(blah, 'Expected blah to be null');
  }

  @isTest
  static void test_parseLastSubObjectFromPath() {
    List<Account> accounts = createTestAccounts();
    accounts[0].OwnerId = UserInfo.getUserId();
    update accounts;

    List<Contact> contactList = new List<Contact>();
    contactList.add(createTestContact(accounts[0]));
    insert contactList;

    Contact contact = [
      SELECT Id, Account.Owner.Name
      FROM Contact
      WHERE Id IN :contactList
    ];
    SObject obj = FormFieldUtil.parseLastSubObjectFromPath(
      contact,
      'Account.Owner.Name'
    );

    Assert.isTrue(obj instanceof User);

    SObject obj2 = FormFieldUtil.parseLastSubObjectFromPath(
      contact,
      'Account.BLAH.name'
    );

    Assert.isNull(obj2, 'Expected obj2 to be null');
  }

  @isTest
  static void test_picklistMethods() {
    Assert.isTrue(
      FormFieldUtil.getPicklistLabels('Contact', 'LeadSource').contains('Web')
    );
    Assert.isTrue(
      FormFieldUtil.getPicklistValues('Contact', 'LeadSource').contains('Web')
    );
  }

  @isTest
  static void test_fieldSetMethods() {
    try {
      // cannot create field set in test class; this is the best we can do:
      List<Schema.FieldSetMember> fieldSet = FormFieldUtil.readFieldSet(
        'some_field_set',
        'Account'
      );
    } catch (exception e) {
      Assert.isTrue(
        e.getMessage().contains('Attempt to de-reference a null object')
      );
    }

    try {
      // cannot create field set in test class; this is the best we can do:
      List<String> fieldApiNames = FormFieldUtil.getFieldSetFieldAPINames(
        'some_field_set',
        'Account'
      );
    } catch (exception e) {
      Assert.isTrue(
        e.getMessage().contains('Attempt to de-reference a null object')
      );
    }

    try {
      // cannot create field set in test class; this is the best we can do:
      List<String> fieldApiNames = FormFieldUtil.getFieldSetFieldAPINames(null);
    } catch (exception e) {
      Assert.isTrue(
        e.getMessage().contains('Attempt to de-reference a null object')
      );
    }
  }

  @isTest
  static void test_fieldPermissionMethods() {
    Assert.isTrue(
      FormFieldUtil.isFieldUpdateable('Account', 'Industry'),
      'Expected isFieldUpdateble to be true for Account Industry field'
    );
    Assert.isTrue(
      FormFieldUtil.isFieldAccessible('Account', 'Industry'),
      'Expected isFieldAccessible to be true for Account Industry field'
    );
    Assert.isTrue(
      FormFieldUtil.isFieldCreateable('Account', 'Name'),
      'Expected isFieldCreateable to be true for Account Name field'
    );
    Assert.isFalse(
      FormFieldUtil.isFieldUpdateable('Account', 'CreatedDate'),
      'Expected isFieldUpdateble to be false for Created Date field'
    );
    Assert.isTrue(
      FormFieldUtil.isFieldAccessible('Account', 'CreatedDate'),
      'Expected isFieldAccessible to be true for Created Date field'
    );
    Assert.isFalse(
      FormFieldUtil.isFieldCreateable('Account', 'CreatedDate'),
      'Expected isFieldCreateable to be false for Created Date field'
    );
  }

  @isTest
  static void test_getFieldType() {
    Assert.areEqual(
      FormFieldUtil.getFieldType('Account', 'Industry'),
      'PICKLIST'
    );
  }

  @isTest
  static void test_GetFieldsMethods() {
    Assert.isTrue(FormFieldUtil.getAllFieldsForSobj('Account').size() > 0);
    Assert.isTrue(
      FormFieldUtil.getAllFieldsForSObjAsStr('Account').length() > 0
    );

    Assert.isFalse(
      FormFieldUtil.getAllFieldsExceptBlacklist(
          'Account',
          new List<String>{ 'Name' }
        )
        .contains('name')
    );
    Assert.isTrue(
      FormFieldUtil.getAllFieldsExceptBlacklist(
          'Account',
          new List<String>{ 'Name' }
        )
        .contains('type')
    );

    Assert.isFalse(
      FormFieldUtil.getAllFieldsExceptBlacklistAsStr(
          'Account',
          new List<String>{ 'Name' }
        )
        .contains('Name,')
    );
    Assert.isTrue(
      FormFieldUtil.getAllFieldsExceptBlacklistAsStr(
          'Account',
          new List<String>{ 'Name' }
        )
        .contains('type,')
    );

    Assert.isTrue(
      FormFieldUtil.getAllCreatableFieldsAsStr('Account').length() > 0,
      'Expected the length of Account createable fields string to be greater than 0'
    );
    Assert.isTrue(
      FormFieldUtil.getAllCreatableFieldsAsStr('Account').contains('Name'),
      'Expected the Account createable fields string to contain "Name"'
    );
    Assert.isFalse(
      FormFieldUtil.getAllCreatableFieldsAsStr('Account')
        .contains('CreatedById'),
      'Expected the Account createable fields string to contain "CreatedById"'
    );

    Assert.isTrue(
      FormFieldUtil.getAllUpdateableFieldsAsStr('Account').length() > 0,
      'Expected the length of Account updateable fields string to be greater than 0'
    );
    Assert.isTrue(
      FormFieldUtil.getAllUpdateableFieldsAsStr('Account').contains('Name'),
      'Expected the Account updateable fields string to contain "Name"'
    );
    Assert.isFalse(
      FormFieldUtil.getAllUpdateableFieldsAsStr('Account')
        .contains('CreatedById'),
      'Expected the Account updateable fields string to contain "CreatedById"'
    );

    Assert.isTrue(
      FormFieldUtil.getAllAccessibleFieldsAsStr('Account').length() > 0,
      'Expected the length of Account accessible fields string to be greater than 0'
    );
    Assert.isTrue(
      FormFieldUtil.getAllAccessibleFieldsAsStr('Account').contains('Name'),
      'Expected the Account accessible fields string to contain "Name"'
    );
    Assert.isTrue(
      FormFieldUtil.getAllAccessibleFieldsAsStr('Account')
        .contains('CreatedById'),
      'Expected the Account accessible fields string to contain "CreatedById"'
    );
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = '1'));
    accounts.add(new Account(Name = '2'));
    accounts.add(new Account(Name = '3'));

    insert accounts;
    return accounts;
  }

  private static Contact createTestContact(Account account) {
    return new Contact(
      FirstName = account.Name,
      LastName = account.name,
      AccountId = account.Id
    );
  }
}
