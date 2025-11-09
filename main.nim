import dom

#--------------------
# A simple tool for saving browser sessions in Firefox
#--------------------

var urls: seq[string] = @[]

proc getAllTabs() =
  {.emit: """
    browser.tabs.query({}).then(tabs => {
      window.urls = tabs.map(tab => tab.url);
      document.getElementById("urls").innerHTML = 
        window.urls.map(url => '<li>' + url + '</li>').join('');
    });
  """.}

proc saveSessionData() =
  {.emit: """
    browser.storage.local.set({
      savedUrls: window.urls,
      savedDate: new Date().toISOString()
    }).then(() => {
      window.alert('Session saved successfully!');
    }).catch(err => {
      window.alert('Error saving session: ' + err);
    });
  """.}

proc loadSavedUrls() =
  {.emit: """
    browser.storage.local.get('savedUrls').then(result => {
      if (result.savedUrls) {
        window.urls = result.savedUrls;
        document.getElementById("urls").innerHTML = 
          window.urls.map(url => '<li>' + url + '</li>').join('');
      }
    });
  """.}

proc openTabs() = 
  {.emit: """
    window.urls.forEach(url => {
        browser.tabs.create({ url: url });
    });
  """.}

proc validateUrls(): string =
  if urls.len == 0:
    return "No tabs found to open"
  return ""

proc main() =
  let content = document.getElementById("content")
  content.innerHTML = """
    <p>Your Firefox Tabs:</p>
    <p>------------------</p>
    <ul id="urls"></ul>
  """

  let saveButton = document.createElement("button")
  saveButton.innerHTML = "Save Session"
  saveButton.onclick = proc(e: Event) =
    getAllTabs()
    saveSessionData()

  let openButton = document.createElement("button")
  openButton.innerHTML = "Open Saved Tabs"
  openButton.onclick = proc(e: Event) =
    loadSavedUrls()
    openTabs()

  content.appendChild(saveButton)
  content.appendChild(openButton)

when isMainModule:
  main()