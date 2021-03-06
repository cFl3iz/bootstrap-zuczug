<script language="javascript" type="text/javascript" src="/zuczugcommon/upload/plugins/imageupload/jQuery.upload.js"></script>
<div class="screenlet">
    <div class="screenlet-title-bar">
        <ul>
            <li class="h3">
				订单项信息            
			</li>	
        </ul>
        <br class="clear">
    </div>
    <table cellspacing="0" class="basic-table" style="width: 120%;">
			    <tbody>
			    <tr class="header-row-2">
				    <td>素然物料编号</td>
				    <td>供应商物料编号</td>
				    <td>序列号</td>
				    <td>物料名称</td>
			    	<td>组别</td>
				    <td>供应商</td>
				    <td>规格</td>
				    <td>采购数量</td>
				    <td>单位</td>
				    <td>单价</td>
				    <td>已接收数量</td>
				    <td>预计到货日期</td>
				    <#--
				    <td>接收数量</td>
				    <td>库位</td>
				    <td>批号</td>
				    -->
				    <td>备注</td>
				    <td>操作</td>
				    <td width="150">上传码单</td>
			    </tr>
    <#if oisgList?has_content>
    	<#assign totalQuantity=0 />
	        	<#assign totalAmount=0 />
		<#list oisgList as oisg>	
			<#assign itemList = delegator.findByAnd("OrderItemShipGroupAssoc", Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"shipGroupSeqId",oisg.shipGroupSeqId))?if_exists>
					
			    <#if itemList?has_content>
			    	<#list itemList as shipitem>
			    		<#assign orderItem = delegator.findByPrimaryKey("OrderItem", Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"orderItemSeqId",shipitem.orderItemSeqId))?if_exists>
			    		<#assign product = orderItem.getRelatedOne("Product")>
	    		<tr <#if shipitem_index%2==999>class="alternate-row"</#if>>
				    	
				    	<td>${Static["com.zuczug.product.ZuczugProductUtils"].getProductGoodIdentificationCode(delegator,product.productId,"ZUCZUG_CODE")}</td>
				    	<td>${Static["com.zuczug.product.ZuczugProductUtils"].getProductSupplierCode(delegator,product.productId,"")}</td>
				    	<td>${(orderItem.orderItemSeqId)!}</td>
					    <td>${(product.productName)!}</td>
					    <td>
					    	<#assign groupList = delegator.findByAnd("ProductDesignFeatureWithType", Static["org.ofbiz.base.util.UtilMisc"].toMap("productId",product.productId,"productFeatureTypeId","GROUPNAME"))?if_exists>
					    	<#if groupList?has_content>
					    		<#assign groupFeature = delegator.findByPrimaryKey("ProductFeature", Static["org.ofbiz.base.util.UtilMisc"].toMap("productFeatureId",groupList[0].productFeatureId))?if_exists>
					    		${(groupFeature.description)!}
					    	</#if>
					    </td>
					    <td>
					    	<#assign supplierGv = delegator.findByPrimaryKey("PartyGroup", Static["org.ofbiz.base.util.UtilMisc"].toMap("partyId",supplierId))?if_exists>
					    	${(supplierGv.groupName)!}
					    </td>
					   
					    <td>${(product.description)!}</td>
					    <td>
					    	${(shipitem.quantity)!}
					    		<!-- 数量 -->
						    	<input type="hidden" name="iqm_${(shipitem.orderItemSeqId)!}:${shipitem.shipGroupSeqId}" size="6" value="${(shipitem.quantity)!}">
					    </td>
					    <td>
					    	<#if product.quantityUomId?has_content>
						    	<#assign uomIdDesc='Uom.description.' + product.quantityUomId?if_exists />
						    	${(uiLabelMap[uomIdDesc])!}
					    	</#if>
					    </td>
					    <td>
					    	<@ofbizCurrency amount=orderItem.unitPrice isoCode=orderHeader.currencyUom/>
					    		<!-- 价格 -->
						    	<input type="hidden" size="8" name="ipm_${orderItem.orderItemSeqId}" value="${orderItem.unitPrice}"/>
					    </td>
					    <td>
					    	<#assign receiptQuantity=Static["com.zuczug.order.ZuczugOrderUtils"].getOrderItemShipReceiptedQuantity(delegator,parameters.orderId,orderItem.orderItemSeqId,shipitem.shipGroupSeqId)?if_exists />
				   			${(receiptQuantity)!}
							
					    </td>
					    <td>
					    	<!--如果更新Cancelled掉的点单项会引起报错 -->
					    	<#if orderItem.statusId != "ITEM_CANCELLED">
					    		<#-- 收货时间 
						    	<@htmlTemplate.renderDateTimeField name="isdm_${orderItem.orderItemSeqId}" value="${orderItem.estimatedShipDate?if_exists}" event="" action="" className="" alert="" title="Format: yyyy-MM-dd HH:mm:ss.SSS" size="25" maxlength="30" id="isdm_${orderItem.orderItemSeqId}" dateType="date" shortDateInput=false timeDropdownParamName="" defaultDateTimeString="" localizedIconTitle="" timeDropdown="" timeHourName="" classString="" hour1="" hour2="" timeMinutesName="" minutes="" isTwelveHour="" ampmName="" amSelected="" pmSelected="" compositeType="" formName=""/>
						    	-->
						    	<!-- 修改价格 -->
						    	<input type="hidden" size="8" name="opm_${orderItem.orderItemSeqId}" value="N"/>
						    	<!--预计到货时间-->
						    	<input type="hidden" name="isdm_${orderItem.orderItemSeqId}" value="${orderItem.estimatedShipDate?if_exists}" size="25" >
						    	
					    	</#if>
					    	${orderItem.estimatedShipDate?if_exists}							    	
					    </td>
					    <td>
							${(orderItem.comments)!}
						</td>
						<td>
							 <#assign itemStatusOkay = (orderItem.statusId != "ITEM_CANCELLED" && orderItem.statusId != "ITEM_COMPLETED")>
							 <#assign receiptQuantity=Static["com.zuczug.order.ZuczugOrderUtils"].getOrderItemShipReceiptedQuantity(delegator,orderItem.orderId,orderItem.orderItemSeqId,'')?if_exists />
							 
							 <#if ((security.hasEntityPermission("ORDERMGR", "_UPDATE", session)) && itemStatusOkay && orderHeader.statusId != "ORDER_SENT") || (security.hasEntityPermission("ORDERMGR", "_ADMIN", session) && itemStatusOkay)>
								<#if receiptQuantity gt 0>
									已收货${receiptQuantity}件
								<#else>
									<#if orderHeader.statusId == "ORDER_CREATED">
									<a href="javascript:document.updateItemInfo.action='<@ofbizUrl>cancelOrderItem</@ofbizUrl>';
									document.updateItemInfo.orderItemSeqId.value='${orderItem.orderItemSeqId}';
									document.updateItemInfo.shipGroupSeqId.value='${oisg.shipGroupSeqId}';
									document.updateItemInfo.submit()" class="buttontext">${uiLabelMap.CommonCancel}</a>
									</#if>
								</#if>								
							 <#else>
                                &nbsp;
                             </#if>
						</td>
						<td>
							<input type="file" name="uploadedFile" accept=".xls, .xlsx" id="file_md_${(orderItem.orderItemSeqId)!}_${(oisg.shipGroupSeqId)}" style="width:100px"/>
							<a href="javascript:;" onclick="uploadShipmentExcel('${(parameters.orderId)!}','${(orderItem.orderItemSeqId)!}','${(oisg.shipGroupSeqId)}')" class="buttontext">上传</a>
							<#assign shipFile=delegator.findByAnd("OrderItemShipContentView",Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"orderItemSeqId",orderItem.orderItemSeqId,"shipGroupSeqId",oisg.shipGroupSeqId,"orderContentTypeId","DELIVERY_NOTE"))?if_exists/>
							<#if shipFile?has_content>
								<span id="span_md_${(orderItem.orderItemSeqId)!}_${(oisg.shipGroupSeqId)}">
									<a href="downloadFile?dataResourceId=${(shipFile[0].dataResourceId)!}" title="${(shipFile[0].dataResourceName)!}">下载码单</a>
								</span>
							</#if>
                        </td>
					   	</tr>
					   	 <#assign totalAmount=totalAmount+orderItem.unitPrice*shipitem.quantity />
		            	<#assign totalQuantity=totalQuantity+shipitem.quantity />
			    	</#list>
			    </#if>			    
			
		</#list>
		</tbody>
			</table>
	</#if>
	<div>
		
		${uiLabelMap.Sumtotal}：
		总数量:${(totalQuantity)!}
		总价格:<@ofbizCurrency amount=totalAmount isoCode=cart.getCurrency()/>
	
	</div>
