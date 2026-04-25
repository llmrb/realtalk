import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"

window.htmx = htmx
require("htmx-ext-ws")

import { Jukebox } from "../js/jukebox"
import { FileUpload } from "../js/file_upload"
import { Scroll } from "../js/scroll"
import { Timer } from "../js/jukebox/timer"

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const jukebox = Jukebox()
    const timer = Timer(document.getElementById("chatbot-status"))
    let scroll = Scroll(document.getElementById("chatbot-stream"))
    const syntaxHighlight = (el) =>{
      hljs.highlightElement(el)
    }
    const modifyAnchors = (el) =>{
      el.setAttribute("target", "_blank")
      el.setAttribute("rel", "noreferrer noopener")
    }
    const refreshScroll = () => {
      const stream = document.getElementById("chatbot-stream")
      if (!stream)
        return
      if (!scroll || scroll.parentEl !== stream)
        scroll = Scroll(stream)
    }
    const enhance = (root = document.body) => {
      refreshScroll()
      root.querySelectorAll("pre code").forEach(syntaxHighlight)
      root.querySelectorAll("a").forEach(modifyAnchors)
      const nodes = root.querySelectorAll(".assistant-content")
      if (nodes.length > 0)
        jukebox.scanForMusic(nodes[nodes.length - 1])
    }
    const fileUpload = FileUpload({afterUpload: enhance})
    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      const elt = event.detail.elt || event.target
      if (elt.id === "chatbot-status") {
        timer.parentEl = elt
        timer.handle(elt)
        return
      }
      enhance(elt)
      scroll?.followIfNeeded()
    })

    document.body.addEventListener("htmx:afterSwap", (event) => {
      const elt = event.detail.elt || event.target
      enhance(elt)
      scroll?.followIfNeeded()
    })

    document.body.addEventListener("submit", (event) => {
      if (event.target.id !== "chat-composer")
        return
      if (fileUpload.blockSubmit(event))
        return
      scroll?.force()
    })
    document.body.addEventListener("focusin", (event) => {
      if (!event.target.matches("#chat-composer textarea"))
        return
      scroll?.force()
    })
    document.body.addEventListener("input", (event) => {
      if (!event.target.matches("#chat-composer textarea"))
        return
      scroll?.force()
    })
    document.body.addEventListener("change", (event) => {
      if (!event.target.matches("#file-upload-input"))
        return
      fileUpload.upload(event.target.files?.[0])
    })
    enhance()
    requestAnimationFrame(() => scroll?.force())
    window.addEventListener("load", () => scroll?.force(), { once: true })
  })
})()
