$ ->
	$('.popover_item').popover(
		html: true,
		delay: show:500, hide: 100
	)

	$('#security').toggle( 
		->
			$(this).html('Public Project')	
			$("#private").val(false);
			$(".controls p").html('Project will be visable to all CaPSID users');
		->
			$(this).html('Private Project')
			$("#private").val(true);
			$(".controls p").html('Project will only be visable to users that are given access');
	)

	return
