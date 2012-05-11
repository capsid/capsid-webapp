$(function() {
  // Popover
  $("[rel=popover]").popover({
    html: true,
    delay: {
      show: 300,
      hide: 100
    }
  });
  // Tooltip
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

  // Radio Button Groups
  $('div.btn-group[data-toggle-name=*]').each(function() {
    var form, group, hidden, name;
    group = $(this);
    form = group.parents('form').eq(0);
    name = group.attr('data-toggle-name');
    hidden = $('input[name="' + name + '"]', form);
    $('button', group).each(function() {
      var button;
      button = $(this);
      button.live('click', function() {
        button.siblings().removeClass('active');
        button.addClass('active');
        hidden.val(button.val());
      });
      if (button.val() === hidden.val()) button.addClass('active');
    });
  });

  // Bookmarks
  $("#add-bookmark").click(function() {
    $("#add-bookmark-modal input[name='title']").val(document.title);
    $("#add-bookmark-modal input[name='address']").val(window.location.pathname + window.location.search);
  });
  $("#add-bookmark-modal form").submit(function() {
    var uri;
    uri = $(this).attr('action') + '?' + $(this).serialize();
    $.post(uri, function(bookmark) {
      $('#bookmarks').append('<li><a href="' + bookmark.address + '"><i class="icon-bookmark"></i> ' + bookmark.title + '</a></li>');
      $('#add-bookmark-modal').modal('hide');
    });
    return false;
  });

  /* Sidebar */
  $(".sidebar .well.separator").click(function() {
    $(this).parent().parent().toggleClass('use_sidebar');
  });

  // User Access Contorl Form
  $('#uac form').submit(function() {
    var id, uri;
    uri = $(this).attr('action') + '&' + $(this).serialize();
    id = $(this).parents('.accordion-body').attr('id');
    $.post(uri, function(data) {
      $('#' + id + ' .user-list').append(data);
      $('.search-query').each(function() {
        var i, s;
        $(this).val('');
        s = $(this).data('source');
        i = s.indexOf(data.username);
        s.splice(i, 1);
        $(this).data('source', s);
      });
    });
    return false;
  });
  // User list
  $('.content').delegate('.delete.close', 'click', function() {
    var parent, uri;
    parent = $(this).parent();
    uri = $(this).attr('href');
    $.post(uri, function(data) {
      parent.fadeOut('fast', function() {
        $(this).remove();
      });
      $('.search-query').each(function() {
        $(this).data('source').push(data.username);
      });
    });
    return false;
  });

  // BLAST Ajax tabs
  if ($('.nav-tabs').length) {
    tabs = ($('.nav-tabs')).find('li.ajax a');
    tabs.each(function() {
      var tab;
      tab = $(this);
      $(tab.attr('href')).load(tab.data('url'), function() {
        tab.removeClass('disabled');
        tab.html(tab.data('loaded'));
        $('#blast').find('li').each(function() {
          var contig, link;
          link = $(this);
          if (link.data('tab') === tab.attr('href')) {
            contig = ($('#contig-sequence')).val();
            link.html('<a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?' + 
                      'PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&' + 
                      'LINK_LOC=blasthome&QUERY=' + contig + '" ' + 
                      'target="_blank">BLAST Contig Sequence</a>');
          }
        });
      });
    });
  }
});