</div>   
 
<div class="screenlet">
    <div class="screenlet-title-bar">
        <ul>
            <li class="h3">
				货运组列表
            </li>	
        	<li><a href="<@ofbizUrl>FindFabricPurchaseItem?purchaseType=${purchaseType}&amp;orderId=${(parameters.orderId)!}</@ofbizUrl>">结束编辑</a></li>
        </ul>
        <br class="clear">
    </div>
	<#if oisgList?has_content>
		<#list oisgList as oisg>
			<form method="post" action="<@ofbizUrl>updateOrderItems</@ofbizUrl>" name="updateItemInfo" class="basic-form">
		    <input type="hidden" name="orderId" value="${(orderHeader.orderId)!}">
		    <input type="hidden" name="supplierPartyId" value="${(supplierId)!}">
		    <input type="hidden" name="orderTypeId" value="${(orderHeader.orderTypeId)!}">
		    <input type="hidden" name="orderItemSeqId">
		    <input type="hidden" name="shipGroupSeqId">
		    <input type="hidden" name="purchaseType" value="${purchaseType}">
			<#assign itemList = delegator.findByAnd("OrderItemShipGroupAssoc", Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"shipGroupSeqId",oisg.shipGroupSeqId))?if_exists>
			<#if oisg.facilityId?has_content>
				<#assign facility = oisg.getRelatedOne("Facility")>
			<#else>
				<#assign facility = orderHeader.getRelatedOne("OriginFacility")>
			</#if>
			
			
			<b>货运组 ${(oisg_index+1)!} / 
			接受仓库：
			<select name="oisg_${(oisg.shipGroupSeqId)!}">
				<#list facilityList as f>
					<option value="${(f.facilityId)!}" <#if facility.facilityId==f.facilityId>selected</#if>>${(f.facilityName)!}</option>
				</#list>
			</select>
			
			 / 预计到货日期：
			 <#if oisg.estimatedShipDate?has_content><#assign thisDate=(oisg.estimatedShipDate)?string('yyyy-MM-dd hh:mm:ss') /></#if>
			<@htmlTemplate.renderDateTimeField name="oisgEstDate_${(oisg.shipGroupSeqId)!}" value="${(thisDate)!}" event="" action="" className="" alert="" title="Format: yyyy-MM-dd HH:mm:ss.SSS" size="25" maxlength="30" id="oisgEstDate_${(oisg.shipGroupSeqId)!}" dateType="date" shortDateInput=false timeDropdownParamName="" defaultDateTimeString="" localizedIconTitle="" timeDropdown="" timeHourName="" classString="" hour1="" hour2="" timeMinutesName="" minutes="" isTwelveHour="" ampmName="" amSelected="" pmSelected="" compositeType="" formName=""/>
			 </b>
			<div id="searchOptions_col" class="screenlet-body" style="border-bottom: #9d9d9b thin solid;overflow-y: auto;">
			<div id="search-options">
			<table cellspacing="0" class="basic-table" style="width: 120%;">
			    <tbody>
			    <tr class="header-row-2">
				    <td>素然物料编号</td>
				    <td>供应商物料编号</td>
				    <td>序列号</td>
				    <td>物料名称</td>
			    	<td>组别</td>
				    <td>供应商</td>
				    <td>规格</td>
				    <td>采购数量</td>
				    <td>单位</td>
				    <td>单价</td>
				    <td>已接收数量</td>
				    <td>预计到货日期</td>
				    <#--
				    <td>接收数量</td>
				    <td>库位</td>
				    <td>批号</td>
				    -->
				    <td>备注</td>
				    <td>操作</td>
				    <td width="150">上传码单</td>
			    </tr>
			    <#if itemList?has_content>
			    	<#list itemList as shipitem>
			    		<#assign orderItem = delegator.findByPrimaryKey("OrderItem", Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"orderItemSeqId",shipitem.orderItemSeqId))?if_exists>
			    		<#assign product = orderItem.getRelatedOne("Product")>
	    		<tr <#if shipitem_index%2==999>class="alternate-row"</#if>>
				    	
				    	<td>${Static["com.zuczug.product.ZuczugProductUtils"].getProductGoodIdentificationCode(delegator,product.productId,"ZUCZUG_CODE")}</td>
				    	<td>${Static["com.zuczug.product.ZuczugProductUtils"].getProductSupplierCode(delegator,product.productId,"")}</td>
				    	<td>${(orderItem.orderItemSeqId)!}</td>
					    <td>${(product.productName)!}</td>
					    <td>
					    	<#assign groupList = delegator.findByAnd("ProductDesignFeatureWithType", Static["org.ofbiz.base.util.UtilMisc"].toMap("productId",product.productId,"productFeatureTypeId","GROUPNAME"))?if_exists>
					    	<#if groupList?has_content>
					    		<#assign groupFeature = delegator.findByPrimaryKey("ProductFeature", Static["org.ofbiz.base.util.UtilMisc"].toMap("productFeatureId",groupList[0].productFeatureId))?if_exists>
					    		${(groupFeature.description)!}
					    	</#if>
					    </td>
					    <td>
					    	<#assign supplierGv = delegator.findByPrimaryKey("PartyGroup", Static["org.ofbiz.base.util.UtilMisc"].toMap("partyId",supplierId))?if_exists>
					    	${(supplierGv.groupName)!}
					    </td>
					   
					    <td>${(product.description)!}</td>
					    <td>
					    	<#if orderHeader.statusId == "ORDER_CREATED">
					    	<!-- 数量 -->
					    	<input type="text" name="iqm_${(shipitem.orderItemSeqId)!}:${shipitem.shipGroupSeqId}" size="6" value="${(shipitem.quantity)!}">
					    	<#else>
					    		${(shipitem.quantity)!}
					    		<!-- 数量 -->
						    	<input type="hidden" name="iqm_${(shipitem.orderItemSeqId)!}:${shipitem.shipGroupSeqId}" size="6" value="${(shipitem.quantity)!}">
					    	</#if>
					    </td>
					    <td>
					    	<#if product.quantityUomId?has_content>
						    	<#assign uomIdDesc='Uom.description.' + product.quantityUomId?if_exists />
						    	${(uiLabelMap[uomIdDesc])!}
					    	</#if>
					    </td>
					    <td>
					    	<#if orderHeader.statusId == "ORDER_CREATED">
					    		<!-- 价格 -->
					    		<input type="text" size="8" name="ipm_${orderItem.orderItemSeqId}" value="${orderItem.unitPrice}"/>
					    	<#else>
					    		<@ofbizCurrency amount=orderItem.unitPrice isoCode=orderHeader.currencyUom/>
					    		<!-- 价格 -->
						    	<input type="hidden" size="8" name="ipm_${orderItem.orderItemSeqId}" value="${orderItem.unitPrice}"/>
					    	</#if>
					    </td>
					    <td>
					    	<#assign receiptQuantity=Static["com.zuczug.order.ZuczugOrderUtils"].getOrderItemShipReceiptedQuantity(delegator,parameters.orderId,orderItem.orderItemSeqId,shipitem.shipGroupSeqId)?if_exists />
				   			${(receiptQuantity)!}
							
					    </td>
					    <td>
					    	<!--如果更新Cancelled掉的点单项会引起报错 -->
					    	<#if orderItem.statusId != "ITEM_CANCELLED">
					    		<#-- 收货时间 
						    	<@htmlTemplate.renderDateTimeField name="isdm_${orderItem.orderItemSeqId}" value="${orderItem.estimatedShipDate?if_exists}" event="" action="" className="" alert="" title="Format: yyyy-MM-dd HH:mm:ss.SSS" size="25" maxlength="30" id="isdm_${orderItem.orderItemSeqId}" dateType="date" shortDateInput=false timeDropdownParamName="" defaultDateTimeString="" localizedIconTitle="" timeDropdown="" timeHourName="" classString="" hour1="" hour2="" timeMinutesName="" minutes="" isTwelveHour="" ampmName="" amSelected="" pmSelected="" compositeType="" formName=""/>
						    	-->
						    	<!-- 修改价格 -->
						    	<input type="hidden" size="8" name="opm_${orderItem.orderItemSeqId}" value="N"/>
						    	<!--预计到货时间-->
						    	<input type="hidden" name="isdm_${orderItem.orderItemSeqId}" value="${orderItem.estimatedShipDate?if_exists}" size="25" >
						    	
					    	</#if>
					    	${orderItem.estimatedShipDate?if_exists}							    	
					    </td>
					    <td>
							${(orderItem.comments)!}
						</td>
						<td>
							 <#assign itemStatusOkay = (orderItem.statusId != "ITEM_CANCELLED" && orderItem.statusId != "ITEM_COMPLETED")>
							 <#assign receiptQuantity=Static["com.zuczug.order.ZuczugOrderUtils"].getOrderItemShipReceiptedQuantity(delegator,orderItem.orderId,orderItem.orderItemSeqId,'')?if_exists />
							 
							 <#if ((security.hasEntityPermission("ORDERMGR", "_UPDATE", session)) && itemStatusOkay && orderHeader.statusId != "ORDER_SENT") || (security.hasEntityPermission("ORDERMGR", "_ADMIN", session) && itemStatusOkay)>
								<#if receiptQuantity gt 0>
									已收货${receiptQuantity}件
								<#else>
									<#if orderHeader.statusId == "ORDER_CREATED">
									<a href="javascript:document.updateItemInfo.action='<@ofbizUrl>cancelOrderItem</@ofbizUrl>';
									document.updateItemInfo.orderItemSeqId.value='${orderItem.orderItemSeqId}';
									document.updateItemInfo.shipGroupSeqId.value='${oisg.shipGroupSeqId}';
									document.updateItemInfo.submit()" class="buttontext">${uiLabelMap.CommonCancel}</a>
									</#if>
								</#if>								
							 <#else>
                                &nbsp;
                             </#if>
						</td>
						<td>
							<input type="file" name="uploadedFile" accept=".xls, .xlsx" id="file_md_${(orderItem.orderItemSeqId)!}_${(oisg.shipGroupSeqId)}" style="width:100px"/>
							<a href="javascript:;" onclick="uploadShipmentExcel('${(parameters.orderId)!}','${(orderItem.orderItemSeqId)!}','${(oisg.shipGroupSeqId)}')" class="buttontext">上传</a>
							<#assign shipFile=delegator.findByAnd("OrderItemShipContentView",Static["org.ofbiz.base.util.UtilMisc"].toMap("orderId",parameters.orderId,"orderItemSeqId",orderItem.orderItemSeqId,"shipGroupSeqId",oisg.shipGroupSeqId,"orderContentTypeId","DELIVERY_NOTE"))?if_exists/>
							<#if shipFile?has_content>
								<span id="span_md_${(orderItem.orderItemSeqId)!}_${(oisg.shipGroupSeqId)}">
									<a href="downloadFile?dataResourceId=${(shipFile[0].dataResourceId)!}" title="${(shipFile[0].dataResourceName)!}">下载码单</a>
								</span>
							</#if>
                        </td>
					   	</tr>
			    	</#list>
			    </#if>			    
			</tbody>
			</table>
			</div>
			</div>
			<input name="submitBtn" value="保存货运组${(oisg_index+1)!}" type="submit">
			</form>
			<br/>
		</#list>
	</#if>
