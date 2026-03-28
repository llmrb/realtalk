import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"

window.htmx = htmx
require("htmx-ext-ws")

import { Jukebox } from "../js/jukebox"
import { Timer } from "../js/jukebox/timer"

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const jukebox = Jukebox()
    const timer = Timer(document.getElementById("chatbot-status"))
    const stream = document.getElementById("chatbot-stream")
    let shouldFollow = true
    let followFrame = null

    const isNearBottom = (el, threshold = 48) =>
      !el || (el.scrollHeight - (el.scrollTop + el.clientHeight)) <= threshold

    const scroll = () => {
      if (!stream || !shouldFollow) return
      stream.scrollTop = stream.scrollHeight
    }

    const follow = () => {
      if (followFrame) return
      followFrame = requestAnimationFrame(() => {
        followFrame = null
        scroll()
      })
    }

    const syntaxHighlight = (el) =>{
      hljs.highlightElement(el)
    }

    const modifyAnchors = (el) =>{
      el.setAttribute("target", "_blank")
      el.setAttribute("rel", "noreferrer noopener")
    }

    const enhance = (root = document.body) => {
      root.querySelectorAll("pre code").forEach(syntaxHighlight)
      root.querySelectorAll("a").forEach(modifyAnchors)
      const nodes = root.querySelectorAll(".assistant-content")
      if (nodes.length > 0)
        jukebox.scanForMusic(nodes[nodes.length - 1])
    }

    document.body.addEventListener("htmx:beforeSwap", () => {
      shouldFollow = isNearBottom(stream)
    })

    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      const elt = event.detail.elt || event.target
      if (elt.id === "chatbot-status") {
        timer.parentEl = elt
        timer.handle(elt)
      }
      enhance(elt)
      follow()
    })

    document.body.addEventListener("htmx:afterSwap", (event) => {
      const elt = event.detail.elt || event.target
      enhance(elt)
    })

    enhance()
    follow()
  })
})()
