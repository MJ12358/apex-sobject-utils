({

  handleResponse: function(args, component, response) {
    if (response && response.hasOwnProperty('state')) {
      switch (response.state) {
        case 'SUCCESS':
        case 'DRAFT':
          this.showToast('Success', 'The operation completed successfully', 'success');
          if (args.successCallback && typeof args.successCallback === 'function') {
            args.successCallback(response);
          }
          break;
        case 'INCOMPLETE':
          this.showToast('Incomplete', 'User is offline, device dosen\'t support drafts', 'info');
          if (args.errorCallback && typeof args.errorCallback === 'function') {
            args.errorCallback(response);
          }
          break;
        case 'ERROR':
          this.showToast('Error', this.getErrorMessage(response), 'error');
          if (args.errorCallback && typeof args.errorCallback === 'function') {
            args.errorCallback(response);
          }
          break;
        default:
          this.showToast('Error', `Unknown error, State: ${response.state}, Error: ${this.getErrorMessage(response)}`, 'error');
          if (args.errorCallback && typeof args.errorCallback === 'function') {
            args.errorCallback(response);
          }
      }
    }
    component.set('v.isLoading', false);
  },

  getErrorMessage: function(response) {
    if (response.error && Array.isArray(response.error) && response.error.length > 0) {
      return response.error[0].message;
    }
    if (typeof response.error === 'string') {
      return response.error;
    }
    return 'Unknown error';
  },

  showToast: function(title, message, type) {
    const toast = $A.get('e.force:showToast');
    toast.setParams({
      title: title,
      message: message,
      type: type
    });
    toast.fire();
  }

})