</div>
<#if orderHeader.statusId == "ORDER_CREATED">
<div id="screenlet_4_col" class="screenlet">
	<div class="screenlet-title-bar">
        <ul>
            <li class="h3">
                ${uiLabelMap.AddProductItem}
            </li>
        </ul>
        <br class="clear">
    </div>
    <form method="post" action="<@ofbizUrl>appendItemToOrder</@ofbizUrl>" id="appendItemForm" name="appendItemForm" onsubmit="return validateAndSubmit()">
    	<input type="hidden" name="MODE" value="ADD_ITEM"/>
    	<input type="hidden" name="orderId" value="${(orderHeader.orderId)!}"/>
    	    	<input name="purchaseType" type="hidden" value="${purchaseType}"/>
    	
    	<table cellspacing="0" class="basic-table">
		    <tbody>
		    <tr>
		        <td class="label">${uiLabelMap.SelectProduct}：</td>
	            <td>
	            	<#if "ACCESSORY_PURCHASE" == purchaseType >
	            			<input type="hidden" name="productId" id="productId"/>
	            			<@htmlTemplate.lookupField formName="appendItemForm" name="idValue" fieldFormName="lookupVirtualProductByParty?supplierId=${(supplierId)!}" descriptionFieldName="productId" className="required" size="20" maxlength="40"/>	            		
	            	<#else>
	            			<@htmlTemplate.lookupField formName="appendItemForm" name="productId" fieldFormName="lookupRealProductNotVirtual" className="required" size="20" maxlength="40"/>
	            		
	            	</#if>
	            </td>
	            <td class="label">数量（米）：</td>
	            <td><input type="text" name="quantity" class="required integerNumber"/></td>
	        </tr>
	        <tr>
	        	<td class="label">${uiLabelMap.UnitPrice}：</td>
	            <td><input type="text" name="basePrice" class="required integerNumber"/></td>
	            <td class="label">${uiLabelMap.Quantity}（<span id="secUomId">计量单位载入中……</span>）：</td>
	            <td>
	            	<input type="text" name="secQuantity" class="integerNumber"/>
	            	<input type="hidden" name="secUom" id="secUom"/>
	            </td>
	        </tr>
	        <tr>
		        <td class="label">预计到货时间：</td>
		        <td>
		            <@htmlTemplate.renderDateTimeField name="estimatedShipDate" event="" action="" value="${(session.getAttribute('estimatedShipDateStr'))!}" className="" alert="" title="" size="25" maxlength="30" id="estimatedShipDate" dateType="date" shortDateInput=true timeDropdownParamName="" defaultDateTimeString="" localizedIconTitle="" timeDropdown="" timeHourName="" classString="" hour1="" hour2="" timeMinutesName="" minutes="" isTwelveHour="" ampmName="" amSelected="" pmSelected="" compositeType="" formName=""/>
		        	<script>
		        	$(function(){
		        		$("#estimatedShipDate_i18n").addClass("required");
		        	});
		        	</script>
		        	
		        </td>  
		    </tr>			
		    </tbody>
		</table>
		<input name="shipGroupSeqId" type="hidden" value="1"/>
		<input name="submitBtn" value="新建" type="submit">
	</form>
    </div>
