/* global HTMLImageElement */

import React, { useEffect, useLayoutEffect, useRef, useState } from 'react'

import {
  AssistantMessage,
  StreamingMessage,
  SystemMessage,
  UserMessage
} from '~/js/components/Messages'

import { ModelSelect, ProviderSelect } from '~/js/components/Select'
import { useModels, useWebSocket } from '~/js/hooks'

export default function App () {
  const [message, setMessage] = useState('')
  const [provider, setProvider] = useState('openai')
  const { loading: modelsLoading, model, models, setModel } = useModels(provider)
  const { entries, send, status, streaming } = useWebSocket(provider, model, setModel)
  const streamRef = useRef(null)

  const scrollToBottom = () => {
    const stream = streamRef.current
    if (stream) stream.scrollTop = stream.scrollHeight
  }

  useLayoutEffect(() => {
    scrollToBottom()
  }, [entries, streaming])

  useEffect(() => {
    const stream = streamRef.current
    if (!stream) return
    const onLoad = (event) => {
      if (event.target instanceof HTMLImageElement) scrollToBottom()
    }
    stream.addEventListener('load', onLoad, true)
    return () => stream.removeEventListener('load', onLoad, true)
  }, [])

  const onSubmit = (event) => {
    event.preventDefault()
    if (!message) return
    if (send(message)) setMessage('')
  }

  const onProviderChange = (event) => {
    setProvider(event.target.value)
  }

  return (
    <main className='h-screen bg-white font-sans text-zinc-900'>
      <div className='mx-auto flex h-full min-h-0 w-full max-w-6xl flex-col gap-4 px-4 py-6 sm:px-6'>
        <header className='pb-1 text-center'>
          <img
            className='mx-auto max-h-16 w-auto max-w-xs rounded-2xl'
            src='/images/realtalk.png'
            alt='RealTalk'
          />
        </header>
        <div
          id='stream'
          ref={streamRef}
          className='min-h-0 flex-1 overflow-y-auto rounded-3xl border border-zinc-200 bg-zinc-50 p-4 text-[15px] leading-7 shadow-sm'
        >
          {entries.map((entry, index) => {
            if (entry.kind === 'assistant') { return <AssistantMessage key={index} markdown={entry.markdown} /> }
            if (entry.kind === 'user') { return <UserMessage key={index} text={entry.text} /> }
            return <SystemMessage key={index} text={entry.text} />
          })}
          {streaming ? <StreamingMessage markdown={streaming} /> : null}
        </div>
        <p className='text-center text-sm text-zinc-500'>
          Status: <span className='font-semibold text-zinc-700'>{status}</span>
        </p>
        <div className='flex justify-center text-sm'>
          <div className='flex items-center gap-3 text-zinc-500'>
            <ProviderSelect provider={provider} onChange={onProviderChange} />
            <ModelSelect
              loading={modelsLoading}
              model={model}
              models={models}
              onChange={(event) => setModel(event.target.value)}
            />
            <span className='text-xs text-zinc-400'>
              {modelsLoading ? '...' : `${models.length} models`}
            </span>
          </div>
        </div>
        <form
          className='sticky bottom-0 flex flex-col gap-2 bg-gradient-to-b from-white/0 via-white/90 to-white pt-3 pb-1'
          onSubmit={onSubmit}
        >
          <input
            className='h-13 w-full rounded-2xl border border-zinc-200 bg-white px-4 text-[15px] text-zinc-900 outline-none placeholder:text-zinc-400 focus:border-zinc-300 focus:ring-4 focus:ring-zinc-900/10'
            type='text'
            placeholder='Type a message'
            autoComplete='off'
            value={message}
            onChange={(event) => setMessage(event.target.value)}
          />
          <div className='flex justify-end'>
            <button
              className='min-w-24 rounded-full bg-zinc-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-zinc-800 focus:ring-4 focus:ring-zinc-900/10 focus:outline-none'
              type='submit'
            >
              Send
            </button>
          </div>
        </form>
      </div>
    </main>
  )
}
