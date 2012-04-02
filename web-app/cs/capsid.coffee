$ ->
	($ "[rel=popover]").popover
		html: true,
		delay: show:300, hide: 100
	
	($ "[rel=tooltip]").tooltip
		delay: show:200, hide: 100


	($ 'div.btn-group[data-toggle-name=*]').each ->
		group = $ @
		form = group.parents('form').eq(0)
		name = group.attr 'data-toggle-name'
		hidden = ($ 'input[name="' + name + '"]', form)
		($ 'button', group).each ->
			button = $ @
			button.live 'click', ->
				button.siblings().removeClass 'active'
				button.addClass 'active'
				hidden.val button.val()
			
			if button.val() == hidden.val()
				button.addClass 'active'
		return

	
	# Bookmarks
	($ "#add-bookmark").click ->
		($ "#add-bookmark-modal input[name='title']").val(document.title)
		($ "#add-bookmark-modal input[name='address']").val(window.location.pathname + window.location.search)
	
	($ "#add-bookmark-modal form").submit ->
		uri = ($ @).attr('action') + '?' + ($ @).serialize()	
		$.post uri, (bookmark) ->
			($ '#bookmarks').append '<li><a href="' + bookmark.address + '"><i class="icon-bookmark"></i> ' + bookmark.title + '</a></li>'
			($ '#add-bookmark-modal').modal('hide')
		
		return false


	# SideBar
	($ ".sidebar .well.separator").click ->
		($ @).parent().parent().toggleClass 'use_sidebar'

	($ '#filter').keyup ->
		value = ($ @).val()
		if value
			($ '#items > li:not(:contains(' + value + '))').hide() 
			($ '#items > li:contains(' + value + ')').fadeIn('fast')
		else
			($ '#items > li').fadeIn('fast')


	# pjax
	if ($ '.pagination a').length
		($ '.pagination a').pjax('#results', {fragment: '#results', timeout: '2000'}).live('click')
	if ($ 'th a').length
		($ 'th a').pjax('#results', {fragment: '#results', timeout: '2000'}).live('click')
	if ($ '.external-filter').length
		($ '.external-filter').pjax('#results', {fragment: '#results', timeout: '2000'}).live('click')


	# UAC Form
	($ '#uac form').submit ->
		uri = ($ @).attr('action') + '&' + ($ @).serialize()
		id = ($ @).parents('.accordion-body').attr('id')
		$.post uri, (data) ->
			($ '#' + id + ' .user-list').append data
			
			($ '.search-query').each ->
				($ @).val('')
				s = ($ @).data('source')
				i = s.indexOf(data.username)
				s.splice(i, 1)
				($ @).data('source', s)

		return false

	($ '.content').delegate '.delete.close', 'click', ->
		parent = ($ @).parent()
		uri = ($ @).attr('href')
		$.post uri, (data) ->
			parent.fadeOut 'fast', -> 
				($ @).remove()
			($ '.search-query').each ->
				($ @).data('source').push(data.username)
		
		return false

	# Mapped Tabs
	if ($ '.nav-tabs').length
		tabs = ($ '.nav-tabs').find('li.ajax a')
		console.log tabs
		tabs.each ->
			tab = $ @
			$(tab.attr('href')).load tab.data('url'), -> 
				tab.removeClass 'disabled'
				tab.html tab.data 'loaded'
				($ '#blast').find('li').each ->
					link = $ @
					if link.data('tab') == tab.attr('href')
						contig = ($ '#contig-sequence').val()
						link.html '<a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?' + 
								  'PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&' +
								  'LINK_LOC=blasthome&QUERY=' + contig + '" ' + 
								  'target="_blank">BLAST Contig Sequence</a>'

	return
