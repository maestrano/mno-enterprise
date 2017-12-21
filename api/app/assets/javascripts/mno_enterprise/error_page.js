var mnoHub = {};

mnoHub.check = function() {
  var xhr = new XMLHttpRequest();
  mnoHub.notify("Checking...");

  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE ) {
      console.log (xhr.status);
      if(xhr.status < 500) {
        mnoHub.notify("Application is now running! Redirecting...")
        mnoHub.stopAutoCheck();
        return window.setTimeout(function() {
          return mnoHub.redirect();
        }, 4 * 1000);
      }
      window.setTimeout(function() {
        mnoHub.notify('');
      }, 1 * 1000);
    }
  }

  xhr.ontimeout = function () {
    mnoHub.notify('');
  }

  xhr.timeout = 15000; //15 seconds
  xhr.open("GET", "/mnoe/health_check/full.json", true);
  xhr.send();
};

mnoHub.redirect = function() {
  return window.location.href = "/";
};

mnoHub.startAutoCheck = function() {
  // For 500 error, we should not keep auto refreshing the page till bug
  //  is resolved manually by our team.
  var page_error_code = document.getElementById('status_code').value;
  if(parseInt(page_error_code) == 500) {
    return;
  }

  return mnoHub.timerId = window.setInterval(function() {
    return mnoHub.check();
  }, 10 * 1000);
};

mnoHub.stopAutoCheck = function() {
  if (mnoHub.timerId != null) {
    return window.clearInterval(mnoHub.timerId);
  }
};

mnoHub.notify = function(msg) {
  var elem = document.getElementById('error-loader');
  elem.innerHTML = msg;
}

mnoHub.startAutoCheck();
