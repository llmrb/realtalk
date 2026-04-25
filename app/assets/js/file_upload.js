export const FileUpload = ({afterUpload}) => {
  const self = { active: false }

  const replaceChatInput = (html) => {
    const current = document.getElementById("chat-input")
    if (!current)
      return
    current.outerHTML = html
    const next = document.getElementById("chat-input")
    if (!next)
      return
    window.htmx.process(next)
    afterUpload(next)
    next.querySelector("textarea")?.focus()
  }

  const setState = ({active, text}) => {
    self.active = active
    const indicator = document.getElementById("file-upload-indicator")
    const input = document.getElementById("file-upload-input")
    const label = document.querySelector("label[for='file-upload-input']")
    const composer = document.getElementById("chat-composer")
    const textarea = composer?.querySelector("textarea")
    const submit = composer?.querySelector("button[type='submit']")
    if (indicator) {
      indicator.textContent = text
      indicator.classList.toggle("is-active", active)
    }
    if (input)
      input.disabled = active
    if (label)
      label.classList.toggle("opacity-60", active)
    if (composer)
      composer.classList.toggle("opacity-60", active)
    if (textarea)
      textarea.disabled = active
    if (submit)
      submit.disabled = active
  }

  self.upload = (file) => {
    if (!file)
      return
    setState({active: true, text: "Uploading attachment..."})
    const xhr = new XMLHttpRequest()
    xhr.open("POST", "/upload-attachment", true)
    xhr.setRequestHeader("Content-Type", file.type || "application/octet-stream")
    xhr.setRequestHeader("X-File-Name", encodeURIComponent(file.name))
    xhr.upload.addEventListener("progress", (event) => {
      if (!event.lengthComputable)
        return
      const percent = Math.max(1, Math.round((event.loaded / event.total) * 100))
      setState({active: true, text: `Uploading attachment... ${percent}%`})
    })
    xhr.addEventListener("load", () => {
      setState({active: false, text: "Uploading attachment..."})
      if (xhr.responseText)
        replaceChatInput(xhr.responseText)
    })
    xhr.addEventListener("error", () => {
      setState({active: true, text: "Upload failed. Try again."})
    })
    xhr.send(file)
  }

  self.blockSubmit = (event) => {
    if (!self.active)
      return false
    event.preventDefault()
    setState({active: true, text: "Finish uploading the attachment before sending."})
    return true
  }

  return self
}
