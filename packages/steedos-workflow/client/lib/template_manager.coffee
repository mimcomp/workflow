TemplateManager = {};

formId = 'instanceform';


TemplateManager.handleTableTemplate = (instance) ->

	pageTitle = """
		{{instance.name}}
	"""

	pageTitleTrClass = "instance-name"

	if CoreForm?.pageTitleFieldName
		pageTitle = """
				{{> afFormGroup name="#{CoreForm.pageTitleFieldName}" label=false}}
		"""
		pageTitleTrClass = ""

	if CoreForm?.pageTitle
		pageTitle = """
			#{CoreForm.pageTitle}
		"""
		pageTitleTrClass = ""

	template = """
	<div class='instance-template'>
		<table class="table-page-title form-table no-border text-align-center" style="width: 100%;display: inline-table;">
			<tr class="#{pageTitleTrClass}">
				<td class="instance-table-name-td page-title">
					#{pageTitle}
				</td>
			</tr>

        </table>
		<table class="table-page-body form-table">
			    <tr style="height:0px">
					<th style='width: 16%'></th>
					<th></th>
					<th style='width: 16%'></th>
					<th></th>
				</tr>
	""";

	table_fields = InstanceformTemplate.helpers.table_fields(instance)

	table_fields.forEach (table_field)->

		required = ""
		if !CoreForm?.pageTitleFieldName || CoreForm?.pageTitleFieldName != table_field.code
			if table_field.is_required
				required = "is-required"

			if InstanceformTemplate.helpers.isOpinionField(table_field)
				template += table_field.tr_start
				template += """
					<td class="td-title #{required}">
						{{afFieldLabelText name="#{table_field.code}"}}
					</td>
					<td class="td-field opinion-field opinion-field-#{table_field.code}" colspan = "#{table_field.td_colspan}">
						{{> instanceSignText name="#{table_field.code}" step="#{InstanceformTemplate.helpers.getOpinionFieldStepName(table_field)}" only_cc_opinion=#{InstanceformTemplate.helpers.showCCOpinion(table_field)} }}
					</td>
				"""
				template += table_field.tr_end
			else
				if InstanceformTemplate.helpers.includes(table_field.type, 'section,table')
					template += table_field.tr_start
					template += """
						<td class="td-childfield td-childfield-#{table_field.code}" colspan = "#{table_field.td_colspan}">
						   {{> afFormGroup name="#{table_field.code}" label=false}}
						</td>
					"""
					template += table_field.tr_end
				else
					template += table_field.tr_start
					template += """
						<td class="td-title td-title-#{table_field.code} #{required}">
							{{afFieldLabelText name="#{table_field.code}"}}
						</td>
						<td class="td-field td-field-#{table_field.code} #{table_field.permission}" colspan = "#{table_field.td_colspan}">
							{{> afFormGroup name="#{table_field.code}" label=false}}
						</td>
					"""
					template += table_field.tr_end

	template += """
		</table>

		<table class="table-page-footer form-table no-border">
			<tr class="applicant-wrapper">
				<td class="nowrap">
					<div class='inline-left'>
						<label class="control-label">{{_t "instance_initiator"}}：</label>
					</div>
					<div class='instance-table-wrapper-td inline-left'>
						{{>Template.dynamic  template="afSelectUser" data=applicantContext}}
					</div>
				</td>
				<td class="nowrap">
					<div class='pull-left'>
						<div class='inline-left'>
							<label>{{_t "instance_submit_date"}}：</label>
						</div>
						<div class='inline-right'>
							<div class="form-group">
								{{formatDate instance.submit_date '{"format":"YYYY-MM-DD"}'}}
							</div>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</div>
	"""
	return template

#此处模板公用与：instance 编辑、查看、打印、转发时生成附件、发送邮件body部分(table 模板)
#如果有修改，请测试确认其他功能是否正常。
TemplateManager._template =
	default: '''
		<div class="box-header  with-border">
			<div class="instance-name">
				<h3 class="box-title">{{instance.name}}</h3>
            	<span class="help-block"></span>
			</div>
            <div class="applicant-wrapper">
                <label class="control-label">{{_t "instance_initiator"}}&nbsp;:</label>
                {{>Template.dynamic  template="afSelectUser" data=applicantContext}}
            </div>
            <span class="help-block"></span>
        </div>
		{{#each steedos_form.fields}}
			{{#if isOpinionField this}}
				<div class="{{#if this.is_wide}}col-md-12{{else}}col-md-6{{/if}}">
					<div class="form-group opinion-field">
						<label class="control-label">{{afFieldLabelText name=this.code}}</label>

						{{> instanceSignText name=this.code step=(getOpinionFieldStepName this) only_cc_opinion=(showCCOpinion this) default=''}}
					</div>
				</div>
			{{else}}
				{{#if includes this.type 'section,table'}}
					<div class="col-md-12">
						{{> afFormGroup name=this.code label=false}}
					</div>
				{{else}}
					<div class="{{#if this.is_wide}}col-md-12{{else}}col-md-6{{/if}}">
					{{> afFormGroup name=this.code}}
					</div>
				{{/if}}
		    {{/if}}
		{{/each}}
	'''
	table: (instance)->
		return TemplateManager.handleTableTemplate(instance)
