$(function() {
  // Popovers
  $("[rel=popover]").popover({
    html: true,
    delay: {
      show: 300,
      hide: 100
    }
  });
  $("[rel=tooltip]").tooltip({
    delay: {
      show: 200,
      hide: 100
    }
  });

  // Pagination
  if ($('.pagination a').length) {
    $('.results').each(function () {
      var el, id;
      id = "#"+this.id;
      $(id).on('click', '.pagination a', function(e) {  
        $(id).load($(this).attr('href') + ' ' + id);
        return false;
      });
    });
  }
  if ($('th a').length) {
    $('.results').each(function () {
      var el, id;
      id = "#"+this.id;
      $(id).on('click', 'th a', function(e) {  
        $(id).load($(this).attr('href') + ' ' + id);
        return false;
      });
    });
  }
});