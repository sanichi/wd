$(function() {
  $('#copy_emails').click(function(e) {
    e.preventDefault();
    document.getElementById('emails_to_copy').select();
    document.execCommand('copy');
  });
});