</div>


<#-- 添加服务项部分 -->
<div class="screenlet">
    <div class="screenlet-title-bar">
        <ul>
            <li class="h3">
                添加服务
            </li>
        </ul>
        <br class="clear">
    </div>
    <div id="screenlet_4_col" class="screenlet-body">
    <form method="post" action="<@ofbizUrl>appendItemToOrder</@ofbizUrl>" id="addServiceForm" name="addServiceForm">
    	<input name="shipGroupSeqId" type="hidden" value="1"/>
    	<input name="purchaseType" type="hidden" value="${purchaseType}"/>
    	<input type="hidden" name="orderId" value="${(orderHeader.orderId)!}"/>
    	<table cellspacing="0" class="basic-table">
		    <tbody>
		    <tr>
		        <td class="label">选择服务：</td>
	            <td>
	            	<select name="productId">
	            		<option>-请选择-</option>
	            		<#if serviceList?has_content>
	            		<#list serviceList as product>
	            			<option value="${(product.productId)!}">${(product.productName)!}</option>
	            		</#list>
	            		</#if>
	            	</select>
	            </td>
	            <td class="label">金额：</td>
	            <td>
	            	<input type="text" name="basePrice" class="required integerNumber"/>
	            	<input type="hidden" name="quantity" value="1"/>
	            </td>
	            <td class="label">
					<input type="submit" value="${uiLabelMap.CommonAdd}"/>
				</td>
	        </tr>
		    </tbody>
		</table>
	</form>
    </div>
