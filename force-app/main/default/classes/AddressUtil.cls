/**
 * Created on Sat Jun 04 2022
 *
 * Copyright (c) 2022 Matt Jants
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public inherited sharing class AddressUtil {

  public static Boolean isCodesEnabled {
    get {
      if (isCodesEnabled == null) {
        isCodesEnabled = SObjectUtil.isValid(Lead.SObjectType, 'CountryCode');
      }
      return isCodesEnabled;
    }
    private set;
  }

/**
 *	Copy address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copy(System.Address addr, SObject obj) {
    if (addr == null || obj == null) {
      return;
    }
    obj.put('City', addr.getCity());
    obj.put('Country', addr.getCountry());
    obj.put('Latitude', addr.getLatitude());
    obj.put('Longitude', addr.getLongitude());
    obj.put('PostalCode', addr.getPostalCode());
    obj.put('State', addr.getState());
    obj.put('Street', addr.getStreet());
    if (isCodesEnabled) {
      obj.put('CountryCode', addr.getCountryCode());
      obj.put('StateCode', addr.getStateCode());
    }
	}

/**
 *	Copy address fields
 *	@param SObject The sObject to copy the address from
 *	@param SObject The sObject to copy the address to
 */
	public static void copy(SObject fromObj, SObject toObj) {
    if (fromObj == null || toObj == null) {
      return;
    }
    if (fromObj.isSet('City')) {
      toObj.put('City', fromObj.get('City'));
    }
    if (fromObj.isSet('Country')) {
      toObj.put('Country', fromObj.get('Country'));
    }
    if (fromObj.isSet('Latitude')) {
      toObj.put('Latitude', fromObj.get('Latitude'));
    }
    if (fromObj.isSet('Longitude')) {
      toObj.put('Longitude', fromObj.get('Longitude'));
    }
    if (fromObj.isSet('PostalCode')) {
      toObj.put('PostalCode', fromObj.get('PostalCode'));
    }
    if (fromObj.isSet('State')) {
      toObj.put('State', fromObj.get('State'));
    }
    if (fromObj.isSet('Street')) {
      toObj.put('Street', fromObj.get('Street'));
    }
    if (isCodesEnabled) {
      if (fromObj.isSet('CountryCode')) {
        toObj.put('CountryCode', fromObj.get('CountryCode'));
      }
      if (fromObj.isSet('StateCode')) {
        toObj.put('StateCode', fromObj.get('StateCode'));
      }
    }
	}

/**
 *	Copy billing address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToBilling(System.Address addr, SObject obj) {
    if (addr == null || obj == null) {
      return;
    }
    obj.put('BillingCity', addr.getCity());
    obj.put('BillingCountry', addr.getCountry());
    obj.put('BillingLatitude', addr.getLatitude());
    obj.put('BillingLongitude', addr.getLongitude());
    obj.put('BillingPostalCode', addr.getPostalCode());
    obj.put('BillingState', addr.getState());
    obj.put('BillingStreet', addr.getStreet());
    if (isCodesEnabled) {
      obj.put('BillingCountryCode', addr.getCountryCode());
      obj.put('BillingStateCode', addr.getStateCode());
    }
	}

/**
 *	Copy shipping address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
	public static void copyToShipping(System.Address addr, SObject obj) {
    if (addr == null || obj == null) {
      return;
    }
    obj.put('ShippingCity', addr.getCity());
    obj.put('ShippingCountry', addr.getCountry());
    obj.put('ShippingLatitude', addr.getLatitude());
    obj.put('ShippingLongitude', addr.getLongitude());
    obj.put('ShippingPostalCode', addr.getPostalCode());
    obj.put('ShippingState', addr.getState());
    obj.put('ShippingStreet', addr.getStreet());
    if (isCodesEnabled) {
      obj.put('ShippingCountryCode', addr.getCountryCode());
      obj.put('ShippingStateCode', addr.getStateCode());
    }
	}

/**
 *	Copy mailing address fields
 *	@param System.Address The address to copy from
 *	@param SObject The sObject to copy the address to
 */
  public static void copyToMailing(System.Address addr, SObject obj) {
    if (addr == null || obj == null) {
      return;
    }
    obj.put('MailingCity', addr.getCity());
    obj.put('MailingCountry', addr.getCountry());
    obj.put('MailingLatitude', addr.getLatitude());
    obj.put('MailingLongitude', addr.getLongitude());
    obj.put('MailingPostalCode', addr.getPostalCode());
    obj.put('MailingState', addr.getState());
    obj.put('MailingStreet', addr.getStreet());
    if (isCodesEnabled) {
      obj.put('MailingCountryCode', addr.getCountryCode());
      obj.put('MailingStateCode', addr.getStateCode());
    }
  }

