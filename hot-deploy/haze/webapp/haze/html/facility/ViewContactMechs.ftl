<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<div>
  <#if contactMeches?has_content>
    <table class="basic-table" cellspacing="0" style="width: 100%;">
      <#list contactMeches as contactMechMap>
          <#assign contactMech = contactMechMap.contactMech>
          <#assign facilityContactMech = contactMechMap.facilityContactMech>
          <tr><td colspan="3"><hr/></td></tr>
          <tr>
            <td class="label" valign="top">
            	<label class="col-md-2 control-label" style="color: black; font-size: 13px;">${contactMechMap.contactMechType.get("description",locale)}</label>
            </td>
            <td valign="top">
              <#list contactMechMap.facilityContactMechPurposes as facilityContactMechPurpose>
                  <#assign contactMechPurposeType = facilityContactMechPurpose.getRelatedOneCache("ContactMechPurposeType")>
                      <#if contactMechPurposeType?has_content>
                        <b>${contactMechPurposeType.get("description",locale)}</b>
                      <#else>
                        <b>${uiLabelMap.ProductPurposeTypeNotFoundWithId}: "${facilityContactMechPurpose.contactMechPurposeTypeId}"</b>
                      </#if>
                      <#if facilityContactMechPurpose.thruDate?has_content>
                      (${uiLabelMap.CommonExpire}: ${facilityContactMechPurpose.thruDate.toString()})
                      </#if>
                      <br />
              </#list>
              <#if "POSTAL_ADDRESS" = contactMech.contactMechTypeId>
                  <#assign postalAddress = contactMechMap.postalAddress>
                    ${setContextField("postalAddress", postalAddress)}
                    <#--${screens.render("component://party/widget/partymgr/PartyScreens.xml#postalAddressHtmlFormatter")}-->
                    <#assign fulladdress = Static['com.zuczug.party.ZuczugPartyUtil'].getPostalAddressString(delegator, postalAddress,nullAgr,false)?if_exists/>
                    ${(fulladdress.fullAddress)!} ${uiLabelMap.ContactPeople}：${(postalAddress.toName)!}
                    <#if postalAddress.geoPointId?has_content>
                      <#if contactMechPurposeType?has_content>
                        <#assign popUptitle = contactMechPurposeType.get("description", locale) + uiLabelMap.CommonGeoLocation>
                      </#if>
                      
                      <a class="btn btn-primary" href="javascript:popUp('<@ofbizUrl>PartyGeoLocation?geoPointId=${postalAddress.geoPointId}&partyId=${partyId}</@ofbizUrl>', '${popUptitle?if_exists}', '450', '550')">${uiLabelMap.CommonGeoLocation}</a>
                      
                      <#!--<a href="javascript:popUp('<@ofbizUrl>PartyGeoLocation?geoPointId=${postalAddress.geoPointId}&partyId=${partyId}</@ofbizUrl>', '${popUptitle?if_exists}', '450', '550')" class="buttontext">${uiLabelMap.CommonGeoLocation}</a> -->
                    </#if>
              <#elseif "TELECOM_NUMBER" = contactMech.contactMechTypeId>
                  <#assign telecomNumber = contactMechMap.telecomNumber>
                    ${telecomNumber.countryCode?if_exists}
                    <#if telecomNumber.areaCode?has_content>${telecomNumber.areaCode}-</#if>${telecomNumber.contactNumber?if_exists}
                    <#if facilityContactMech.extension?has_content>${uiLabelMap.CommonExt} ${facilityContactMech.extension}</#if>
              <#elseif "EMAIL_ADDRESS" = contactMech.contactMechTypeId>
                    ${contactMech.infoString?if_exists}
              <#elseif "WEB_ADDRESS" = contactMech.contactMechTypeId>
                    ${contactMech.infoString?if_exists}
                    <#assign openAddress = contactMech.infoString?default("")>
                    <#if !openAddress?starts_with("http") && !openAddress?starts_with("HTTP")><#assign openAddress = "http://" + openAddress></#if>
              <#else>
                    ${contactMech.infoString?if_exists}
              </#if>
              <br />(${uiLabelMap.CommonUpdated}: ${facilityContactMech.fromDate.toString()})
              <#if facilityContactMech.thruDate?has_content><br /><b>${uiLabelMap.CommonUpdatedEffectiveThru}:&nbsp;${facilityContactMech.thruDate.toString()}</b></#if>
            </td>
            <td class="button-col">
              &nbsp;
              <#if security.hasEntityPermission("FACILITY", "_UPDATE", session)>
                <#--<a href='<@ofbizUrl>facility.EditContactMech?facilityId=${facilityId}&amp;contactMechId=${contactMech.contactMechId}</@ofbizUrl>'>${uiLabelMap.CommonUpdate}</a> -->
                <a class="btn btn-primary" href="<@ofbizUrl>facility.EditContactMech?facilityId=${facilityId}&amp;contactMechId=${contactMech.contactMechId}</@ofbizUrl>">${uiLabelMap.CommonUpdate}</a>
                
              </#if>
              <#if security.hasEntityPermission("FACILITY", "_DELETE", session)>
              	<a class="btn btn-primary" href="javascript:document.deleteContactForm_${contactMechMap_index}.submit()">${uiLabelMap.CommonExpire}</a>
                <#-- <a href="javascript:document.deleteContactForm_${contactMechMap_index}.submit()">${uiLabelMap.CommonExpire}</a> -->
                <form action="<@ofbizUrl>facility.deleteContactMech</@ofbizUrl>" name="deleteContactForm_${contactMechMap_index}" method="post">
                  <input type="hidden" name="facilityId" value="${facilityId?if_exists}"/>
                  <input type="hidden" name="contactMechId" value="${contactMech.contactMechId?if_exists}"/>
                </form>
              </#if>
            </td>
          </tr>
      </#list>
    </table>
  <#else>
    <div class="screenlet-body">${uiLabelMap.CommonNoContactInformationOnFile}.</div>
  </#if>
</div>
