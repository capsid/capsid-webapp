$ ->
	($ "[rel=popover]").popover
		html: true,
		delay: show:300, hide: 100
	
	($ "[rel=tooltip]").tooltip
		delay: show:200, hide: 100

	($ 'div.btn-group[data-toggle-name=*]').each ->
		group = $(this);
		form = group.parents('form').eq(0);
		name = group.attr('data-toggle-name');
		hidden = $('input[name="' + name + '"]', form);
		$('button', group).each ->
			button = $(this);
			button.live('click', ->
				hidden.val $(this).val()
			)
			if button.val() == hidden.val()
				button.addClass 'active'
		return

	($ ".modal").delegate(".btn-group[data-toggle='buttons-radio'] .btn", "click", ->
		button = $ @
		group = button.parents '.btn-group'
		field = group.data 'toggle-name'
		hidden = $ 'input[name="is_private"]'
		button.siblings().removeClass 'active'
		button.addClass 'active'
		hidden.val button.val()
	)

	($ "a[data-toggle='modal']").click -> 
		target = ($ @).attr 'data-target'
		url = ($ @).attr 'href'
		($ target + ' .modal-body').load url + ' #ajax', ->
			($ "[rel=tooltip]").tooltip
			delay: show:500, hide: 100
	
	($ ".sidebar .well.separator").click ->
		($ @).parent().parent().toggleClass 'use_sidebar'

	$('.pagination a, th a').pjax('#results', {fragment: '#results'}).live('click')

	($ '#filter').keyup ->
		value = ($ @).val()
		if value
			($ '#items > li:not(:contains(' + value + '))').hide() 
			($ '#items > li:contains(' + value + ')').fadeIn('fast')
		else
			($ '#items > li').fadeIn('fast')

	return
