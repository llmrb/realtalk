/* global WebSocket */

import { useEffect, useState } from 'react'

const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'

export default function useWebSocket ({session, setSession}) {
  const [status, setStatus] = useState('connecting')
  const [entries, setEntries] = useState([])
  const [stream, setStream] = useState('')
  const [socket, setSocket] = useState(null)

  const say = (kind, text) => {
    setEntries((prev) => [...prev, { kind, text }])
  }

  const error = () => {
    setStream('')
    setStatus('error')
    say('system', 'server: server error')
  }

  const onMessage = (payload) => {
    switch (payload.event) {
      case 'welcome':
        say('system', `server: connected (${session.provider} / ${session.model})`)
        break
      case 'status':
        setStatus(payload.message)
        break
      case 'delta':
        setStream((prev) => prev + payload.message)
        break
      case 'done':
        setStream((current) => {
          if (current) { setEntries((prev) => [...prev, { kind: 'assistant', markdown: current }]) }
          return ''
        })
        if (payload.cost === 'unknown') {
          setSession((prev) => ({...prev, cost: payload.cost}))
        } else {
          setSession((prev) => ({...prev, cost: `$${payload.cost}`}))
        }
        setStatus('ready')
        break
      case 'error':
        error('server: server error')
        break
      default:
        break
    }
  }

  useEffect(() => {
    if (!session.model) { return }

    let active = true
    const query = `provider=${encodeURIComponent(session.provider)}&model=${encodeURIComponent(session.model)}`
    const socket = new WebSocket(`${protocol}//${window.location.host}/ws?${query}`)
    setSocket(socket)
    setStatus('connecting')

    socket.addEventListener('open', () => active && setStatus('ready'))
    socket.addEventListener('close', () => active && setStatus('closed'))

    socket.addEventListener('error', () => {
      if (!active) { return }
      setStatus('error')
      say('client: socket error')
    })

    socket.addEventListener('message', (event) => {
      if (!active) { return }
      try {
        const payload = JSON.parse(event.data)
        onMessage(payload)
      } catch (err) {
        say('client: recv failed')
        console.error(err)
      }
    })

    return () => {
      active = false
      socket.close()
    }
  }, [session.provider, session.model])

  const send = (message) => {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      say('client: socket is not open')
      return false
    }
    setStatus('waiting')
    say('user', message)
    socket.send(message)
    return true
  }

  return {
    entries,
    send,
    status,
    stream
  }
}
