({

  recordUpdated: function(component, event, helper) {
    const params = event.getParams();
    switch (params.changeType) {
      case 'ERROR':
        helper.showToast('Error', 'An error occurred while loading the record', 'error');
        component.getEvent('recordError').fire();
        break;
      case 'LOADED':
        component.getEvent('recordLoaded').fire();
        break;
      case 'REMOVED':
        component.getEvent('recordRemoved').fire();
        break;
      case 'CHANGED':
        const evt = component.getEvent('recordChanged');
        evt.setParams({
          fields: params.changedFields
        });
        evt.fire();
        break;
    }
    component.set('v.isLoading', false);
  },

  deleteRecord: function(component, event, helper) {
    component.set('v.isLoading', true);
    const args = event.getParam('arguments');
    component.find('recordData').deleteRecord(
      $A.getCallback(response => {
        helper.handleResponse(args, component, response);
      })
    );
  },

  getNewRecord: function(component, event, helper) {
    component.set('v.isLoading', true);
    const args = event.getParam('arguments');
    component.find('recordData').getNewRecord(
      args.objectApiName,
      args.recordTypeId,
      args.skipCache,
      $A.getCallback(() => {
        let record = component.get('v.targetRecord');
        let error = component.get('v.targetError');
        if (error || !record) {
          helper.showToast('Error', 'Error initializing record', 'error');
          if (args.errorCallback && typeof args.errorCallback === 'function') {
            args.errorCallback();
          }
        } else if (args.successCallback && typeof args.successCallback === 'function') {
          args.successCallback();
        }
      })
    );
  },

  reloadRecord: function(component, event, helper) {
    component.set('v.isLoading', true);
    const args = event.getParam('arguments');
    component.find('recordData').reloadRecord(
      args.skipCache,
      $A.getCallback(() => {
        if (args.callback && typeof args.callback === 'function') {
          args.callback();
        }
      })
    );
  },

  saveRecord: function(component, event, helper) {
    component.set('v.isLoading', true);
    const args = event.getParam('arguments');
    component.find('recordData').saveRecord(
      $A.getCallback(response => {
        helper.handleResponse(args, component, response);
      })
    );
  }

})
