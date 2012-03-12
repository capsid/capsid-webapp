$ ->
	$('#sample_filter').keypress( ->
		$.getJSON('/capsid/project/list.json', (data) ->
			console.log(data)
		)
	)
	$('.popover_item').popover(
		html: true,
		delay: show:500, hide: 100
	)
