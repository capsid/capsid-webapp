$(function() {
  var tabs;
  ($("[rel=popover]")).popover({
    html: true,
    delay: {
      show: 300,
      hide: 100
    }
  });
  ($("[rel=tooltip]")).tooltip({
    delay: {
      show: 200,
      hide: 100
    }
  });
  ($('div.btn-group[data-toggle-name=*]')).each(function() {
    var form, group, hidden, name;
    group = $(this);
    form = group.parents('form').eq(0);
    name = group.attr('data-toggle-name');
    hidden = $('input[name="' + name + '"]', form);
    ($('button', group)).each(function() {
      var button;
      button = $(this);
      button.live('click', function() {
        button.siblings().removeClass('active');
        button.addClass('active');
        return hidden.val(button.val());
      });
      if (button.val() === hidden.val()) return button.addClass('active');
    });
  });
  ($("#add-bookmark")).click(function() {
    ($("#add-bookmark-modal input[name='title']")).val(document.title);
    return ($("#add-bookmark-modal input[name='address']")).val(window.location.pathname + window.location.search);
  });
  ($("#add-bookmark-modal form")).submit(function() {
    var uri;
    uri = ($(this)).attr('action') + '?' + ($(this)).serialize();
    $.post(uri, function(bookmark) {
      ($('#bookmarks')).append('<li><a href="' + bookmark.address + '"><i class="icon-bookmark"></i> ' + bookmark.title + '</a></li>');
      return ($('#add-bookmark-modal')).modal('hide');
    });
    return false;
  });
  ($(".sidebar .well.separator")).click(function() {
    return ($(this)).parent().parent().toggleClass('use_sidebar');
  });
  ($('#filter')).keyup(function() {
    var value;
    value = ($(this)).val();
    if (value) {
      ($('#items > li:not(:contains(' + value + '))')).hide();
      return ($('#items > li:contains(' + value + ')')).fadeIn('fast');
    } else {
      return ($('#items > li')).fadeIn('fast');
    }
  });
  if (($('.pagination a')).length) {
    ($('.pagination a')).pjax('#results', {
      fragment: '#results',
      timeout: '2000'
    }).live('click');
  }
  if (($('th a')).length) {
    ($('th a')).pjax('#results', {
      fragment: '#results',
      timeout: '2000'
    }).live('click');
  }
  if (($('.external-filter')).length) {
    ($('.external-filter')).pjax('#results', {
      fragment: '#results',
      timeout: '2000'
    }).live('click');
  }
  ($('#uac form')).submit(function() {
    var id, uri;
    uri = ($(this)).attr('action') + '&' + ($(this)).serialize();
    id = ($(this)).parents('.accordion-body').attr('id');
    $.post(uri, function(data) {
      ($('#' + id + ' .user-list')).append(data);
      return ($('.search-query')).each(function() {
        var i, s;
        ($(this)).val('');
        s = ($(this)).data('source');
        i = s.indexOf(data.username);
        s.splice(i, 1);
        return ($(this)).data('source', s);
      });
    });
    return false;
  });
  ($('.content')).delegate('.delete.close', 'click', function() {
    var parent, uri;
    parent = ($(this)).parent();
    uri = ($(this)).attr('href');
    $.post(uri, function(data) {
      parent.fadeOut('fast', function() {
        return ($(this)).remove();
      });
      return ($('.search-query')).each(function() {
        return ($(this)).data('source').push(data.username);
      });
    });
    return false;
  });
  if (($('.nav-tabs')).length) {
    tabs = ($('.nav-tabs')).find('li.ajax a');
    console.log(tabs);
    tabs.each(function() {
      var tab;
      tab = $(this);
      return $(tab.attr('href')).load(tab.data('url'), function() {
        tab.removeClass('disabled');
        tab.html(tab.data('loaded'));
        return ($('#blast')).find('li').each(function() {
          var contig, link;
          link = $(this);
          if (link.data('tab') === tab.attr('href')) {
            contig = ($('#contig-sequence')).val();
            return link.html('<a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?' + 'PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&' + 'LINK_LOC=blasthome&QUERY=' + contig + '" ' + 'target="_blank">BLAST Contig Sequence</a>');
          }
        });
      });
    });
  }
});