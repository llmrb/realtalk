export const Scroll = (parentEl) => {
  if (!parentEl)
    return null

  const self = Object.create(null)
  const threshold = 8
  const releaseRatio = 0.7
  const onScroll = () => {
    if (ignoreScroll) return
    following = isNearBottom()
    if (!following)
      self.cancel()
  }
  const isNearBottom = () => {
    return (parentEl.scrollHeight - (parentEl.scrollTop + parentEl.clientHeight)) <= threshold
  }
  const lastAssistantMessage = () => {
    return parentEl.querySelector("#chatbot-messages > div:last-of-type .assistant-content")
      || parentEl.querySelector("#chatbot-messages .chat-bubble-assistant:last-of-type")
  }
  const shouldRelease = () => {
    const messageEl = lastAssistantMessage()
    if (!messageEl)
      return false
    return messageEl.getBoundingClientRect().height >= (parentEl.clientHeight * releaseRatio)
  }

  let following = true
  let followFrame = null
  let ignoreScroll = false

  self.parentEl = parentEl

  /**
   * Cancel any pending animation frame that would continue following the
   * stream.
   *
   * @returns {void}
   */
  self.cancel = () => {
    if (!followFrame) return
    cancelAnimationFrame(followFrame)
    followFrame = null
  }

  /**
   * Scroll the container to its current bottom edge and refresh the internal
   * follow state after layout settles.
   *
   * @returns {void}
   */
  self.scroll = () => {
    ignoreScroll = true
    parentEl.scrollTop = parentEl.scrollHeight
    requestAnimationFrame(() => {
      parentEl.scrollTop = parentEl.scrollHeight
      ignoreScroll = false
      following = isNearBottom()
    })
  }

  /**
   * Re-enable follow mode and immediately jump to the newest content.
   *
   * Use this when a new turn starts and the reader should be brought back to
   * the live edge of the conversation.
   *
   * @returns {void}
   */
  self.force = () => {
    following = true
    self.scroll()
  }

  /**
   * Follow incoming content only while the latest assistant reply still fits
   * comfortably within the viewport.
   *
   * Once the latest reply grows large enough to be readable in place, follow
   * mode is released so the viewport stops moving during streaming updates.
   *
   * @returns {void}
   */
  self.followIfNeeded = () => {
    if (!following)
      return
    if (shouldRelease()) {
      following = false
      self.cancel()
      return
    }
    if (followFrame)
      return
    followFrame = requestAnimationFrame(() => {
      followFrame = null
      self.scroll()
    })
  }

  following = isNearBottom()
  parentEl.addEventListener("scroll", onScroll, { passive: true })

  return self
}
