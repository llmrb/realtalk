import "../css/application.css"
import htmx from "htmx.org"
import { marked } from "marked"

window.htmx = htmx
window.marked = marked
require("htmx-ext-ws")

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const scroll = () => {
      const stream = document.getElementById("chatbot-stream")
      if (!stream) return
      stream.scrollTop = stream.scrollHeight
    }

    const follow = () => {
      scroll()
      requestAnimationFrame(scroll)
      setTimeout(scroll, 0)
      setTimeout(scroll, 32)
    }

    const markdown = (root = document.body) => {
      root.querySelectorAll("[data-markdown]").forEach((element) => {
        const template = element.querySelector("template")
        if (!template) return
        element.innerHTML = marked.parse(template.innerHTML)
      })
    }

    document.body.addEventListener("htmx:afterSwap", (event) => markdown(event.target))
    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      markdown(event.target)
      follow()
    })
  })
})()
