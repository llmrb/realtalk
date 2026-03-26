import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"
import { marked } from "marked"

window.htmx = htmx
window.marked = marked
require("htmx-ext-ws")

import { Jukebox } from "../js/jukebox"

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const jukebox = Jukebox()
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

    const syntaxHighlight = (el) =>{
      hljs.highlightElement(el)
    }

    const modifyAnchors = (el) =>{
      el.setAttribute("target", "_blank")
      el.setAttribute("rel", "noreferrer noopener")
    }

    const markdown = (root = document.body) => {
      const nodes = root.querySelectorAll("[data-markdown]")
      nodes.forEach((node, index) => {
        node.innerHTML = marked.parse(node.dataset.markdownSource || "")
        node.querySelectorAll("pre code").forEach(syntaxHighlight)
        node.querySelectorAll("a").forEach(modifyAnchors)
        if (index === nodes.length - 1)
          jukebox.scanForMusic(node)
      })
    }

    // Timer functionality for thinking/tool execution
    let timerInterval = null
    let timerStartTime = null
    let currentStatus = ""

    const updateTimerDisplay = () => {
      const statusElement = document.getElementById("chatbot-status")
      if (!statusElement) return

      const statusSpan = statusElement.querySelector(".font-medium.text-zinc-100")
      if (!statusSpan) return

      const statusText = statusSpan.textContent.trim()
      
      // Check if we're in a thinking or tool execution state
      const isThinking = statusText.startsWith("Thinking")
      const isRunningTool = statusText.startsWith("Running")
      
      if (isThinking || isRunningTool) {
        // Extract base status without timer
        const baseStatus = statusText.replace(/\s*\(\d+s\)$/, "")
        
        // Start timer if not already running or if status changed
        if (baseStatus !== currentStatus) {
          currentStatus = baseStatus
          timerStartTime = Date.now()
          
          if (timerInterval) {
            clearInterval(timerInterval)
          }
          
          timerInterval = setInterval(() => {
            if (!timerStartTime) return
            
            const elapsedSeconds = Math.floor((Date.now() - timerStartTime) / 1000)
            statusSpan.textContent = `${baseStatus} (${elapsedSeconds}s)`
          }, 1000)
          
          // Initial update
          statusSpan.textContent = `${baseStatus} (0s)`
        }
      } else {
        // Not in thinking/tool state, clear timer
        currentStatus = ""
        timerStartTime = null
        if (timerInterval) {
          clearInterval(timerInterval)
          timerInterval = null
        }
      }
    }

    // Observe status changes
    const observeStatusChanges = () => {
      const statusElement = document.getElementById("chatbot-status")
      if (!statusElement) return

      // Create a MutationObserver to watch for status changes
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList' || mutation.type === 'characterData') {
            updateTimerDisplay()
          }
        })
      })

      // Observe the status span for text changes
      const statusSpan = statusElement.querySelector(".font-medium.text-zinc-100")
      if (statusSpan) {
        observer.observe(statusSpan, {
          childList: true,
          characterData: true,
          subtree: true
        })
      }

      // Also observe the entire status element for replacements
      observer.observe(statusElement, {
        childList: true,
        subtree: true
      })

      // Initial check
      updateTimerDisplay()
    }

    // Initialize after DOM is ready
    setTimeout(observeStatusChanges, 100)

    markdown()
    follow()

    document.body.addEventListener("htmx:afterSwap", (event) => markdown(event.target))
    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      markdown(event.target)
      follow()
      
      // Check for status updates after OOB swaps
      if (event.target.id === "chatbot-status" || 
          event.target.querySelector && event.target.querySelector("#chatbot-status")) {
        setTimeout(updateTimerDisplay, 50)
      }
    })
  })
})()