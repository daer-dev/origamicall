$(window).load(function() {
  window.sr = new scrollReveal({
    mobile: true
  });

  $('.hidden-block').hide();

  if($('#modal.auto').length > 0) {
    $('#modal').modal('show');
    setTimeout('$(\'#modal\').modal(\'hide\')', 3000);
  }

  $('a#current-locale').click(function(e) {
    $('#modal .modal-dialog .modal-content .modal-body p').text($('.navbar .dropdown-menu .hidden-block').html());
  });

  $('[data-tooltip]').tooltip();

  $('a[href*=#]:not([href=#]):not([href=#quotes])').click(function(e) {
    e.preventDefault();

    var hash = this.hash;

    $('html, body').animate({
      scrollTop: $(this.hash).offset().top
    }, 1000, function(){
      window.location.hash = hash;
    })
  });

  $('#products-content .product .button-container a').click(function() {
    var button_container = $(this).parent();
    button_container.parent().find('.text .hidden-block').slideDown('slow', function() {
      button_container.fadeOut();
    });
    return false;
  });

  $('form').submit(function(e) {
    if($.trim($('form textarea').val()) == '') {
      $('#modal').modal();
      e.preventDefault();
    }
  });
});