import { useEffect, useState } from 'react'

export default function useModels ({ session, setSession }) {
  const [models, setModels] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(false)

  const unmarshal = (response) => response.json()

  const clear = (response) => {
    setModels([])
    setLoading(true)
    setError(false)
    return response
  }

  const receive = (payload) => {
    setModels(payload)
    setLoading(false)
    return payload
  }

  const onError = (error) => {
    if (error.name === 'AbortError') {
      return
    }
    setLoading(false)
    setError(true)
  }

  useEffect(() => {
    const controller = new AbortController()
    const path = `/models?provider=${encodeURIComponent(session.provider)}`
    fetch(path, { signal: controller.signal })
      .then(clear)
      .then(unmarshal)
      .then(receive)
      .catch(onError)
    return () => controller.abort()
  }, [session.provider])

  useEffect(() => {
    const setDefault = (model) => setSession((prev) => ({...prev, model}))
    switch(session.provider) {
      case 'openai':
        setDefault('gpt-5.2')
        break
      case 'google':
        setDefault('gemini-2.5-pro')
        break
      case 'anthropic':
        setDefault('claude-sonnet-4-20250514')
        break
      case 'deepseek':
        setDefault('deepseek-chat')
        break
      case 'xai':
        setDefault('grok-3')
        break
    }
  }, [session.provider])

  return {
    error,
    loading,
    models,
  }
}
