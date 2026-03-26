const Timer = function(parentEl) {
  if (!parentEl)
    return null

  const self = Object.create(null)

  self.parentEl = parentEl
  self.timeout = null
  self.startTime = null
  self.el = null

  self.getStatusEl = (parent = self.parentEl) => {
    return parent?.querySelector(".status-value")
  }

  self.create = () => {
    const timer = document.createElement("span")
    timer.className = "timer-value"
    return timer
  }

  self.update = (elapsedSeconds) => {
    if (!self.el) return
    self.el.textContent = `${elapsedSeconds}s`
    if (elapsedSeconds >= 10)
      self.el.title = `Running for ${elapsedSeconds} seconds`
    else
      self.el.removeAttribute("title")
  }

  self.tick = () => {
    if (!self.startTime) return
    const elapsedMs = Date.now() - self.startTime
    const elapsedSeconds = Math.floor(elapsedMs / 1000)
    self.update(elapsedSeconds)
    const delay = 1000 - (elapsedMs % 1000)
    self.timeout = setTimeout(self.tick, delay)
  }

  self.attachTo = (span) => {
    if (self.el && !self.el.isConnected)
      self.el = null
    if (!span || self.el) return
    self.el = self.create()
    const wrapper = document.createElement("span")
    wrapper.className = "status-active"
    const originalText = span.textContent.replace(/\s*\(\d+s\)$/, "")
    const textNode = document.createTextNode(originalText)
    span.textContent = ""
    wrapper.appendChild(textNode)
    wrapper.appendChild(self.el)
    span.appendChild(wrapper)
  }

  self.detach = () => {
    if (!self.el) return
    if (self.el.parentNode)
      self.el.parentNode.remove()
    self.el = null
  }

  self.start = (statusText) => {
    if (self.timeout)
      clearTimeout(self.timeout)
    self.startTime = Date.now()
    const span = self.getStatusEl()
    if (!span) return
    self.attachTo(span)
    self.update(0)
    self.timeout = setTimeout(self.tick, 1000)
  }

  self.stop = () => {
    if (self.timeout)
      clearTimeout(self.timeout)
    self.timeout = null
    self.detach()
    self.startTime = null
  }

  self.handle = (parent) => {
    const span = self.getStatusEl(parent)
    if (!span) return
    const statusText = span.textContent.trim()
    if (statusText.startsWith("Thinking") || statusText.startsWith("Running"))
      self.start(statusText)
    else
      self.stop()
  }

  return self
}

export { Timer }