/**
 *	Is an address empty (skip checking country it defaults to US)
 *	@param System.Address
 *	@return Boolean
 */
	public static Boolean isEmpty(System.Address addr) {
    if (addr == null) {
      return true;
    }
		return String.isBlank(addr.getCity())
			&& String.isBlank(addr.getPostalCode())
			&& String.isBlank(addr.getState())
			&& String.isBlank(addr.getStreet());
	}

/**
 *	Is an address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isEmpty(SObject obj) {
    if (obj == null) {
      return true;
    }
		return obj.get('City') == null
			&& obj.get('PostalCode') == null
			&& obj.get('State') == null
			&& obj.get('Street') == null;
	}

/**
 *	Is billing address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isBillingEmpty(SObject obj) {
    if (obj == null) {
      return true;
    }
		return obj.get('BillingCity') == null
			&& obj.get('BillingPostalCode') == null
			&& obj.get('BillingState') == null
			&& obj.get('BillingStreet') == null;
	}

/**
 *	Is shipping address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean isShippingEmpty(SObject obj) {
    if (obj == null) {
      return true;
    }
		return obj.get('ShippingCity') == null
			&& obj.get('ShippingPostalCode') == null
			&& obj.get('ShippingState') == null
			&& obj.get('ShippingStreet') == null;
	}

/**
 *	Is mailing address empty (skip checking country it defaults to US)
 *	@param SObject
 *	@return Boolean
 */
  public static Boolean isMailingEmpty(SObject obj) {
    if (obj == null) {
      return true;
    }
    return obj.get('MailingCity') == null
      && obj.get('MailingPostalCode') == null
      && obj.get('MailingState') == null
      && obj.get('MailingStreet') == null;
  }

/**
 *	Did the address change
 *	@param SObject
 *	@param SObject
 *	@return Boolean
 */
	public static Boolean hasChanged(SObject newObj, SObject oldObj) {
		if (newObj == null || oldObj == null) {
			return false;
		}
		return newObj.get('City') != oldObj.get('City')
      || newObj.get('Country') != oldObj.get('Country')
      || newObj.get('Latitude') != oldObj.get('Latitude')
			|| newObj.get('Longitude') != oldObj.get('Longitude')
      || newObj.get('PostalCode') != oldObj.get('PostalCode')
			|| newObj.get('State') != oldObj.get('State')
			|| newObj.get('Street') != oldObj.get('Street');
	}

/**
 *	Did the address change
 *	@param System.Address
 *	@param System.Address
 *	@return Boolean
 */
	public static Boolean hasChanged(System.Address newAddr, System.Address oldAddr) {
		if (newAddr == null || oldAddr == null) {
			return false;
		}
		return newAddr.getCity() != oldAddr.getCity()
      || newAddr.getCountry() != oldAddr.getCountry()
      || newAddr.getCountryCode() != oldAddr.getCountryCode()
      || newAddr.getLatitude() != oldAddr.getLatitude()
      || newAddr.getLongitude() != oldAddr.getLongitude()
      || newAddr.getPostalCode() != oldAddr.getPostalCode()
			|| newAddr.getState() != oldAddr.getState()
			|| newAddr.getStateCode() != oldAddr.getStateCode()
			|| newAddr.getStreet() != oldAddr.getStreet();
	}
}
