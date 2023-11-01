trigger FormResponseTrigger on FormResponse__c(
  before insert,
  after insert,
  before update,
  after update
) {
  FormResponseTriggerHandler.handleTrigger(
    Trigger.new,
    Trigger.isAfter,
    Trigger.isInsert,
    Trigger.isUpdate
  );
}
