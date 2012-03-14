$ ->
	$('.popover_item').popover(
		html: true,
		delay: show:500, hide: 100
	)

	$('#security').click( ->
		if $(this).hasClass('active')
			$(this).html('Private Project')
				   .addClass('active')
			$("#private").val(true);
			$(".controls p").html('Project will only be visable to users that are given access');
		else
			$(this).html('Public Project')
				   .removeClass('active')	
			$("#private").val(false);
			$(".controls p").html('Project will be visable to all CaPSID users');
	)

	return