#	table: '''
#		<table class="box-header  with-border" style="width: 100%;display: inline-table;">
#			<tr class="instance-name">
#				<td class="instance-table-name-td">
#					<h3 class="box-title">{{instance.name}}</h3>
#					<span class="help-block"></span>
#				</td>
#			</tr>
#            <tr class="applicant-wrapper">
#				<td class="instance-table-wrapper-td">
#					<label class="control-label">{{_t "instance_initiator"}}&nbsp;:</label>
#					{{>Template.dynamic  template="afSelectUser" data=applicantContext}}
#				</td>
#			</tr>
#        </table>
#		<table class="form-table">
#		    {{#each table_fields}}
#				{{#if isOpinionField this}}
#					{{{tr_start}}}
#						<td class="td-title {{#if is_required}}is-required{{/if}}">
#							{{afFieldLabelText name=this.code}}
#						</td>
#						<td class="td-field opinion-field" colspan = '{{td_colspan}}'>
#							{{> instanceSignText step=(getOpinionFieldStepName this) default=''}}
#						</td>
#					{{{tr_end}}}
#				{{else}}
#					{{#if includes this.type 'section,table'}}
#						{{{tr_start}}}
#							<td class="td-childfield" colspan = '{{td_colspan}}'>
#							   {{> afFormGroup name=this.code label=false}}
#							</td>
#						{{{tr_end}}}
#					{{else}}
#						{{{tr_start}}}
#							<td class="td-title {{#if is_required}}is-required{{/if}}">
#								{{afFieldLabelText name=this.code}}
#							</td>
#							<td class="td-field {{permission}}" colspan = '{{td_colspan}}'>
#								{{> afFormGroup name=this.code label=false}}
#							</td>
#						{{{tr_end}}}
#					{{/if}}
#				{{/if}}
#
#		    {{/each}}
#		</table>
#	'''

TemplateManager._templateHelps =
	applicantContext: ->
		steedos_instance = WorkflowManager.getInstance();
		data = {
			name: 'ins_applicant',
			atts: {
				name: 'ins_applicant',
				id: 'ins_applicant',
				class: 'selectUser form-control',
				style: 'padding:6px 12px;width:140px;display:inline'
			}
		}
#		if not steedos_instance || steedos_instance.state != "draft"
		data.atts.disabled = true
		return data;

instanceId: ->
	return 'instanceform';#"instance_" + Session.get("instanceId");

form_types: ->
	if ApproveManager.isReadOnly()
		return 'disabled';
	else
		return 'method';

steedos_form: ->
	form_version = WorkflowManager.getInstanceFormVersion();
	if form_version
		return form_version

innersubformContext: (obj)->
	doc_values = WorkflowManager_format.getAutoformSchemaValues();
	obj["tableValues"] = if doc_values then doc_values[obj.code] else []
	obj["formId"] = formId;
	return obj;

instance: ->
	Session.get("change_date")
	if (Session.get("instanceId"))
		steedos_instance = WorkflowManager.getInstance();
		return steedos_instance;

equals: (a, b) ->
	return (a == b)

includes: (a, b) ->
	return b.split(',').includes(a);

fields: ->
	form_version = WorkflowManager.getInstanceFormVersion();
	if form_version
		return new SimpleSchema(WorkflowManager_format.getAutoformSchema(form_version));

doc_values: ->
	WorkflowManager_format.getAutoformSchemaValues();

instance_box_style: ->
	box = Session.get("box")
	if box == "inbox" || box == "draft"
		judge = Session.get("judge")
		if judge
			if (judge == "approved")
				return "box-success"
			else if (judge == "rejected")
				return "box-danger"
	ins = WorkflowManager.getInstance();
	if ins && ins.final_decision
		if ins.final_decision == "approved"
			return "box-success"
		else if (ins.final_decision == "rejected")
			return "box-danger"


TemplateManager.getTemplate = (instance, templateName) ->
	flow = db.flows.findOne(instance.flow);
	form = db.forms.findOne(instance.form);

	if templateName
		if templateName == 'table'
			return TemplateManager._template.table(instance)
		return TemplateManager._template[templateName]

	if Session?.get("instancePrint")
		if flow?.print_template
			return "<div class='instance-template'>" + flow.print_template + "</div>"
		else
			if flow?.instance_template
				return "<div class='instance-template'>" + flow.instance_template + "</div>"
			else
				return TemplateManager._template.table(instance)
	else
		if Steedos.isMobile()
			return TemplateManager._template.default

		if flow?.instance_template
			return "<div class='instance-template'>" + flow.instance_template + "</div>"

		if form?.instance_style
			if form.instance_style == 'table'
				return TemplateManager._template.table(instance)
			return TemplateManager._template[form.instance_style]
		else
			return TemplateManager._template.default

#TemplateManager.exportTemplate = (flowId) ->
#	template = TemplateManager.getTemplate(flowId);
#
#	flow = WorkflowManager.getFlow(flowId);
#
#	if flow?.instance_template
#		return template;
#
#	return template;