</div>

</#if>
<script>
		jQuery("#addItemForm").validate({
	     	submitHandler:
	         	function(form) {
	         	form.submit();
	    	 }
		});
		
		jQuery("#addServiceForm").validate({
		     submitHandler:
		         function(form) {
		         form.submit();
		     }
		});
	
		$("input[name='productId']").bind('input', function(){
		getProductInfo();
	    });
	    
	    $("input[name='productId']").bind('propertychange', function(){
			getProductInfo();
	    });
	    
	    $("input[name='productId']").bind('blur', function(){
			getProductInfo();
	    });
		
	function getProductInfo(){
		if($("input[name='productId']").val()!=""){
			$.post("<@ofbizUrl>findProductMasterUomId</@ofbizUrl>",{'productId':$("input[name='productId']").val()},function(result){
				if("uom" in result){
					$("#secUomId").text(result['uom'].abbreviation);
					$("#secUom").val(result['uom'].abbreviation);
					
				}else{
					$("#secUomId").text("无");
				}
			});
		}
	}
	
	function uploadShipmentExcel(orderId,orderItemSeqId,shipGroupSeqId){
		var fileId="file_md_"+orderItemSeqId+"_"+shipGroupSeqId;
		if($("#"+fileId).val().length <= 0){
			showErrorAlert("提示","必须选择文件才可以提交");
			return false;
		}
		$("#"+fileId).upload({
		    action: "<@ofbizUrl>uploadShipGroupDetailExcel</@ofbizUrl>",
		    data:{
		    	orderId:orderId,
		    	orderItemSeqId:orderItemSeqId,
		    	shipGroupSeqId:shipGroupSeqId
		    },
		    oncomplete:function(result){
		    	if("dataResource" in result){
		    		alert(result['_EVENT_MESSAGE_']);
		    		window.location.reload();
		    	}else{
		    		showErrorAlert("错误",result['_ERROR_MESSAGE_']);
		    	}
		    }
		});
	}
	
	function validateAndSubmit(){
		var productId = $("input[name='productId']").val();
		var quantity = $("input[name='quantity']").val();
		if(productId == "" || quantity == "") {
			alert("物料,数量为必填项，请返回选择");
			return false;
		} else {
			return true;
		}
	}
</script>